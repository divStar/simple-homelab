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
    restapi = {
      source  = "mastercard/restapi"
      version = ">= 2.0.1"
    }
    portainer = {
      source  = "portainer/portainer"
      version = ">= 1.18.2"
    }
  }
}

locals {
  base_domain = regex("BASE_DOMAIN\\s*=\\s*(\\S+)", file("${path.module}/stack.env"))[0]
}

variable "admin_username" {
  description = "Portainer admin username"
  type        = string
  sensitive   = false
  nullable    = false
}

variable "admin_password" {
  description = "Portainer admin password"
  type        = string
  sensitive   = true
  nullable    = false
}

variable "license_key" {
  description = "Portainer BE license key"
  type        = string
  sensitive   = true
  nullable    = false
}

# `zitadel` provider set up.
provider "zitadel" {
  domain           = "zitadel.${local.base_domain}"
  insecure         = "false"
  port             = "443"
  jwt_profile_file = "${path.module}/../../admin_key.json"
}

provider "restapi" {
  uri                  = "https://portainer.${local.base_domain}"
  write_returns_object = true
  debug                = true

  headers = {
    "Content-Type" = "application/json"
  }
}

provider "portainer" {
  alias    = "unauth"
  endpoint = "https://portainer.${local.base_domain}"
}

provider "portainer" {
  alias        = "auth"
  endpoint     = "https://portainer.${local.base_domain}"
  api_user     = var.admin_username
  api_password = var.admin_password
}

# Call to the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary resources in Zitadel.
module "portainer_web_ui_oidc" {
  source = "../../../common/modules/oidc"

  org_name         = "Sanctum"
  project_name     = "Portainer"
  application_name = "Portainer Web UI"
  app_type         = "OIDC_APP_TYPE_WEB"
  auth_method_type = "OIDC_AUTH_METHOD_TYPE_BASIC"

  redirect_uris             = ["https://portainer.${local.base_domain}/"]
  response_types            = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types               = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  post_logout_redirect_uris = ["https://portainer.${local.base_domain}/"]

  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true

  project_roles = {
    "portainer_admin" : {
      display_name = "Portainer admin"
      group : "portainer"
    }
  }

  actions = [{
    name            = "flatRoles"
    script          = file("${path.module}/files/zitadel-action.flatRoles.js")
    allowed_to_fail = true
    triggers = [
      {
        flow_type    = "FLOW_TYPE_CUSTOMISE_TOKEN"
        trigger_type = "TRIGGER_TYPE_PRE_USERINFO_CREATION"
      },
      {
        flow_type    = "FLOW_TYPE_CUSTOMISE_TOKEN"
        trigger_type = "TRIGGER_TYPE_PRE_ACCESS_TOKEN_CREATION"
      },
    ]
  }]

  admin_user = "igor.voronin@${local.base_domain}"
}

# resource "portainer_init" "this" {
#   provider = portainer.unauth
#   username = var.admin_username
#   password = var.admin_password
# }

resource "restapi_object" "portainer_admin_init" {
  create_method = "POST"
  path          = "/api/users/admin/init"
  data = jsonencode({
    username = "admin",
    password = var.admin_password
  })
  object_id = "portainer_token"
}

resource "portainer_licenses" "this" {
  provider   = portainer.auth
  depends_on = [restapi_object.portainer_admin_init]
  key        = var.license_key
  force      = true
}

resource "portainer_settings" "this" {
  provider   = portainer.auth
  depends_on = [restapi_object.portainer_admin_init, portainer_licenses.this]

  authentication_method = 3
  oauth_settings {
    client_id               = module.portainer_web_ui_oidc.client_id
    client_secret           = module.portainer_web_ui_oidc.client_secret
    access_token_uri        = "https://zitadel.${local.base_domain}/oauth/v2/token"
    authorization_uri       = "https://zitadel.${local.base_domain}/oauth/v2/authorize"
    resource_uri            = "https://zitadel.${local.base_domain}/oidc/v1/userinfo"
    redirect_uri            = "https://portainer.${local.base_domain}/"
    logout_uri              = "https://zitadel.${local.base_domain}/oidc/v1/end_session?post_logout_redirect_uri=https://portainer.${local.base_domain}/"
    user_identifier         = "preferred_username"
    scopes                  = "openid email profile roles"
    oauth_auto_create_users = true
    default_team_id         = 0
    sso                     = true
    auth_style              = 0

    oauth_auto_map_team_memberships = true

    team_memberships {
      oauth_claim_name              = "roles"
      admin_auto_populate           = true
      admin_group_claims_regex_list = ["portainer_admin"]
    }
  }
}

# `client_id` for further use.
output "client_id" {
  description = "Portainer Client ID"
  value       = module.portainer_web_ui_oidc.client_id
  sensitive   = true
}

# `client_secret` for further use.
output "client_secret" {
  description = "Portainer Client ID"
  value       = module.portainer_web_ui_oidc.client_secret
  sensitive   = true
}
