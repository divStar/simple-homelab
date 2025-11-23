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
  base_domain = "my.world"
  portainer_jwt = restapi_object.portainer_jwt.api_data["jwt"]
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
  alias = "unauthorized_restapi"
  uri                  = "https://portainer.${local.base_domain}"
  write_returns_object = true
  debug                = true

  headers = {
    "Content-Type" = "application/json"
  }
}

# `restapi` provider set up.
provider "restapi" {
  alias = "jwt_restapi"
  uri                  = "https://portainer.${local.base_domain}"
  write_returns_object = true
  debug                = true

  headers = {
    "Content-Type" = "application/json"
     "Authorization" = "Bearer ${local.portainer_jwt}"
  }

  create_method  = "PUT"
  update_method  = "PUT"
  destroy_method = "PUT"
}

resource "restapi_object" "portainer_jwt" {
  provider = restapi.unauthorized_restapi
  create_method = "POST"
  path = "/api/auth"
  data = file("${path.module}/portainer-get-jwt.secret.json")
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

  admin_user = "igor.voronin@${local.base_domain}"
}

resource "restapi_object" "portainer_settings" {
  depends_on = [module.portainer_web_ui_oidc]

  provider = restapi.jwt_restapi
  path = "/api/settings"
  data = templatefile("${path.module}/portainer-set-oauth-settings.json.tftpl", {
    client_id = module.portainer_web_ui_oidc.client_id
    client_secret = module.portainer_web_ui_oidc.client_secret
    base_domain = local.base_domain
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
