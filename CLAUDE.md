# simple-homelab

Terraform/OpenTofu-managed infrastructure for the user's Proxmox homelab (host `sanctum`). Provisions LXC containers and VMs and their in-guest configuration directly via SSH — there is no separate configuration-management layer (no Ansible etc.), provisioning happens through `ssh_resource` blocks in the same Terraform run that creates the container.

## Tooling

- Use **`tofu`**, not `terraform` — this repo targets OpenTofu (`required_version >= 1.10.5`). Both binaries happen to be installed locally; always use `tofu`.
- Providers: `bpg/proxmox` (container/VM/download-file resources), `loafoe/ssh` (in-guest provisioning via SSH), `hashicorp/random`, `hashicorp/tls`.
- Docs are generated, not hand-written: `bash scripts/generate-docs.sh <module-path>` (wraps `terraform-docs`, config at `.terraform-docs.yml`). **Always regenerate after any `.tf` file change** — module READMEs should never drift from the actual code.
- `scripts/destroy-vmlxc.sh`, `scripts/upload-configs.sh`, `scripts/portainer-get-token.sh` exist for other workflows in this repo; not covered here.

## Module layout

```
modules/
├── common/modules/{alpine,debian}   # reusable base OS modules
├── host/                            # Proxmox host itself (packages, storage, users, ACME/repos)
├── samba/, step-ca/, pihole/        # single-purpose LXC service modules, each built on a base OS module
├── docker-vm/                       # Flatcar + Docker VM, hosts Traefik-fronted apps
├── docker-apps/                     # Portainer-managed docker-compose stacks that live on docker-vm
└── service-configs/                 # stack.env / docker-compose.yml per docker-apps service
```

### Base OS modules (`common/modules/{alpine,debian}`)

