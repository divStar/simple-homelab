/**
 * # Homarr OIDC
 *
 * This module uses the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary `client_id` and `client_secret` to set up OIDC/OAuth in Homarr with Zitadel.
 *
 * Homarr is fully env-var driven; no post-boot API setup is required (unlike Portainer/Jellyfin). All OIDC config produced here flows into the module's `stack.env` via the `homarr_oidc_env_vars` output.
 *
 * Only the initial admin user (`igor.voronin@my.world`) is granted a role here. Any other user's group membership (`homarr_admin` / `homarr_user`) is managed by hand in the Zitadel console, not in Terraform.
 *
 * ## Notes
 *
 * - Storage is SQLite, not Postgres - no sidecar DB needed.
 * - Docker socket mounted `:ro` (read-only stats widget); not a real isolation boundary, fine since nothing here is internet-facing.
 * - `AUTH_PROVIDERS=oidc,credentials` keeps local login as a fallback.
 * - `AUTH_OIDC_TOKEN_ENDPOINT_AUTH_METHOD=client_secret_basic` matches `OIDC_AUTH_METHOD_TYPE_BASIC` below - switch both to POST if login fails.
 * - Board access is per-board, not per-tile. Admin/family/anonymous split needs 3 boards created by hand, each group's default board set in Homarr's UI.
 * - `AUTH_OIDC_GROUPS_ATTRIBUTE=roles`, not `groups` - Zitadel's shared `flatRoles` Action (also used by Prometheus/Alloy's Traefik middleware, don't change it) writes to a `roles` claim. Its own doc comment claims `"{projectId}:{roleName}"` format, but verified by testing: the actual value is the bare role key (e.g. `homarr_admin`) - Homarr's group name must match that, not the prefixed form.
 * - `zitadel` provider resolved to v3.4.0 here (others are on `2.12.7`) - has a real diff on `zitadel_application_oidc` (`org_id` forces replacement) on subsequent plans; don't `apply` untargeted or it'll rotate the OIDC client secret.
 * - Homarr trusts integration certs via its own `/appdata/trusted-certificates` store, separate from `NODE_EXTRA_CA_CERTS`. Only the Root CA is needed (Traefik sends the Intermediate itself). Fetched via `data.http.sanctum_root_ca`, pushed to the Docker VM with `scripts/upload-configs.sh --dest /mnt/data/step-ca --input modules/docker-apps/modules/homarr/files`.
 * - Proxmox integration uses its own read-only `homarr@pve` / `PVEAuditor` API user+token via `bpg/proxmox`, modeled on `modules/host/modules/terraform-user`. Paste `homarr_proxmox_integration` output into Homarr's integration form.
 *
 * <!-- docs-meta: order=230 icon=homarr -->
 */

# Terraform and provider setup.
terraform {
  required_version = ">= 1.10.5"

  required_providers {
    zitadel = {
      source  = "zitadel/zitadel"
      version = ">= 2.5.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.111.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.9.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.0"
    }
  }
}

locals {
  base_domain = "my.world"
}

# `zitadel` provider set up.
provider "zitadel" {
  domain           = "zitadel.${local.base_domain}"
  insecure         = "false"
  port             = "443"
  jwt_profile_file = "${path.module}/../../admin_key.json"
}

# `proxmox` provider set up - used only for the read-only Proxmox integration user/token below,
# no SSH-based provisioning needed here.
provider "proxmox" {
  endpoint = "https://${var.proxmox.host}:8006/"
  insecure = var.proxmox.insecure
  username = var.proxmox.username
  password = var.proxmox.password
}

# Call to the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary resources in Zitadel.
module "homarr_web_ui_oidc" {
  source = "../../../common/modules/oidc"

  org_name         = "Sanctum"
  project_name     = "Homarr"
  application_name = "Homarr Web UI"
  app_type         = "OIDC_APP_TYPE_WEB"
  auth_method_type = "OIDC_AUTH_METHOD_TYPE_BASIC"

  redirect_uris             = ["https://homarr.${local.base_domain}/", "https://homarr.${local.base_domain}/api/auth/callback/oidc"]
  response_types            = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types               = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  post_logout_redirect_uris = ["https://homarr.${local.base_domain}/"]

  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true

