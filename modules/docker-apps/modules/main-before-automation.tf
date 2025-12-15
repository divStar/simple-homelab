/**
 * # Jellyfin Web UI OIDC
 *
 * This module uses the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary `client_id` to set up OIDC/OAuth for Jellyfin (dashboard) with Zitadel.
 */

# Terraform and provider setup.
terraform {
  required_version = ">= 1.10.5"

  required_providers {
    zitadel = {
      source  = "zitadel/zitadel"
      version = ">= 2.3.0"
    }
    restapi = {
      source  = "mastercard/restapi"
      version = ">= 2.0.1"
    }
  }
}

locals {
  base_domain = regex("BASE_DOMAIN\\s*=\\s*(\\S+)", file("${path.module}/stack.env"))[0]
}

variable "jellyfin_api_key" {
  description = "API key to use to access the Jellyfin API"
  type        = string
  sensitive   = true
  nullable    = false
}

# `zitadel` provider set up.
provider "zitadel" {
  domain           = "zitadel${local.base_domain}"
  insecure         = "false"
  port             = "443"
  jwt_profile_file = "${path.module}/../../admin_key.json"
}

# `restapi` provider set up.
provider "restapi" {
  uri                  = "https://portainer.${local.base_domain}"
  write_returns_object = true
  debug                = true

  headers = {
    "Content-Type" = "application/json"
  }
}

# Call to the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary resources in Zitadel.
module "jellyfin_web_ui_oidc" {
  source = "../../../common/modules/oidc"

  org_name         = "Sanctum"
  project_name     = "Jellyfin"
  application_name = "Jellyfin Web UI"
  app_type         = "OIDC_APP_TYPE_WEB"
  auth_method_type = "OIDC_AUTH_METHOD_TYPE_BASIC"

  redirect_uris             = ["https://jellyfin${local.base_domain}/sso/OID/redirect/zitadel"]
  response_types            = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types               = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  post_logout_redirect_uris = ["https://jellyfin${local.base_domain}"]

  project_roles = {
    "jellyfin_admin" : {
      display_name = "Jellyfin admin"
      group : "jellyfin"
    }
    # video folder
    "jellyfin_animated" : {
      display_name = "Jellyfin animated folder"
      group : "jellyfin"
    }
    "jellyfin_anime" : {
      display_name = "Jellyfin anime folder"
      group : "jellyfin"
    }
    "jellyfin_concerts" : {
      display_name = "Jellyfin concerts folder"
      group : "jellyfin"
    }
    "jellyfin_movies" : {
      display_name = "Jellyfin movies folder"
      group : "jellyfin"
    }
    "jellyfin_emovies" : {
      display_name = "Jellyfin e-movies folder"
      group : "jellyfin"
    }
    "jellyfin_rmovies" : {
      display_name = "Jellyfin Russian movies folder"
      group : "jellyfin"
    }
    "jellyfin_series" : {
      display_name = "Jellyfin TV series folder"
      group : "jellyfin"
    }
    # pictures folder
    "jellyfin_photos_igor" : {
      display_name = "Jellyfin Igor's photos folder"
      group : "jellyfin"
    }
    "jellyfin_photos_mariia" : {
      display_name = "Jellyfin Mariia's photos folder"
      group : "jellyfin"
    }
    "jellyfin_photos_yuliia" : {
      display_name = "Jellyfin Yuliia's photos folder"
      group : "jellyfin"
    }
    # music folder
    "jellyfin_music" : {
      display_name = "Jellyfin music folder"
      group : "jellyfin"
    }
    # yuliia folder
    "jellyfin_yuliia" : {
      display_name = "Jellyfin movies folder"
      group : "jellyfin"
    }
  }

  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true

  admin_user = "igor.voronin@${local.base_domain}"
}

resource "restapi_object" "jellyfin_sso" {
  depends_on = [module.jellyfin_web_ui_oidc]

  create_method = "PUT"
  path          = "/sso/OID/Add/zitadel"
  query_string  = "api_key=${var.jellyfin_api_key}"

  data = jsonencode({
    oidEndpoint         = "https://zitadel.my.world"
    oidClientId         = zitadel_application_oidc.jellyfin.client_id
    oidSecret           = zitadel_application_oidc.jellyfin.client_secret
    roleClaim           = "role"
    oidScopes           = ["openid", "profile", "email"]
    enabled             = true
    enableAuthorization = true
    enableAllFolders    = true # ✅ Give admin access to everything initially
    enabledFolders      = []
    adminRoles          = ["jellyfin-admin"]
    roles               = ["jellyfin-user"]
    enableFolderRoles   = false # ✅ Disabled initially
    folderRoleMapping   = []    # ✅ Empty for now
    schemeOverride      = "https"
  })

  object_id = "jellyfin_sso"
}

# `client_id` for further use.
output "client_id" {
  description = "Jellyfin Client ID"
  value       = module.jellyfin_dashboard_oidc.client_id
  sensitive   = true
}