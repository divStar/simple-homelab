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
module "grafana_web_ui_oidc" {
  source = "../../../common/modules/oidc"

  org_name         = "Sanctum"
  project_name     = "Grafana"
  application_name = "Grafana Web UI"
  app_type         = "OIDC_APP_TYPE_WEB"
  auth_method_type = "OIDC_AUTH_METHOD_TYPE_NONE"

  redirect_uris             = ["https://grafana.my.world/login/generic_oauth"]
  response_types            = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types               = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  post_logout_redirect_uris = ["https://grafana.my.world/login"]

  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true

  admin_user = "igor.voronin@my.world"

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

# `client_id` for further use.
output "client_id" {
  description = "Grafana Client ID"
  value       = module.grafana_web_ui_oidc.client_id
  sensitive   = true
}
