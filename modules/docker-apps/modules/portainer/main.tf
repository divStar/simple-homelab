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
  }
}

locals {
  base_domain = regex("BASE_DOMAIN\\s*=\\s*(\\S+)", file("${path.module}/stack.env"))[0]
  portainer_jwt = restapi_object.portainer_jwt.api_data["jwt"]
}

variable "admin_password" {
  description = "Portainer admin password"
  type        = string
  sensitive   = true
  nullable    = false
}

variable "portainer_license" {
  description = "Portainer license key"
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

# `restapi` provider set up.
provider "restapi" {
  alias                = "unauthorized"
  uri                  = "https://portainer.${local.base_domain}"
  write_returns_object = true
  debug                = true

  headers = {
    "Content-Type" = "application/json"
  }
}

# `restapi` provider set up.
provider "restapi" {
  alias                = "jwt"
  uri                  = "https://portainer.${local.base_domain}"
  write_returns_object = true
  debug                = true

  headers = {
    "Content-Type"  = "application/json"
    "Authorization" = "Bearer ${local.portainer_jwt}"
  }
}

resource "restapi_object" "portainer_admin_init" {
  provider      = restapi.unauthorized
  create_method = "POST"
  path          = "/api/users/admin/init"
  data = jsonencode({
    username = "admin",
    password = var.admin_password
  })
  object_id = "portainer_token"
}

resource "restapi_object" "portainer_jwt" {
  depends_on = [restapi_object.portainer_admin_init]

  provider      = restapi.unauthorized
  create_method = "POST"
  path          = "/api/auth"
  data = jsonencode({
    username = "admin",
    password = var.admin_password
  })
  object_id = "portainer_token"
}

resource "restapi_object" "portainer_license" {
  depends_on = [restapi_object.portainer_admin_init]

  provider      = restapi.jwt
  create_method = "POST"
  path          = "/api/licenses/add"
  data = jsonencode({
    key = var.portainer_license,
  })
  object_id = "portainer_token"
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

resource "restapi_object" "portainer_settings" {
  depends_on = [module.portainer_web_ui_oidc]

  provider      = restapi.jwt
  create_method = "PUT"
  path          = "/api/settings"
  data = jsonencode({
    "AuthenticationMethod" : 3,
    "OAuthSettings" : {
      "ClientID" : "${module.portainer_web_ui_oidc.client_id}",
      "ClientSecret" : "${module.portainer_web_ui_oidc.client_secret}",
      "AccessTokenURI" : "https://zitadel.${local.base_domain}/oauth/v2/token",
      "AuthorizationURI" : "https://zitadel.${local.base_domain}/oauth/v2/authorize",
      "ResourceURI" : "https://zitadel.${local.base_domain}/oidc/v1/userinfo",
      "RedirectURI" : "https://portainer.${local.base_domain}/",
      "UserIdentifier" : "preferred_username",
      "Scopes" : "openid email profile roles",
      "OAuthAutoCreateUsers" : true,
      "OAuthAutoMapTeamMemberships" : true,
      "DefaultTeamID" : 0,
      "SSO" : true,
      "LogoutURI" : "https://zitadel.${local.base_domain}/oidc/v1/end_session?post_logout_redirect_uri=https://portainer.${local.base_domain}/",
      "AuthStyle" : 0,
      "TeamMemberships" : {
        "OAuthClaimName" : "roles",
        "AdminAutoPopulate" : true,
        "AdminGroupClaimsRegexList" : ["portainer_admin"]
      }
    }
  })
  object_id = "portainer_settings"
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