Each one: downloads an LXC template (`proxmox_virtual_environment_download_file`, pinned by URL + checksum), creates the container, installs OpenSSH via `pct exec` from the Proxmox host (fresh templates don't have it), installs a package list, sets up an OS-native recurring update mechanism, and pushes default shell aliases.

- **Alpine**: `apk` / OpenRC / cron. `update_interval` is a **cron expression**.
- **Debian**: `apt` / systemd. `update_interval` is a **systemd `OnCalendar` expression**, not cron — deliberately different formats between the two modules, matching each OS's native idiom rather than forcing one convention. Debian's own update job is a systemd timer (`debian-update.timer`/`.service`), not cron — cron was tried first, then deliberately dropped in favor of systemd since Debian isn't Alpine and already has it.
- Both output `root_password` and `ssh_private_key` (sensitive), used by the calling module to provision further.

When adding a third base OS: match this shape, but let the update mechanism be whatever's native to that OS, not a copy-paste of Alpine's or Debian's specific implementation.

### Service modules (`samba`, `step-ca`, `pihole`)

Each is a standalone root module: its own `providers.tf`, `variables.tf` (always includes a `proxmox` object var — `name/host/ssh_user/ssh_key/insecure/username/password`, `sensitive = true`), `outputs.tf` (`root_password`, `ssh_private_key`), `project.auto.tfvars` + `.example`, and a `main.tf` that calls a base OS module via `module "setup_container"` then layers service-specific `ssh_resource` provisioning on top.

**Known gap — fixed in `samba` (2026-08-04). `step-ca` and `pihole` are NOT in the same state as each other, verified 2026-08-04 - check which base module a service module actually uses before assuming scope:**
- **`step-ca`** uses `common/modules/alpine`, which already has both of tonight's fixes (the `proxmox_download_file` migration and the `container_id` output). `step-ca` only needs the smaller, service-module-level half: wrap `module.setup_container.container_id` in a `terraform_data` resource and add it to `replace_triggered_by` on its own `ssh_resource`s, same as `samba`'s `main.tf`.
- **`pihole`** uses `common/modules/debian`, which has **neither** fix yet - still on `proxmox_virtual_environment_download_file`, no `container_id` output at all. This is the bigger job: `debian` needs the same base-module work `alpine` got tonight (resource migration + new output) before `pihole`'s own main.tf can even be wired up the same way `step-ca`'s can.

Unchecked: `docker-vm`/`pbs-vm`, since those are VM-based and may not share this exact structure at all — verify before assuming either fix applies mechanically there.

A service module's `ssh_resource` provisioning steps (config push, account creation, etc.) are linked to their base container only via `depends_on`, which is ordering-only — it does *not* propagate replacement. If the container is ever destroyed and recreated (e.g. a template/image change forcing `must be replaced`), those `ssh_resource`s see no attribute change of their own and silently do **not** re-run against the fresh container — `tofu apply` reports success, but the new container ends up with no config on it. Confirmed via `tofu plan` while migrating `samba` off the deprecated `proxmox_virtual_environment_download_file`: the container correctly showed `must be replaced`, but `configure_samba`/`configure_users` showed zero diff until this was fixed.

Fix (reference implementation: `modules/samba/main.tf` + `modules/common/modules/alpine/outputs.tf`): the base OS module needs to export a `container_id` output (the container resource's own `id` — not useful for identifying the container, since callers already know `vm_id`, but its value goes to "known after apply" whenever the container is replaced, which is what actually matters here). Module outputs aren't valid `replace_triggered_by` references on their own though (only resources are, confirmed the hard way via a `tofu plan` error) — wrap it in a `terraform_data` resource first, same pattern the existing `users_trigger`-style triggers already use for other values, then add that `terraform_data`'s `.id` to every provisioning `ssh_resource`'s `lifecycle.replace_triggered_by` list, alongside whatever trigger(s) it already has.

**`proxmox.host` must be a hostname (e.g. `sanctum.my.world`), never the raw IP.** Proxmox's real TLS cert is issued via this repo's own Step CA for the hostname, not the IP — connecting via IP fails certificate validation (`x509: cannot validate certificate ... doesn't contain any IP SANs`). All working `project.auto.tfvars` files use the hostname; if you ever see an IP in one, that's a bug, not a valid alternative. (Side note: the cert doesn't lack an IP SAN by choice — Proxmox's built-in ACME client has a known bug, [Bugzilla #4687](https://bugzilla.proxmox.com/show_bug.cgi?id=4687), that mangles IP addresses into the DNS SAN field instead of the IP SAN field, referenced already in `modules/step-ca/files/setup-host.sh`. Not fixable from this repo's side.)

### tfvars and secrets

`*.tfvars` files show as gitignored (`.gitignore` lists them) but **are actually committed, encrypted** — `.gitattributes` has `*.tfvars filter=crypt diff=crypt merge=crypt` (transcrypt). The `.gitignore` entry only stops an accidental unencrypted `git add .`; real values are force-added and transparently encrypted at rest. Don't be surprised to find a real `project.auto.tfvars` sitting next to its `.example` twin — that's the intended setup, not a leak.

### Before ever deploying this fresh

Nothing here gets exercised again until an actual from-scratch deploy happens, which isn't imminent — so treat this as a pre-flight checklist for that day, not a standing task:
- Pinned template URLs/checksums (`alpine_image`, `debian_image` defaults) may be stale by then — verify against what Proxmox's `pveam available`/apl-info cache actually offers.
- `proxmox_virtual_environment_download_file` is deprecated in favor of `proxmox_download_file` (shows up as a warning on every `plan`/`apply` already, in both `alpine` and `debian`) — worth migrating *then*, since a fresh deploy is the one time a resource-type change (which likely forces recreating the container, given `template_file_id` is probably create-time-only) doesn't cost anything extra.
- Provider version constraints (`bpg/proxmox`, `loafoe/ssh`, etc.) may have newer releases worth bumping to at that point too.

## Working conventions in this repo

- **Always show a plan and get confirmation before `apply`** — even for single-resource changes. `tofu plan` first, walk through what's changing, then apply.
- **Never run `git add`/`commit`/`push`** unless explicitly asked — the user handles git themselves.
- Prefer changing a **shared default** (e.g. a base module's variable default) over adding a **per-consumer override**, when the override would just match the sensible default and there's only one consumer today.
- When a `ssh_resource`'s `commands` embeds a Terraform-interpolated value directly (e.g. `OnCalendar=${var.update_interval}`), changing that variable *will* re-diff and re-apply cleanly on the next `tofu apply`. When a `ssh_resource` only references a *file* via `file { source = ... }`, changing that file's content on disk does **not** get picked up by a future `apply` — the provider doesn't appear to track file content as a diffable attribute. Propagating a source-file change to an already-applied resource means pushing/re-running it manually over SSH; don't assume `tofu apply` alone will do it.
- Before assuming a Pi-hole/Debian/systemd behavior (unattended-install flags, restart-after-update behavior, config defaults), check the actual installed version's source on the live box (`ssh <host> "cat /path/to/script"`) rather than trust general knowledge or a secondhand summary — this repo's history includes at least one case where that secondhand-summary approach was wrong (`PIHOLE_SKIP_OS_CHECK` necessity) and one where an initial primary-source check missed something a deeper search found (the same flag, and separately the `pi.hole` cert SAN requirement).

## Design decisions worth knowing before changing the `pihole` module

- **"Seed once, UI is source of truth"**: `files/pihole.toml` is pushed once at container creation. Local DNS records, CNAME records, theme, NTP settings, etc. all live in that one-time seed; further changes go through Pi-hole's own web UI/CLI, not Terraform. The one deliberate exception is `upstream_dns` (a real tfvar, applied via a separate `pihole-FTL --config dns.upstreams` resource) since the user specifically wants that one to stay a one-line Terraform-adjustable lever.
- **TLS via Step CA, not Traefik/Let's Encrypt** — adapted from `docker-vm`'s own pattern (see `modules/docker-vm/files/docker-cert.config.yaml.tftpl` for the original this was based on). `step` CLI installed as a static binary (not an apt package), trust bootstrapped via the CA's `/roots.pem` fingerprint, cert requested via `step ca certificate` with a provisioner, renewed on a 12h systemd timer (Step CA issues 24h-lived certs). Cert issuance happens *before* Pi-hole is installed, so the seed config can declare HTTPS-only (`webserver.port = "443os"`, no port 80 at all) from the very first boot. SAN list must include `pi.hole` specifically (Pi-hole's own hardcoded `webserver.domain` default) alongside the real hostname/FQDN/IP, or Pi-hole logs a cert-mismatch warning even though normal access still works.
- Unprivileged LXC containers can't get `CAP_SYS_TIME` — Pi-hole's own NTP client fails trying to adjust the clock. Harmless (LXC shares the host's kernel clock directly, nothing to actually adjust), fixed by disabling `ntp.ipv4.active`/`ntp.ipv6.active`/`ntp.sync.active` in the seed config rather than granting the capability.
- Pi-hole's unattended installer needs a pre-existing `pihole.toml` to actually skip prompts (a documented upstream quirk, not obvious from the flag name), and does *not* run gravity (`pihole -g`) itself even though it sets up the weekly auto-refresh cron job — both are why gravity is run as an explicit one-time step after install.
