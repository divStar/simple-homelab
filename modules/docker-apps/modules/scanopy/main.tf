/**
 * # Scanopy OIDC
 *
 * This module uses the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary `client_id` and `client_secret` to set up OIDC/OAuth in Scanopy with Zitadel.
 *
 * Scanopy's OIDC support supplements rather than replaces its own username/password login - users
 * link it to their existing account via Account Settings. Config is a mounted `oidc.toml` file
 * (fixed container path `/oidc.toml`), not env vars - Scanopy's own format, not ours.
 *
 * <!-- docs-meta: order=220 icon=scanopy -->
 */

# Terraform and provider setup.
terraform {
  required_version = ">= 1.10.5"

  required_providers {
    zitadel = {
      source  = "zitadel/zitadel"
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

# Call to the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary resources in Zitadel.
module "scanopy_web_ui_oidc" {
  source = "../../../common/modules/oidc"

  org_name         = "Sanctum"
  project_name     = "Scanopy"
  application_name = "Scanopy Web UI"
  app_type         = "OIDC_APP_TYPE_WEB"
  auth_method_type = "OIDC_AUTH_METHOD_TYPE_BASIC"

  redirect_uris             = ["https://topology.${local.base_domain}/api/auth/oidc/zitadel/callback"]
  response_types            = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types               = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  post_logout_redirect_uris = ["https://topology.${local.base_domain}/"]

  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = false
  id_token_role_assertion     = false
  id_token_userinfo_assertion = true

  # Scanopy itself has no role-claim mapping to use these for - this grant exists purely because
  # Zitadel's project_role_check defaults to true, so *some* role grant is required for anyone to
  # authenticate at all, regardless of whether the app does anything with the role name itself.
  project_roles = {
    "scanopy_user" = {
      display_name = "Scanopy user"
      group        = "scanopy"
    }
  }

  user_grants = {
    "igor" = {
      user_name = "igor.voronin@${local.base_domain}"
      role_keys = ["scanopy_user"]
    }
  }
}

# Snippet for this module's `oidc.toml` (see files/oidc.toml.example).
output "scanopy_oidc_toml" {
  description = "Copy and paste this into oidc.toml"
  value       = <<-EOT
    [[oidc_providers]]
    name = "Zitadel"
    slug = "zitadel"
    issuer_url = "https://zitadel.${local.base_domain}"
    client_id = "${module.scanopy_web_ui_oidc.client_id}"
    client_secret = "${module.scanopy_web_ui_oidc.client_secret}"
  EOT
  sensitive   = true
}

# `client_id` for further use.
output "client_id" {
  description = "Scanopy Client ID"
  value       = module.scanopy_web_ui_oidc.client_id
  sensitive   = true
}

# `client_secret` for further use.
output "client_secret" {
  description = "Scanopy Client Secret"
  value       = module.scanopy_web_ui_oidc.client_secret
  sensitive   = true
}
