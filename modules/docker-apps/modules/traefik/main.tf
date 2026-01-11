/**
 * # Traefik dashboard OIDC
 *
 * This module uses the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary `client_id` to set up OIDC/OAuth for Traefik (dashboard) with Zitadel.
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

# `zitadel` provider set up.
provider "zitadel" {
  domain           = "zitadel.my.world"
  insecure         = "false"
  port             = "443"
  jwt_profile_file = "${path.module}/../../admin_key.json"
}

# Call to the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary resources in Zitadel.
module "traefik_dashboard_oidc" {
  source = "../../../common/modules/oidc"

  org_name         = "Sanctum"
  project_name     = "Traefik"
  application_name = "Traefik Dashboard"
  app_type         = "OIDC_APP_TYPE_WEB"
  auth_method_type = "OIDC_AUTH_METHOD_TYPE_NONE"

  redirect_uris             = ["https://traefik.my.world/oidc/callback"]
  response_types            = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types               = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  post_logout_redirect_uris = ["https://traefik.my.world/oidc/logout"]

  project_roles = {
    "traefik_admin" = {
      display_name = "Traefik admin"
      group        = "traefik"
    }
  }

  user_grants = {
    "igor" = {
      user_name = "igor.voronin@my.world"
      role_keys = ["traefik_admin"]
    }
  }
}

# `client_id` for further use.
output "client_id" {
  description = "Traefik Client ID"
  value       = module.traefik_dashboard_oidc.client_id
  sensitive   = true
}