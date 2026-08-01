/**
 * # Grist OIDC
 *
 * This module uses the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary `client_id` and `client_secret` to set up OIDC/OAuth in Grist with Zitadel.
 *
 * Grist is fully env-var driven; no post-boot API setup is required (unlike Portainer/Jellyfin). All OIDC config produced here flows into the module's `stack.env` via the `grist_oidc_env_vars` output.
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
module "grist_web_ui_oidc" {
  source = "../../../common/modules/oidc"

  org_name         = "Sanctum"
  project_name     = "Grist"
  application_name = "Grist Web UI"
  app_type         = "OIDC_APP_TYPE_WEB"
  auth_method_type = "OIDC_AUTH_METHOD_TYPE_BASIC"

  redirect_uris             = ["https://grist.${local.base_domain}/", "https://grist.${local.base_domain}/oauth2/callback"]
  response_types            = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types               = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  post_logout_redirect_uris = ["https://grist.${local.base_domain}/"]

  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true

  project_roles = {
    "grist_admin" = {
      display_name = "Grist admin"
      group        = "grist"
    }
  }

  user_grants = {
    "igor" = {
      user_name = "igor.voronin@${local.base_domain}"
      role_keys = ["grist_admin"]
    }
  }
}

# Snippet for the `stack.env` used by Grist's `docker-compose.yml`.
output "grist_oidc_env_vars" {
  description = "Copy and paste these into the `stack.env` file"
  value       = <<-EOT
    GRIST_OIDC_IDP_ISSUER=https://zitadel.${local.base_domain}
    GRIST_OIDC_IDP_CLIENT_ID=${module.grist_web_ui_oidc.client_id}
    GRIST_OIDC_IDP_CLIENT_SECRET=${module.grist_web_ui_oidc.client_secret}
    GRIST_OIDC_IDP_SCOPES=openid email profile
    GRIST_OIDC_SP_HOST=https://grist.${local.base_domain}
    GRIST_OIDC_IDP_ENABLED_PROTECTIONS=PKCE,STATE
  EOT
  sensitive   = true
}

# `client_id` for further use.
output "client_id" {
  description = "Grist Client ID"
  value       = module.grist_web_ui_oidc.client_id
  sensitive   = true
}

# `client_secret` for further use.
output "client_secret" {
  description = "Grist Client Secret"
  value       = module.grist_web_ui_oidc.client_secret
  sensitive   = true
}
