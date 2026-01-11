/**
 * # Jellyfin Web UI OIDC
 *
 * This module uses the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary `client_id`
 * to set up OIDC/OAuth for Jellyfin (dashboard) with Zitadel.
 */

# Terraform and provider setup.
terraform {
  required_version = ">= 1.10.5"

  required_providers {
    zitadel = {
      source  = "zitadel/zitadel"
      version = ">= 2.5.0"
    }
    terracurl = {
      source  = "devops-rob/terracurl"
      version = ">= 1.2.1"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.13.1"
    }
  }
}

locals {
  base_domain = regex("BASE_DOMAIN\\s*=\\s*(\\S+)", file("${path.module}/stack.env"))[0]

  # Startup configuration values
  jellyfin_server_name             = "sanctum-jellyfin"
  jellyfin_ui_culture              = "en-US"
  jellyfin_metadata_country_code   = "DE"
  jellyfin_preferred_metadata_lang = "de"

  # Base MediaBrowser auth header (without token)
  # IMPORTANT: Use a static DeviceId for reproducibility across runs
  base_auth_header = "MediaBrowser Client=\"Terraform\", Device=\"Terraform\", DeviceId=\"terraform-jellyfin-setup\", Version=\"1.0.0\""

  # Set access token and create authentication header (depends on the jellyfin_auth resource)
  access_token              = jsondecode(terracurl_request.jellyfin_auth.response).AccessToken
  authenticated_auth_header = "${local.base_auth_header}, Token=\"${local.access_token}\""

  # Generate library-specific roles
  library_roles = {
    for key, lib in var.libraries : "library-${key}" => {
      display_name = lib.display_name
      group        = lib.group
    }
  }

  # Static admin/user roles
  static_roles = {
    "jellyfin-admin" = {
      display_name = "Jellyfin Administrator"
      group        = "admin"
    }
    "jellyfin-user" = {
      display_name = "Jellyfin User"
      group        = "user"
    }
  }

  # Combine all roles
  roles = merge(local.static_roles, local.library_roles)

  # Parse library response and build folder role mapping (must be after jellyfin_get_libraries resource)
  jellyfin_libraries_response = jsondecode(terracurl_request.jellyfin_get_libraries.response)

  library_id_map = {
    for item in local.jellyfin_libraries_response :
    item.Name => item.ItemId
  }

  folder_role_mapping = [
    for key, lib in var.libraries : {
      role    = "library-${key}"
      folders = [local.library_id_map[lib.display_name]]
    }
  ]
}

# `zitadel` provider set up.
provider "zitadel" {
  domain           = "zitadel.${local.base_domain}"
  insecure         = "false"
  port             = "443"
  jwt_profile_file = "${path.module}/../../admin_key.json"
}

# ==============================================================================
# JELLYFIN STARTUP WIZARD
# ==============================================================================
# IMPORTANT: The wizard must be executed in this exact order:
#   1. POST /Startup/Configuration - Set server settings
#   2. GET  /Startup/User          - This creates the initial user internally!
#   3. POST /Startup/User          - Set username and password for that user
#   4. POST /Startup/Complete      - Finish the wizard
#
# The GET /Startup/User step is REQUIRED - without it, POST /Startup/User
# returns 401 because no user exists yet. Yes, the GET has a side effect.
# ==============================================================================

# Step 1: Set initial server configuration
resource "terracurl_request" "jellyfin_startup_configuration" {
  name   = "jellyfin_startup_configuration"
  url    = "https://jellyfin.${local.base_domain}/Startup/Configuration"
  method = "POST"

  headers = {
    "Content-Type"  = "application/json"
    "Authorization" = local.base_auth_header
  }

  request_body = jsonencode({
    UICulture                 = local.jellyfin_ui_culture
    MetadataCountryCode       = local.jellyfin_metadata_country_code
    PreferredMetadataLanguage = local.jellyfin_preferred_metadata_lang
    ServerName                = local.jellyfin_server_name
  })

  response_codes = [204]
}

# Step 2: GET the startup user (this creates the initial user internally!)
resource "terracurl_request" "jellyfin_get_startup_user" {
  depends_on = [terracurl_request.jellyfin_startup_configuration]

  name   = "jellyfin_get_startup_user"
  url    = "https://jellyfin.${local.base_domain}/Startup/User"
  method = "GET"

  headers = {
    "Content-Type"  = "application/json"
    "Authorization" = local.base_auth_header
  }

  response_codes = [200]
}

