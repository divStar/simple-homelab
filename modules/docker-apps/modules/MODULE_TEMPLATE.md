# Adding a new Docker-app module

This guide is the canonical procedure for adding a new self-hosted application module under `modules/docker-apps/modules/<app>/`, integrated with Traefik + Zitadel SSO + the private `my.world` CA. It is written for Claude Code's future sessions (and any human contributor) so that a prompt like *"create a module for Directus"* lands the same shape every time.

When in doubt - **ask the user**. Most decisions below are conventional, but every app has quirks. If research and existing modules don't answer a question with confidence, surface it.

> **Treat the user's prompt as intent, not spec.** Past prompts have asked for things that contradict the reference modules (e.g. "add the `com.docker.network.bridge.gateway_priority` label" - no existing module uses it, including the one cited as the reference). When research or the closest reference disagrees with what was asked, **stop and confirm** before writing it; record the resolution explicitly.

---

## 0. Reference modules - read these first

Always read at least one closest-match reference module **in full** before writing anything.

| Use case | Reference module |
|---|---|
| Web app + Postgres + Redis + OIDC, env-var driven | `modules/docker-apps/modules/outline/` or `modules/docker-apps/modules/grist/` |
| Web app + Postgres + OIDC + init container | `modules/docker-apps/modules/gitea/` |
| Web app needing post-boot REST setup (admin init, license, settings) | `modules/docker-apps/modules/portainer/` |
| Complex API-driven setup, multi-stage HTTP bootstrap | `modules/docker-apps/modules/jellyfin/` |
| Shared OIDC/Zitadel resources used by every app module | `modules/common/modules/oidc/` |
| Shared Docker networks/volumes definitions | `modules/docker-apps/modules/external-resources/` |

**Property ordering matters.** Mirror the reference module's service order, key order within each service block (`image` → `container_name` → `restart` → `command` → `environment` → `networks` → `labels` → `volumes` → `depends_on` → `healthcheck`), and block order in `main.tf` (`terraform` → `locals` → `provider` → `module` → `output`). This keeps future cleanup/standardization passes a no-op. If a new key is required (e.g. `command:` for `jit=off`), insert it at the natural position rather than appending at the end.

---

## 1. Up-front research

