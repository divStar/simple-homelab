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

  device_id = "terraform-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  # access_token = jsondecode(restapi_object.jellyfin_auth.api_response).AccessToken

  roles = {
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
      display_name = "Jellyfin Yuliia folder"
      group : "jellyfin"
    }
  }
}

variable "admin_username" {
  description = "Admin username for Jellyfin initial setup"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Admin password for Jellyfin initial setup"
  type        = string
  sensitive   = true
}

# `zitadel` provider set up.
provider "zitadel" {
  domain           = "zitadel.${local.base_domain}"
  insecure         = "false"
  port             = "443"
  jwt_profile_file = "${path.module}/../../admin_key.json"
}

# # `restapi` provider set up for Jellyfin API
# provider "restapi" {
#   alias                = "basic"
#   uri                  = "https://jellyfin.${local.base_domain}"
#   write_returns_object = false
#   debug                = true
#   create_method = "POST"

#   headers = {
#     "Content-Type" = "application/json"
#     "Authorization" = "MediaBrowser Client=\"Terraform\", Device=\"Automation\", DeviceId=\"${local.device_id}\", Version=\"1.0.0\""
#   }
# }

# # `restapi` provider set up for Jellyfin API (with access token)
# provider "restapi" {
#   alias                = "access_token"
#   uri                  = "https://jellyfin.${local.base_domain}"
#   write_returns_object = false
#   debug                = true
#   create_method = "POST"

#   headers = {
#     "Content-Type" = "application/json"
#     "Authorization" = "MediaBrowser Client=\"Terraform\", Device=\"Automation\", DeviceId=\"${local.device_id}\", Version=\"1.0.0\", Token=\"${local.access_token}\""
#   }
# }

# Call to the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary resources in Zitadel.
module "jellyfin_web_ui_oidc" {
  source = "../../../common/modules/oidc"

  org_name         = "Sanctum"
  project_name     = "Jellyfin"
  application_name = "Jellyfin Web UI"
  app_type         = "OIDC_APP_TYPE_WEB"
  auth_method_type = "OIDC_AUTH_METHOD_TYPE_BASIC"

  redirect_uris             = ["https://jellyfin.${local.base_domain}/sso/OID/redirect/zitadel"]
  response_types            = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types               = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  post_logout_redirect_uris = ["https://jellyfin.${local.base_domain}"]

  project_roles = local.roles

  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true

  admin_user = "igor.voronin@${local.base_domain}"
}

# # Create the initial admin user (no auth required during wizard)
# resource "restapi_object" "jellyfin_startup_user" {
#   provider = restapi.basic

#   path          = "/Startup/User"
#   data = jsonencode({
#     Name     = var.admin_username
#     Password = var.admin_password
#   })

#   # This endpoint returns 204 with no body
#   object_id    = "startup_user"
# }

# # Mark the wizard as complete (no auth required during wizard)
# resource "restapi_object" "jellyfin_complete_wizard" {
#   provider   = restapi.basic
#   depends_on = [restapi_object.jellyfin_startup_user]

#   path          = "/Startup/Complete"
#   data = "{}" # Empty body

#   object_id    = "wizard_complete"
# }

# # Authenticate to get an access token
# resource "restapi_object" "jellyfin_auth" {
#   provider   = restapi.basic
#   depends_on = [restapi_object.jellyfin_complete_wizard]

#   path          = "/Users/AuthenticateByName"
#   data = jsonencode({
#     Username = var.admin_username
#     Pw       = var.admin_password
#   })

#   # The response contains AccessToken in the body
#   object_id    = "auth"
# }

# # Install the DLNA plugin
# resource "restapi_object" "jellyfin_install_dlna_plugin" {
#   provider   = restapi.access_token

#   path          = "/Packages/Installed/DLNA"
#   query_string = "assemblyGuid=33eba9cd-7da1-4720-967f-dd7dae7b74a1&repositoryUrl=https://repo.jellyfin.org/releases/plugin/manifest.json"
#   data = "{}" # Empty body for installation

#   # Installation returns 204, so we use the plugin name as ID
#   object_id    = "dlna_plugin"
# }

# # Install the SSO Authentication plugin
# resource "restapi_object" "jellyfin_install_sso_plugin" {
#   provider   = restapi.access_token

#   path          = "/Packages/Installed/SSO Authentication"
#   query_string = "assemblyGuid=505ce9d1-d916-42fa-86ca-673ef241d7df&repositoryUrl=https://raw.githubusercontent.com/9p4/jellyfin-plugin-sso/manifest-release/manifest.json"
#   data = "{}" # Empty body for installation

#   # Installation returns 204, so we use the plugin name as ID
#   object_id    = "sso_plugin"
# }

# # Configure the SSO plugin with Zitadel OIDC details
# resource "restapi_object" "jellyfin_sso" {
#   provider   = restapi.access_token
#   depends_on = [module.jellyfin_web_ui_oidc,restapi_object.jellyfin_install_sso_plugin]

#   create_method = "PUT"
#   path          = "/sso/OID/Add/zitadel"

#   data = jsonencode({
#     oidEndpoint         = "https://zitadel.${local.base_domain}"
#     oidClientId         = module.jellyfin_web_ui_oidc.client_id
#     oidSecret           = module.jellyfin_web_ui_oidc.client_secret
#     oidScopes           = ["openid", "profile", "email", "roles"]
#     enabled             = true
#     enableAuthorization = true
#     enableFolderRoles   = true
#     enableAllFolders    = true # change to false as soon as enabledFolders + create libraries has been figured out
#     enabledFolders      = []
#     adminRoles          = ["jellyfin-admin"]
#     roles               = keys(local.roles)
#     roleClaim           = "roles"
#     folderRoleMapping   = []
#     schemeOverride      = "https"
#   })

#   object_id = "jellyfin_sso"
# }

# `client_id` for further use.
output "client_id" {
  description = "Jellyfin Client ID"
  value       = module.jellyfin_web_ui_oidc.client_id
  sensitive   = true
}

# admin user name
# output "jellyfin_admin_user_id" {
#   description = "Jellyfin Admin User ID"
#   value       = jsondecode(restapi_object.jellyfin_auth.api_response).User.Id
# }