# Step 3: Set the admin username and password
resource "terracurl_request" "jellyfin_startup_user" {
  depends_on = [terracurl_request.jellyfin_get_startup_user]

  name   = "jellyfin_startup_user"
  url    = "https://jellyfin.${local.base_domain}/Startup/User"
  method = "POST"

  headers = {
    "Content-Type"  = "application/json"
    "Authorization" = local.base_auth_header
  }

  request_body = jsonencode({
    Name     = var.admin_username
    Password = var.admin_password
  })

  response_codes = [204]
}

# Step 4: Complete the startup wizard
resource "terracurl_request" "jellyfin_complete_wizard" {
  depends_on = [terracurl_request.jellyfin_startup_user]

  name   = "jellyfin_complete_wizard"
  url    = "https://jellyfin.${local.base_domain}/Startup/Complete"
  method = "POST"

  headers = {
    "Content-Type"  = "application/json"
    "Authorization" = local.base_auth_header
  }

  request_body = "{}"

  response_codes = [204]
}

# ==============================================================================
# POST-WIZARD SETUP (requires authentication)
# ==============================================================================

# Authenticate to get an access token
resource "terracurl_request" "jellyfin_auth" {
  depends_on = [terracurl_request.jellyfin_complete_wizard]

  name   = "jellyfin_auth"
  url    = "https://jellyfin.${local.base_domain}/Users/AuthenticateByName"
  method = "POST"

  headers = {
    "Content-Type"  = "application/json"
    "Authorization" = local.base_auth_header
  }

  request_body = jsonencode({
    Username = var.admin_username
    Pw       = var.admin_password
  })

  response_codes = [200]
}

# Setup Jellyfin plugin repositories
resource "terracurl_request" "jellyfin_setup_plugin_repositories" {
  depends_on = [terracurl_request.jellyfin_auth]

  name   = "jellyfin_setup_plugin_repositories"
  url    = "https://jellyfin.${local.base_domain}/Repositories"
  method = "POST"

  headers = {
    "Content-Type"  = "application/json"
    "Authorization" = local.authenticated_auth_header
  }

  request_body = jsonencode(var.plugin_repositories)

  response_codes = [204]
}

# Install Jellyfin plugins
resource "terracurl_request" "jellyfin_install_plugins" {
  depends_on = [terracurl_request.jellyfin_setup_plugin_repositories]

  for_each = var.plugins

  name   = "jellyfin_install_plugin_${each.key}"
  url    = "https://jellyfin.${local.base_domain}/Packages/Installed/${urlencode(each.value.name)}?assemblyGuid=${each.value.assembly_guid}&repositoryUrl=${urlencode(each.value.repository)}"
  method = "POST"

  headers = {
    "Content-Type"  = "application/json"
    "Authorization" = local.authenticated_auth_header
  }

  request_body = "{}"

  response_codes = [204]
}

# ==============================================================================
# LIBRARY CREATION WITH OPTIONS
# ==============================================================================
# The POST /Library/VirtualFolders endpoint accepts LibraryOptions in the body.
# We look up the options_category from the library definition in variables.tf.
# ==============================================================================

resource "terracurl_request" "jellyfin_libraries" {
  depends_on = [terracurl_request.jellyfin_install_plugins]
  for_each = var.libraries

  name   = "jellyfin_library_${each.key}"

  method = "POST"
  url    = "https://jellyfin.${local.base_domain}/Library/VirtualFolders?name=${urlencode(each.value.display_name)}&collectionType=${each.value.collection_type}&refreshLibrary=false"
  headers = {
    "Content-Type"  = "application/json"
    "Authorization" = local.authenticated_auth_header
  }
  # Look up options_category from the library definition
  request_body = jsonencode({
    LibraryOptions = merge(
      var.library_options_templates[each.value.options_category],
      {
        PathInfos                 = [{ Path = each.value.path }]
        PreferredMetadataLanguage = local.jellyfin_preferred_metadata_lang
        MetadataCountryCode       = local.jellyfin_metadata_country_code
      }
    )
  })
  response_codes = [204]

  # Destroy configuration
  destroy_method = "DELETE"
  destroy_url    = "https://jellyfin.${local.base_domain}/Library/VirtualFolders?name=${urlencode(each.value.display_name)}&refreshLibrary=false"
  destroy_headers = {
    "Content-Type"  = "application/json"
    "Authorization" = local.authenticated_auth_header
  }
  destroy_response_codes = [204]
}

