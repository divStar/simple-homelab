/**
 * # Portainer OIDC
 *
 * This module uses the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary `client_id` and `client_secret` to set up OIDC/OAuth in Portainer with Zitadel.
 */

# Terraform and provider setup.
terraform {
  required_version = ">= 1.10.5"

  required_providers {
    zitadel = {
      source  = "zitadel/zitadel"
      version = ">= 2.3.0"
    }
    portainer = {
      source  = "portainer/portainer"
      version = ">= 1.17.0"
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

provider "portainer" {
  endpoint = "https://portainer.my.world"

  api_user     = "admin"
  api_password = var.portainer_password
}

variable "portainer_password" {
  description = "Containers the portainer password"
  type        = string
}

# Call to the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary resources in Zitadel.
module "portainer_web_ui_oidc" {
  source = "../../../common/modules/oidc"

  org_name         = "Sanctum"
  project_name     = "Portainer"
  application_name = "Portainer Web UI"
  app_type         = "OIDC_APP_TYPE_WEB"
  auth_method_type = "OIDC_AUTH_METHOD_TYPE_BASIC"

  redirect_uris             = ["https://portainer.my.world/"]
  response_types            = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types               = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  post_logout_redirect_uris = ["https://portainer.my.world"]

  admin_user = "igor.voronin@my.world"
}

resource "portainer_settings" "this" {
  authentication_method = 3
  oauth_settings {
    client_id               = module.portainer_web_ui_oidc.client_id
    client_secret           = tostring(module.portainer_web_ui_oidc.client_secret)
    authorization_uri       = "https://zitadel.my.world/oauth/v2/authorize"
    access_token_uri        = "https://zitadel.my.world/oauth/v2/token"
    redirect_uri            = "https://portainer.my.world/"
    resource_uri            = "https://zitadel.my.world/oidc/v1/userinfo"
    user_identifier         = "preferred_username"
    scopes                  = "openid email profile"
    logout_uri              = "https://zitadel.my.world/oidc/v1/end_session?post_logout_redirect_uri=https://portainer.my.world/"
    oauth_auto_create_users = true # Based on "Automatic user provisioning" being enabled
    sso                     = true # Based on "Use SSO" being enabled
    auth_style              = 0    # "Auto Detect" in the UI
  }
}

# `client_id` for further use.
output "client_id" {
  description = "Portainer Client ID"
  value       = module.portainer_web_ui_oidc.client_id
  sensitive   = false
}

# `client_secret` for further use.
output "client_secret" {
  description = "Portainer Client Secret"
  value       = module.portainer_web_ui_oidc.client_secret
  sensitive   = false
}