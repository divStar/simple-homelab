/**
 * # Grafana OIDC
 *
 * This module uses the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary `client_id` to set up OIDC/OAuth in Grafana with Zitadel.
 */

# Terraform and provider setup.
terraform {
  required_version = ">= 1.10.5"

  required_providers {
    zitadel = {
      source  = "zitadel/zitadel"
      version = ">= 2.3.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = ">= 4.17.0"
    }
  }
}

locals {
  base_domain = "my.world"
}

variable "admin_user" {
  description = "Grafana admin username"
  type        = string
  nullable    = false
}

variable "admin_password" {
  description = "Grafana admin password"
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

# `grafana` provider set up.
provider "grafana" {
  auth = "${var.admin_user}:${var.admin_password}"
  url  = "https://grafana.${local.base_domain}"
}

# Call to the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary resources in Zitadel.
module "grafana_web_ui_oidc" {
  source = "../../../common/modules/oidc"

  org_name         = "Sanctum"
  project_name     = "Grafana"
  application_name = "Grafana Web UI"
  app_type         = "OIDC_APP_TYPE_WEB"
  auth_method_type = "OIDC_AUTH_METHOD_TYPE_NONE"

  redirect_uris             = ["https://grafana.${local.base_domain}/login/generic_oauth"]
  response_types            = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types               = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  post_logout_redirect_uris = ["https://grafana.${local.base_domain}/login"]

  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true

  admin_user = "igor.voronin@${local.base_domain}"

  project_roles = {
    "grafana_admin" : {
      display_name = "Grafana admin"
      group : "grafana"
    }
    "grafana_editor" : {
      display_name = "Grafana editor"
      group : "grafana"
    }
  }
}

resource "grafana_sso_settings" "name" {
  provider_name = "generic_oauth"

  oauth2_settings {
    enabled                    = true
    name                       = "Zitadel"
    use_pkce                   = true
    use_refresh_token          = true
    client_id                  = module.grafana_web_ui_oidc.client_id
    allow_sign_up              = true
    allow_assign_grafana_admin = true
    empty_scopes               = false
    scopes                     = "openid profile email offline_access"
    email_attribute_path       = "email"
    name_attribute_path        = "name"
    login_attribute_path       = "preferred_username"
    role_attribute_path        = "\"urn:zitadel:iam:org:project:${module.grafana_web_ui_oidc.project_id}:roles\".grafana_admin && 'GrafanaAdmin' || \"urn:zitadel:iam:org:project:${module.grafana_web_ui_oidc.project_id}:roles\".grafana_editor && 'Editor' || 'Viewer'"
    role_attribute_strict      = false
    custom = {
      "icon" = "signin"
    }
    api_url              = "https://zitadel.${local.base_domain}/oidc/userinfo"
    auth_url             = "https://zitadel.${local.base_domain}/oauth/v2/authorize"
    token_url            = "https://zitadel.${local.base_domain}/oauth/v2/token"
    signout_redirect_url = "https://zitadel.${local.base_domain}/oidc/v1/end_session?post_logout_redirect_uri=https://grafana.${local.base_domain}/login"
  }
}

# `client_id` for further use.
output "client_id" {
  description = "Grafana Client ID"
  value       = module.grafana_web_ui_oidc.client_id
  sensitive   = true
}