# Restart Jellyfin
resource "terracurl_request" "jellyfin_restart_issued" {
  depends_on = [terracurl_request.jellyfin_libraries]

  name   = "jellyfin_restart_issued"

  method = "POST"
  url    = "https://jellyfin.${local.base_domain}/System/Restart"
  headers = {
    "Content-Type"  = "application/json"
    "Authorization" = local.authenticated_auth_header
  }
  # Look up options_category from the library definition
  request_body = "{}"
  response_codes = [204]
}

resource "time_sleep" "jellyfin_restart_completed" {
  depends_on = [terracurl_request.jellyfin_restart_issued]
  
  create_duration = "1m"
}

# Retrieve library IDs from Jellyfin
resource "terracurl_request" "jellyfin_get_libraries" {
  depends_on = [time_sleep.jellyfin_restart_completed]

  name   = "jellyfin_get_libraries"
  url    = "https://jellyfin.${local.base_domain}/Library/VirtualFolders"
  method = "GET"

  headers = {
    "Authorization" = local.authenticated_auth_header
  }

  response_codes = [200]
}

# Call to the OIDC module to create the necessary resources in Zitadel.
module "jellyfin_web_ui_oidc" {
  depends_on = [terracurl_request.jellyfin_install_plugins, terracurl_request.jellyfin_get_libraries]

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

  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true

  project_roles = local.roles

  user_grants = {
    "igor" = {
      user_name = "igor.voronin@${local.base_domain}"
      role_keys = ["jellyfin-admin"]
    }
  }
}

# Configure the SSO plugin with Zitadel OIDC details
resource "terracurl_request" "jellyfin_sso" {
  depends_on = [module.jellyfin_web_ui_oidc]

  name   = "jellyfin_sso"
  url    = "https://jellyfin.${local.base_domain}/sso/OID/Add/zitadel"
  method = "POST"

  headers = {
    "Content-Type"  = "application/json"
    "Authorization" = local.authenticated_auth_header
  }

  request_body = jsonencode({
    oidEndpoint         = "https://zitadel.${local.base_domain}"
    oidClientId         = module.jellyfin_web_ui_oidc.client_id
    oidSecret           = module.jellyfin_web_ui_oidc.client_secret
    oidScopes           = ["email", "roles"]
    enabled             = true
    enableAuthorization = true
    enableFolderRoles   = true
    enableAllFolders    = false
    enabledFolders      = []
    adminRoles          = ["jellyfin-admin"]
    roles               = keys(local.roles)
    roleClaim           = "roles"
    folderRoleMapping   = local.folder_role_mapping
    schemeOverride      = "https"
  })

  response_codes = [200, 204]
}

# Add the "Login with Zitadel" SSO button as a Login disclaimer branding configuration
resource "terracurl_request" "jellyfin_branding" {
  depends_on = [terracurl_request.jellyfin_sso]

  name   = "jellyfin_branding"
  url    = "https://jellyfin.${local.base_domain}/System/Configuration/Branding"
  method = "POST"

  headers = {
    "Content-Type"  = "application/json"
    "Authorization" = local.authenticated_auth_header
  }

  request_body = jsonencode({
    LoginDisclaimer = "<form action=\"https://jellyfin.${local.base_domain}/sso/OID/start/zitadel\"><button class=\"raised block emby-button button-submit\">Login with Zitadel</button></form>"
  })

  response_codes = [204]
}

# Initiate the scan of all created libraries
resource "terracurl_request" "jellyfin_scan_libraries" {
  depends_on = [terracurl_request.jellyfin_sso]

  name   = "jellyfin_scan_libraries"
  url    = "https://jellyfin.${local.base_domain}/Library/Refresh"
  method = "POST"

  headers = {
    "Content-Type"  = "application/json"
    "Authorization" = local.authenticated_auth_header
  }

  request_body = "{}"
  response_codes = [204]
}

# Output
output "client_id" {
  description = "Jellyfin Client ID"
  value       = module.jellyfin_web_ui_oidc.client_id
  sensitive   = true
}

output "library_ids" {
  description = "Jellyfin library IDs"
  value       = local.library_id_map
  sensitive   = true
}

output "folder_role_mapping" {
  description = "Jellyfin folder-role-mapping"
  value       = local.folder_role_mapping
  sensitive   = false
}

output "auth_header" {
  description = "Jellyfin MediaBrowser header"
  value       = terracurl_request.jellyfin_auth.response
  sensitive   = true
}
