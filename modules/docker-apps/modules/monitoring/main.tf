/**
 * # Grafana Alloy and Prometheus OIDC
 *
 * This module uses the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary `client_id`
 * to set up OIDC/OAuth for Grafana Alloy and Prometheus with Zitadel.
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

locals {
  base_domain = regex("BASE_DOMAIN\\s*=\\s*(\\S+)", file("${path.module}/stack.env"))[0]
}

# `zitadel` provider set up.
provider "zitadel" {
  domain           = "zitadel.${local.base_domain}"
  insecure         = "false"
  port             = "443"
  jwt_profile_file = "${path.module}/../../admin_key.json"
}

# Call to the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary resources in Zitadel.
module "prometheus_oidc" {
  source = "../../../common/modules/oidc"

  org_name         = "Sanctum"
  project_name     = "Prometheus"
  application_name = "Prometheus Dashboard"
  app_type         = "OIDC_APP_TYPE_WEB"
  auth_method_type = "OIDC_AUTH_METHOD_TYPE_NONE"

  redirect_uris             = ["https://prometheus.${local.base_domain}/oidc/callback"]
  response_types            = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types               = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  post_logout_redirect_uris = ["https://prometheus.${local.base_domain}/oidc/logout"]

  admin_user = "igor.voronin@${local.base_domain}"
}

# Call to the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary resources in Zitadel.
module "grafana_alloy_oidc" {
  source = "../../../common/modules/oidc"

  org_name         = "Sanctum"
  project_name     = "Grafana Alloy"
  application_name = "Grafana Alloy Dashboard"
  app_type         = "OIDC_APP_TYPE_WEB"
  auth_method_type = "OIDC_AUTH_METHOD_TYPE_NONE"

  redirect_uris             = ["https://alloy.${local.base_domain}/oidc/callback"]
  response_types            = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types               = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  post_logout_redirect_uris = ["https://alloy.${local.base_domain}/oidc/logout"]

  admin_user = "igor.voronin@${local.base_domain}"
}

# Zitadel application client-ID for further use.
output "prometheus_client_id" {
  description = "Prometheus Client ID"
  value       = module.prometheus_oidc.client_id
  sensitive   = true
}

# Zitadel application client-ID for further use.
output "alloy_client_id" {
  description = "Grafana Alloy Client ID"
  value       = module.grafana_alloy_oidc.client_id
  sensitive   = true
}