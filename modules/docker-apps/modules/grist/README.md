# Grist OIDC

This module uses the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary `client_id` and `client_secret` to set up OIDC/OAuth in Grist with Zitadel.

Grist is fully env-var driven; no post-boot API setup is required (unlike Portainer/Jellyfin). All OIDC config produced here flows into the module's `stack.env` via the `grist_oidc_env_vars` output.

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Modules](#modules) _(nested and adjacent)_
  - [grist_web_ui_oidc](#grist_web_ui_oidc)
- [Variables](#variables)
- [Outputs](#outputs)
  - [client_id](#client_id)
  - [client_secret](#client_secret)
  - [grist_oidc_env_vars](#grist_oidc_env_vars)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![zitadel](https://img.shields.io/badge/zitadel->=2.5.0-ee4398?logo=zitadel)

## Modules
  
<blockquote><!-- module:"grist_web_ui_oidc":start -->

### `grist_web_ui_oidc`

Call to the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary resources in Zitadel.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>../../../common/modules/oidc</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L34"><code>main.tf#L34</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="../../../common/modules/oidc/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"grist_web_ui_oidc":end -->

## Outputs
  
<blockquote><!-- output:"client_id":start -->

#### `client_id`

Grist Client ID

In file: <a href="./main.tf#L84"><code>main.tf#L84</code></a>
</blockquote><!-- output:"client_id":end -->
<blockquote><!-- output:"client_secret":start -->

#### `client_secret`

Grist Client Secret

In file: <a href="./main.tf#L91"><code>main.tf#L91</code></a>
</blockquote><!-- output:"client_secret":end -->
<blockquote><!-- output:"grist_oidc_env_vars":start -->

#### `grist_oidc_env_vars`

Copy and paste these into the `stack.env` file

In file: <a href="./main.tf#L69"><code>main.tf#L69</code></a>
</blockquote><!-- output:"grist_oidc_env_vars":end -->

## Notes

- **OIDC callback URL** registered with Zitadel: `https://grist.my.world/oauth2/callback` (Grist's documented default).
- **Postgres image** is `postgres:18-alpine` with `jit=off` forced via `command:`. Grist publishes no official Postgres compatibility matrix; if `grist` fails to start with TypeORM/schema errors, revert to `postgres:16-alpine` AND `docker volume rm grist-db-data` so a fresh cluster is initialized at the older version.
- **Redis sidecar** (`grist-redis`) provides queues/webhooks support - required for production-grade webhooks and recommended even for single-instance deployments.
- **Persistent data** lives at `/persist` inside the container (Grist's documented dir, mapped to the `grist-data` external volume).
- **Multi-org mode**: `GRIST_SINGLE_ORG` is intentionally unset, so URLs include `/o/<orgslug>/`. This preserves the option to carve out separate orgs later (e.g. `sanctum-project`, `sanctum-family`); a single org with multiple workspaces is also viable inside the default personal org. Set `GRIST_SINGLE_ORG=<slug>` in `stack.env` and redeploy to switch to single-org mode.
- **gVisor sandbox** (`GRIST_SANDBOX_FLAVOR=gvisor`) is bundled inside the official image but the host must support it. TODO: verify gVisor runs on the Flatcar VM; if not, set `GRIST_SANDBOX_FLAVOR=unsandboxed`.
- **SSO is the only auth path** while `GRIST_OIDC_IDP_ISSUER` is set - Grist has no documented way to run built-in login in parallel with OIDC. If Zitadel becomes unreachable, comment out the `GRIST_OIDC_*` lines in `stack.env`, `docker compose up -d`, log in via Grist's built-in form as `GRIST_DEFAULT_EMAIL`, then restore OIDC config once Zitadel is healthy.
- **No `project.auto.tfvars`** is needed for this module - no Terraform variables are declared (matches the Outline module).

## Prerequisites

The following Docker resources must exist on the target Docker VM (registered in the [external-resources](../external-resources/) module):

- networks: `services-network`, `grist-network`
- volumes: `grist-data`, `grist-db-data`

The Zitadel admin service-account key must be present at `modules/docker-apps/admin_key.json`.

## Usage

Run Terraform first to create the Zitadel project/application, then deploy the stack:

```bash
$ tofu init
$ tofu apply -show-sensitive
# Copy the `grist_oidc_env_vars` output into stack.env (or paste the client_id /
# client_secret lines into the OIDC section).
$ docker compose -f ./docker-compose.yml --env-file ./stack.env up -d
```

Open `https://grist.my.world/` and log in via Zitadel as `igor.voronin@my.world` (matches `GRIST_DEFAULT_EMAIL`, so this account becomes admin on first login).