Before writing anything, gather (and verify against authoritative sources - Dockerfile, official docs - not the user's prompt):

1. **Official Docker image** name and tag (prefer `:latest` unless the user pins).
2. **Default HTTP port** the app listens on inside the container - verify against the official Dockerfile (`https://raw.githubusercontent.com/<org>/<repo>/main/Dockerfile`) via WebFetch; do not guess and do not trust a number cited in the prompt without checking.
3. **Base OS** of the image (Debian / Alpine / Ubuntu) - determines the CA bundle path. For Debian/Ubuntu/Alpine the convention `/etc/ssl/certs/ca-certificates.crt` works; verify if unsure.
4. **Persistent data directory** inside the container.
5. **Database requirements** - does it need its own Postgres? Some apps support SQLite (decide with the user); for production-grade, give it a dedicated Postgres. Never share a Postgres instance across apps unless the user explicitly asks.
6. **Highest officially supported Postgres major version** - check the app's docs. If unstated, default to `postgres:18-alpine` to match the rest of the stack and add a comment with the revert path to an older minor (`postgres:16-alpine` + wipe `<app>-db-data` volume).
7. **OIDC support** - exact env var names for issuer, client_id, client_secret, scopes, callback URL, end-session URL. Pull these from the app's official docs (`support.<app>.com/install/oidc`, `<repo>/docs/oidc.md`, etc.). Never guess env var names.
8. **OIDC callback path** - register this with Zitadel as a redirect URI. Common patterns: `/oauth2/callback`, `/auth/oidc.callback`, `/user/oauth2/<provider>/callback`. Verify per app.
9. **First-run admin setup mechanism**:
   - Env-var driven (e.g. `<APP>_DEFAULT_EMAIL` becomes admin on first login) - no Terraform restapi step needed.
   - API-driven init (Portainer-style admin user creation, license install, settings) - needs `mastercard/restapi` provider in `main.tf`.
   - Multi-stage HTTP wizard (Jellyfin-style startup → user creation → plugin install → SSO config) - needs `devops-rob/terracurl`.
   - Init container baked into compose (Gitea-style admin auth source registration).
10. **Healthcheck endpoint** - `/health`, `/status`, `/api/healthz`, etc. Verify.
11. **Whether the app supports parallel local + SSO login** - most apps replace local auth once OIDC is configured. Document the rescue procedure (comment-out OIDC env vars + redeploy) in the module README if so.

If research leaves anything ambiguous - **ask the user before writing code**. Don't invent.

---

## 2. Files to create

Inside `modules/docker-apps/modules/<app>/` (mandatory unless noted):

```
<app>/
├── docker-compose.yml
├── stack.env                       (transcrypt-encrypted in git; real values)
├── stack.env.example               (plaintext template, <placeholder> values)
├── main.tf
├── project.auto.tfvars             (only if Terraform variables are declared)
├── project.auto.tfvars.example     (only if project.auto.tfvars exists)
├── variables.tf                    (only if main.tf declares variables)
├── outputs.tf                      (only if outputs don't fit inline in main.tf)
├── README.md
└── .terraform.lock.hcl             (committed; created by `tofu init`)
```

You may add `<app>-reset.sh` or similar utility scripts if the app benefits (see `outline/outline-reset.sh`).

---

## 3. `docker-compose.yml` - checklist

Mirror Outline or Grist 1:1 for env-var-driven apps. Mirror Gitea/Portainer/Jellyfin when their bootstrap pattern is closer.

- **Service order**: db → redis (if present) → init container (if present) → main app.
- **Per-service keys**: `image`, `container_name`, `restart: unless-stopped`, `command` (if any), `environment` (list-of-names form so values come from `stack.env`), `networks`, `labels`, `volumes`, `depends_on`, `healthcheck`. Keep this order.
- **Main app networks** - two-network pattern:
  ```yaml
  networks:
    services-network:
      priority: 100   # Primary - Traefik / outbound
    <app>-network:
      priority: 10    # Internal - reaches db/redis only
  ```
  Do **NOT** use the `com.docker.network.bridge.gateway_priority` label - no existing module does. If a third-party doc (or a user prompt) tells you to add it, push back and confirm before diverging.
- **Database / redis sidecars** only attach to `<app>-network` (no exposure to `services-network`).
- **Traefik labels** (exact pattern):
  ```yaml
  labels:
    - "traefik.enable=true"
    - "traefik.docker.network=services-network"
    - "traefik.http.routers.<app>.rule=Host(`<app>.${BASE_DOMAIN}`)"
    - "traefik.http.routers.<app>.entrypoints=websecure"
    - "traefik.http.services.<app>.loadbalancer.server.port=<INTERNAL_PORT>"
  ```
- **CA bundle mount** (so the app trusts the private Zitadel CA):
  ```yaml
  volumes:
    - /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro
    - <app>-data:/<persist-path>
  ```
- **Healthchecks**: every db/redis service must have one (apps use `depends_on: { condition: service_healthy }`). Postgres pattern:
  ```yaml
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -d $${POSTGRES_DB} -U $${POSTGRES_USER}"]
    interval: 10s; timeout: 10s; retries: 5; start_period: 20s
  ```
  Redis pattern:
  ```yaml
  healthcheck:
    test: ["CMD", "redis-cli", "ping"]
    interval: 10s; timeout: 5s; retries: 5; start_period: 10s
  ```
- **Networks / volumes section** - every network and volume is `external: true`. They are created by `external-resources`, not by this compose.
- **Postgres safety net**: set `command: ["postgres", "-c", "jit=off"]` when the app uses TypeORM or has documented JIT issues on newer PG. Always comment the rationale.

### Variants

- **IPVLAN / static IP** (Jellyfin needs L2 broadcast for DLNA): declare an extra network in `external-resources` with `driver: ipvlan`, mount it as a third network on the app service.
- **Init container** (Gitea-style): add `<app>-init` service that runs after the main app, executes one-shot setup, exits. Use `depends_on: { <app>: { condition: service_healthy } }` and idempotent commands.
- **Sandboxes / runners** (gVisor inside Grist, Gitea Runner): keep them as additional services in the same compose; give them their own volumes if stateful.

---

## 4. `stack.env` and `stack.env.example` - checklist

- **Grouping & comments** match the reference module (no blank lines between groups, comment lines like `# Storage`, `# OIDC setup` introduce sections).
- **`BASE_DOMAIN`** is always the first line. In `stack.env` use `BASE_DOMAIN=my.world` (the real homelab domain). In `stack.env.example` use a generic placeholder like `BASE_DOMAIN=example.com` so the example file is safe to share/publish.
- **Use `${BASE_DOMAIN}` interpolation throughout - in BOTH `stack.env` and `stack.env.example`** - and never hardcode the literal domain anywhere else in either file. Example: `GRIST_DEFAULT_EMAIL=igor.voronin@${BASE_DOMAIN}`, `APP_HOME_URL=https://<app>.${BASE_DOMAIN}`, `GRIST_OIDC_IDP_ISSUER=https://zitadel.${BASE_DOMAIN}`. Hardcoding the domain is a lint-fix the user has applied manually in the past - get it right the first time.
- **Sensitive values** in `stack.env`: stub plausibly (e.g. `<random-hex>` generated via `openssl rand -hex 32`; DB password `<app>`; OIDC client_id/secret placeholders that get overwritten from `tofu output`). The file IS committed (transcrypt encrypts it via the `.gitattributes` filter `stack.env filter=crypt diff=crypt merge=crypt`) but treat real secrets carefully - `tofu apply` outputs the real values for first deploy.
- **`stack.env.example`** uses `<angle-bracket-placeholder>` style for every sensitive value.
- Always include `NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt` (or the language-specific equivalent: `SSL_CERT_FILE`, `REQUESTS_CA_BUNDLE`, etc.) so the app trusts the private CA. Ask the user if you're unsure which env var the runtime honors.
- **App-specific OIDC env var names** - don't normalize across modules. Use the exact names the upstream app documents (e.g. `OIDC_CLIENT_ID` for Outline vs `GRIST_OIDC_IDP_CLIENT_ID` for Grist).

---

## 5. `main.tf` - checklist

Layout (block order, no exceptions):

```hcl
/**
 * # <App> OIDC
 *
 * One-paragraph description, link to ../../../common/modules/oidc/README.md.
 */

terraform {
  required_version = ">= 1.10.5"
  required_providers {
    zitadel = { source = "zitadel/zitadel", version = ">= 2.5.0" }
    # restapi = { source = "Mastercard/restapi", version = ">= 2.0.1" }    # if needed
    # terracurl = { source = "devops-rob/terracurl", version = ">= 1.2.1" } # if needed
  }
}

locals {
  base_domain = "my.world"
}

provider "zitadel" {
  domain           = "zitadel.${local.base_domain}"
  insecure         = "false"
  port             = "443"
  jwt_profile_file = "${path.module}/../../admin_key.json"
}

# Comment explaining whether post-boot setup is needed.
module "<app>_web_ui_oidc" {
  source = "../../../common/modules/oidc"

  org_name         = "Sanctum"
  project_name     = "<App>"
  application_name = "<App> Web UI"
  app_type         = "OIDC_APP_TYPE_WEB"
  auth_method_type = "OIDC_AUTH_METHOD_TYPE_BASIC"   # or _POST if app can't use Basic header

  redirect_uris             = ["https://<app>.${local.base_domain}/", "https://<app>.${local.base_domain}/<callback-path>"]
  response_types            = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types               = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  post_logout_redirect_uris = ["https://<app>.${local.base_domain}/"]

  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true

  project_roles = {
    "<app>_admin" = { display_name = "<App> admin", group = "<app>" }
    # Add per-app roles as needed (e.g. gitea_user, jellyfin_kids).
  }

  user_grants = {
    "igor" = { user_name = "igor.voronin@${local.base_domain}", role_keys = ["<app>_admin"] }
  }
}

# Optional: restapi / terracurl providers and resources for post-boot setup. Reference Portainer / Jellyfin.

output "<app>_oidc_env_vars" {
  description = "Copy and paste these into the `stack.env` file"
  value = <<-EOT
    <APP>_OIDC_<ISSUER_VAR>=https://zitadel.${local.base_domain}
    <APP>_OIDC_<CLIENT_ID_VAR>=${module.<app>_web_ui_oidc.client_id}
    <APP>_OIDC_<CLIENT_SECRET_VAR>=${module.<app>_web_ui_oidc.client_secret}
    ... (all OIDC env vars the app needs)
  EOT
  sensitive = true
}

output "client_id"     { value = module.<app>_web_ui_oidc.client_id;     sensitive = true; description = "<App> Client ID" }
output "client_secret" { value = module.<app>_web_ui_oidc.client_secret; sensitive = true; description = "<App> Client Secret" }
```

### When post-boot setup is needed

- **Pure env-var apps** (Outline, Grist): no `restapi`/`terracurl` providers. Add a one-line comment `# <App> is env-var driven; no post-boot API setup is needed.`
- **`restapi`-driven** (Portainer): add two `provider "restapi"` aliases (`unauthorized` + `jwt`), do admin-init → auth → JWT extraction → settings configuration. Read Portainer's `main.tf` end-to-end.
- **`terracurl`-driven** (Jellyfin): more flexible multi-stage HTTP calls. Read Jellyfin's `main.tf` end-to-end.

When in doubt about which approach fits the app, **ask the user**.

---

## 6. `project.auto.tfvars` + `.example` - when needed

Create them **only** if `main.tf` (or a sibling `variables.tf`) declares Terraform variables (e.g. Portainer's `admin_password` and `portainer_license`). Otherwise skip entirely (Outline and Grist do).

- `*.tfvars` is in `.gitignore` (root `.gitignore`). The live file is NOT tracked unless force-added.
- If the module needs persistent sensitive variables, the live file should be `git add -f`ed and will then be encrypted via transcrypt (`*.tfvars filter=crypt diff=crypt merge=crypt` in `.gitattributes`). Portainer is the only module that does this today - confirm with the user before adding another.
- `*.tfvars.example` is plaintext, always committed, uses `<placeholder>` values.

---

## 7. `README.md` - structure

Use the auto-generated format from Outline / Grist verbatim:

```markdown
# <App> OIDC

<one-paragraph description, link to ../../../common/modules/oidc/README.md>

## Contents

<blockquote><!-- contents:start -->
- [Providers](#providers)
- [Modules](#modules) _(nested and adjacent)_
  - [<app>_web_ui_oidc](#<app>_web_ui_oidc)
- [Variables](#variables)
- [Outputs](#outputs)
  - [client_id](#client_id)
  - [client_secret](#client_secret)
  - [<app>_oidc_env_vars](#<app>_oidc_env_vars)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![zitadel](https://img.shields.io/badge/zitadel->=2.5.0-ee4398?logo=zitadel)

## Modules
<blockquote><!-- module:"<app>_web_ui_oidc":start -->
### `<app>_web_ui_oidc`
... (same shape, link main.tf line numbers)
</blockquote><!-- module:"<app>_web_ui_oidc":end -->

## Outputs
<blockquote><!-- output:"client_id":start --> ... </blockquote>
<blockquote><!-- output:"client_secret":start --> ... </blockquote>
<blockquote><!-- output:"<app>_oidc_env_vars":start --> ... </blockquote>

## Notes

- OIDC callback URL: `https://<app>.my.world/<callback-path>`
- Anything quirky (Postgres pinning, JIT-off, sandbox flavors, init containers, multi-org/tenant mode)
- SSO-only-auth rescue procedure if the app replaces local login with OIDC
- TODOs surfaced during research (gVisor on Flatcar, undocumented PG support, etc.)

## Prerequisites

- Networks (registered in `external-resources/`): `services-network`, `<app>-network` (+ any extras)
- Volumes: `<app>-data`, `<app>-db-data` (+ any extras)
- `admin_key.json` at `modules/docker-apps/admin_key.json`

## Usage

​```bash
$ tofu init
$ tofu apply -show-sensitive
# Copy the `<app>_oidc_env_vars` output into stack.env.
$ docker compose -f ./docker-compose.yml --env-file ./stack.env up -d
​```
```

---

## 8. Update `external-resources/project.auto.tfvars` + `.example`

Register all new networks and volumes here. The compose file references them as `external: true` and never creates them itself.

### Subnet allocation

Internal `<app>-network`s follow `172.20.<N>.0/24` where `<N>` increments by 10. Current allocations (as of 2026-05; verify before picking):

| Network | Subnet |
|---|---|
| `services-network` | 172.20.10.0/24 |
| `zitadel-network` | 172.20.20.0/24 |
| `outline-network` | 172.20.30.0/24 |
| `gitea-network` | 172.20.40.0/24 |
| `grist-network` | 172.20.50.0/24 |
| *(next free)* | 172.20.60.0/24 |

Before picking a subnet, `grep -rE "subnet  = \"172.20" external-resources/` to confirm the next free `/24`. IPVLAN networks (Jellyfin) use the LAN range (192.168.x.x) - coordinate with the user on routing.

### Volume registration

Every external volume needs an entry in `volumes = {...}`:

```hcl
"<app>-data" = {
  labels = {
    "com.docker-vm.managed-using" = "Terraform"
    "com.docker-vm.description"   = "<App>'s Data volume (...)"
    "com.docker-vm.tags"          = "<app>"
  }
}
```

DB volumes use the tag `"<app>,postgresql"`.

### `.example` sync

`external-resources/project.auto.tfvars.example` is committed; mirror your additions there too. Note that the example file has historically been left stale for some modules (jellyfin, outline, gitea aren't in it as of 2026-05) - when in doubt, ask the user whether to backfill or only add your own entry.

### Gitignore caveat

The live `external-resources/project.auto.tfvars` is gitignored (`*.tfvars` rule). Edits to it are local-only unless force-added. The `.example` mirror is what actually lands in git. If a deploy-side checkout needs the new networks/volumes, the user has to sync the live file manually (or you can offer to force-add it under transcrypt - confirm first).

---

## 9. Branch / git workflow

- New module → new branch `feature/<app>` off `master`.
- Live `project.auto.tfvars` and `stack.env` are transcrypted. Verify transcrypt is unlocked in the working tree before editing (`stack.env` should be human-readable, not gibberish). If it isn't, ask the user - never commit raw plaintext into a transcrypted file.
- Commit message style (from `git log`): `feat(<app>): <short description>` for new features, `fix(<app>): <description>` for bug fixes. Short, conventional-commits-ish, no fluff.

---

## 10. Local validation (do this - don't leave to user)

In the new module directory:

```bash
$ tofu init -backend=false   # downloads providers + sub-modules
$ tofu fmt -check -diff      # must exit 0
$ tofu validate              # must say "Success!"
$ tofu plan                  # smoke-test against live Zitadel; expect N resources to be created
```

`tofu plan` only talks to Zitadel over HTTPS, so it usually works regardless of the Docker context state.

```bash
$ docker compose -f docker-compose.yml --env-file stack.env config
```

`docker compose config` parses YAML and resolves env vars **without touching the Docker daemon** in most setups - but if the active `DOCKER_HOST`/context points to a remote daemon (as it does on this homelab; see `modules/docker-apps/README.md`), Compose may still try to ping it. **If the Docker context certs are expired, the command will fail.** Ask the user to renew certs before running `docker compose config`, or use `DOCKER_HOST=unix:///var/run/docker.sock docker compose ... config` to force a local-only render.

**Never run `docker compose up`** - that's the user's job on the deploy VM.

In `external-resources/`:

```bash
$ tofu fmt -check -diff
$ tofu validate
```

If any check fails, fix and re-run. Do not hand off a module with red local checks.

---

## 11. Leave to the user (E2E deploy)

Describe these in the module's README but do **not** run them:

1. `cd external-resources && tofu apply` to create networks/volumes.
2. `cd <app> && tofu apply -show-sensitive`; copy the `<app>_oidc_env_vars` output into `stack.env`.
3. Generate any real secrets (`openssl rand -hex 32`) and set real passwords in `stack.env`.
4. `docker compose -f docker-compose.yml --env-file stack.env up -d`.
5. Browser test: `https://<app>.my.world/` → Zitadel login → land as admin.
6. Sanity checks (healthcheck endpoint via `curl`, `jit=off` via `psql`, etc.).

The user owns the deploy because the Flatcar Docker VM context requires user-side cert renewal and they want to keep a hand on production state.

---

## 12. When to ask the user (mandatory)

Always ask before assuming:

- Database engine and version (especially if PG18 compatibility is undocumented).
- Whether to add Redis (some apps optionally use it for queues/webhooks).
- Single-tenant vs multi-tenant mode if the app has both (e.g. Grist's `GRIST_SINGLE_ORG`).
- Sandbox flavor on Flatcar (gVisor may or may not be available).
- Whether the live `project.auto.tfvars` should be force-added under transcrypt.
- Custom port allocation if anything obvious clashes.
- Whether to add the app to `modules/docker-apps/README.md` walkthrough (currently slated for a full overhaul - confirm before editing).
- **Anything where the user's prompt and the reference modules disagree.** Prompts may include technical claims that turn out to contradict established patterns (e.g. requesting a Docker label no module uses, or a Postgres version the app doesn't support). Treat the prompt as intent - verify the specifics.

It is always cheaper to ask one clarifying question than to write 200 lines that need re-doing. Keep questions focused and offer a recommended default in option 1.

---

## 13. Final checklist

Before declaring the module done:

- [ ] `<app>/docker-compose.yml` - services, networks, volumes, traefik labels, CA mount, healthchecks; key order matches reference module
- [ ] `<app>/stack.env` (stubbed, transcrypt-friendly, `${BASE_DOMAIN}` interpolation everywhere) + `stack.env.example` (placeholders)
- [ ] `<app>/main.tf` - terraform/locals/provider/module/output blocks in canonical order
- [ ] `<app>/project.auto.tfvars` + `.example` - only if Terraform vars exist
- [ ] `<app>/README.md` - Outline-format with badges, blockquote markers, Notes, Prerequisites, Usage
- [ ] `external-resources/project.auto.tfvars` - new network + volumes registered
- [ ] `external-resources/project.auto.tfvars.example` - mirror additions
- [ ] `<app>/.terraform.lock.hcl` - committed (from `tofu init`)
- [ ] `tofu fmt -check`, `tofu validate`, `tofu plan` all green in `<app>/` and `external-resources/`
- [ ] `docker compose config` renders cleanly with `stack.env` (after confirming Docker context is healthy)
- [ ] All TODO comments in code/README are explicit about what needs verification
- [ ] User has been asked about anything research couldn't pin down

When all boxes are checked, hand off to the user with: a short summary of what was created, the deploy steps from §11, and any outstanding TODOs from §12.

---

## Appendix: Lessons from past module rollouts

These are concrete pitfalls that have actually bitten this repo. Keep them on your radar.

- **The `gw_priority` decoy** - a prompt for the Grist module asked for a `com.docker.network.bridge.gateway_priority` label on the main container, citing Outline as the reference. Outline doesn't set that label; the priority comes from compose's `priority:` keys alone. Don't blindly add labels because a prompt suggests them - verify against the cited reference.
- **`${BASE_DOMAIN}` interpolation** - the Grist `stack.env` was initially written with hardcoded `igor.voronin@my.world`; the user manually rewrote it to `igor.voronin@${BASE_DOMAIN}`. Then the `stack.env.example` got rewritten the same way and additionally had its `BASE_DOMAIN` flipped to `example.com` (so the public-facing template doesn't leak the real homelab domain). Net rule: `stack.env` uses `BASE_DOMAIN=my.world`; `stack.env.example` uses `BASE_DOMAIN=example.com`; **every other domain reference in both files uses `${BASE_DOMAIN}` interpolation**.
- **PG18 + JIT** - Grist (TypeORM-based) disables JIT at the connection level since 1.5; this repo additionally pins `command: ["postgres", "-c", "jit=off"]` as a belt-and-suspenders against PG18's more aggressive JIT. Other TypeORM apps may need the same.
- **`.terraform.lock.hcl` is committed** - every existing module commits its lock file. Run `tofu init` so it gets generated, and let `git add` pick it up.
- **`*.tfvars` gitignore vs transcrypt** - discovered during the Grist rollout. The gitignore rule means edits to live tfvars are local-only unless you force-add (Portainer is the only module that does). Don't assume a tfvars change will reach the deploy machine through git.
- **Stale `external-resources/project.auto.tfvars.example`** - has historically lagged behind the live file. Don't backfill silently; mirror only your own additions unless asked to clean up.
- **Cert renewal & `docker compose config`** - the active Docker context points at a remote VM; if its client certs are stale, even `docker compose config` may fail. Ask the user to renew before deploy-adjacent commands rather than retrying blindly.