  # Only the two roles are declared here. Assigning further users/groups to
  # either role happens by hand in the Zitadel console, not in Terraform.
  project_roles = {
    "homarr_admin" = {
      display_name = "Homarr admin"
      group        = "homarr"
    }
    "homarr_user" = {
      display_name = "Homarr user"
      group        = "homarr"
    }
  }

  user_grants = {
    "igor" = {
      user_name = "igor.voronin@${local.base_domain}"
      role_keys = ["homarr_admin"]
    }
  }
}

# Read-only Proxmox API user for Homarr's Proxmox integration widget.
# Modeled on `modules/host/modules/terraform-user`'s shape, via `bpg/proxmox` resources instead
# of `pveum` over SSH. `PVEAuditor` is a built-in role - no custom role resource needed.
resource "proxmox_virtual_environment_group" "homarr_api" {
  group_id = "homarr"
  comment  = "Homarr's Proxmox integration"
}

# Required by the `pve` realm even though only the token below is actually used for auth.
resource "random_password" "homarr_proxmox_user" {
  length  = 32
  special = false
}

resource "proxmox_virtual_environment_user" "homarr_api" {
  user_id  = "homarr@pve"
  comment  = "Homarr Proxmox integration (read-only)"
  password = random_password.homarr_proxmox_user.result
  groups   = [proxmox_virtual_environment_group.homarr_api.group_id]
}

resource "proxmox_acl" "homarr_api_group" {
  group_id  = proxmox_virtual_environment_group.homarr_api.group_id
  role_id   = "PVEAuditor"
  path      = "/"
  propagate = true
}

resource "proxmox_user_token" "homarr" {
  user_id               = proxmox_virtual_environment_user.homarr_api.user_id
  token_name            = "homarr"
  comment               = "Homarr integration token"
  privileges_separation = false
}

resource "proxmox_acl" "homarr_api_token" {
  token_id  = proxmox_user_token.homarr.id
  role_id   = "PVEAuditor"
  path      = "/"
  propagate = true
}

# Fetches the Sanctum Root CA (insecurely, trust-on-first-use - same pattern as `pihole`'s
# `install-step.sh`/`pbs-lxc`'s `setup-acme.sh`) so it can be pushed onto the Docker VM for
# Homarr's own `/appdata/trusted-certificates` store (see main docblock Notes).
data "http" "sanctum_root_ca" {
  url      = "https://step-ca.${local.base_domain}/roots.pem"
  insecure = true
}

resource "local_file" "sanctum_root_ca" {
  content  = data.http.sanctum_root_ca.response_body
  filename = "${path.module}/files/sanctum-root-ca.crt"
}

# Snippet for the `stack.env` used by Homarr's `docker-compose.yml`.
output "homarr_oidc_env_vars" {
  description = "Copy and paste these into the `stack.env` file"
  value       = <<-EOT
    AUTH_OIDC_ISSUER=https://zitadel.${local.base_domain}
    AUTH_OIDC_CLIENT_ID=${module.homarr_web_ui_oidc.client_id}
    AUTH_OIDC_CLIENT_SECRET=${module.homarr_web_ui_oidc.client_secret}
    AUTH_OIDC_CLIENT_NAME=Zitadel
    AUTH_OIDC_GROUPS_ATTRIBUTE=roles
    AUTH_OIDC_TOKEN_ENDPOINT_AUTH_METHOD=client_secret_basic
  EOT
  sensitive   = true
}

# `client_id` for further use.
output "client_id" {
  description = "Homarr Client ID"
  value       = module.homarr_web_ui_oidc.client_id
  sensitive   = true
}

# `client_secret` for further use.
output "client_secret" {
  description = "Homarr Client Secret"
  value       = module.homarr_web_ui_oidc.client_secret
  sensitive   = true
}

# Paste these into Homarr's Proxmox integration form (Settings -> Integrations -> Proxmox).
output "homarr_proxmox_integration" {
  description = "Proxmox integration credentials for Homarr's UI (Username / Realm / Token ID / API Key)"
  value       = <<-EOT
    Username: homarr
    Realm: pve
    Token ID: homarr
    API Key: ${element(split("=", proxmox_user_token.homarr.value), 1)}
  EOT
  sensitive   = true
}
