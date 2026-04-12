/**
 * # Outline OIDC
 *
 * This module uses the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary `client_id` and `client_secret` to set up OIDC/OAuth in Outline with Zitadel.
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
  base_domain   = "my.world"
}

# `zitadel` provider set up.
provider "zitadel" {
  domain           = "zitadel.${local.base_domain}"
  insecure         = "false"
  port             = "443"
  jwt_profile_file = "${path.module}/../../admin_key.json"
}

# Call to the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary resources in Zitadel.
module "outline_web_ui_oidc" {
  source = "../../../common/modules/oidc"

  org_name         = "Sanctum"
  project_name     = "Outline"
  application_name = "Outline Web UI"
  app_type         = "OIDC_APP_TYPE_WEB"
  auth_method_type = "OIDC_AUTH_METHOD_TYPE_BASIC"

  redirect_uris             = ["https://outline.${local.base_domain}/", "https://outline.${local.base_domain}/auth/oidc.callback"]
  response_types            = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types               = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  post_logout_redirect_uris = ["https://outline.${local.base_domain}/"]

  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true

  project_roles = {
    "outline_admin" = {
      display_name = "Outline admin"
      group        = "outline"
    }
  }

  user_grants = {
    "igor" = {
      user_name = "igor.voronin@${local.base_domain}"
      role_keys = ["outline_admin"]
    }
  }
}

# Snippet for the `stack.env` used by Outline's `docker-compose.yml`.
output "outline_oidc_env_vars" {
  description = "Copy and paste these into the `stack.env` file"
  value       = <<-EOT
    OIDC_CLIENT_ID=${module.outline_web_ui_oidc.client_id}
    OIDC_CLIENT_SECRET=${module.outline_web_ui_oidc.client_secret}
    OIDC_AUTH_URI=https://zitadel.${local.base_domain}/oauth/v2/authorize
    OIDC_TOKEN_URI=https://zitadel.${local.base_domain}/oauth/v2/token
    OIDC_USERINFO_URI=https://zitadel.${local.base_domain}/oidc/v1/userinfo
    OIDC_LOGOUT_URI=https://zitadel.${local.base_domain}/oidc/v1/end_session?post_logout_redirect_uri=https://outline.${local.base_domain}/
    OIDC_SCOPES=openid profile email
  EOT
  sensitive = true
}

# `client_id` for further use.
output "client_id" {
  description = "Outline Client ID"
  value       = module.outline_web_ui_oidc.client_id
  sensitive   = true
}

# `client_secret` for further use.
output "client_secret" {
  description = "Outline Client ID"
  value       = module.outline_web_ui_oidc.client_secret
  sensitive   = true
}
