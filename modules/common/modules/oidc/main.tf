/**
 * # OIDC (Zitadel) module
 *
 * This module creates a project and application and grants a specified admin user (if set) permissions to it.
 *
 * This module is as rigid as I need it, but of course it does not (yet?) allow for e.g. roles assignments etc. since I do not use them currently.
 */

# Data source to find the ID of the desired organization.
data "zitadel_orgs" "this" {
  name        = var.org_name
  name_method = "TEXT_QUERY_METHOD_CONTAINS_IGNORE_CASE"
  state       = "ORG_STATE_ACTIVE"
}

# Project to create in the organization found via the data source `zitadel_orgs`.
resource "zitadel_project" "this" {
  name                   = var.project_name
  org_id                 = data.zitadel_orgs.this.ids[0]
  project_role_assertion = true
  project_role_check     = true
}

# Application to create in the newly created project.
resource "zitadel_application_oidc" "this" {
  project_id = zitadel_project.this.id

  name                      = var.application_name
  app_type                  = var.app_type
  auth_method_type          = var.auth_method_type
  redirect_uris             = var.redirect_uris
  response_types            = var.response_types
  grant_types               = var.grant_types
  post_logout_redirect_uris = var.post_logout_redirect_uris
}

# Find user, that should be granted the project (if set)
data "zitadel_machine_users" "this" {
  count = var.admin_user == null ? 0 : 1

  org_id           = data.zitadel_orgs.this.ids[0]
  user_name        = var.admin_user
  user_name_method = "TEXT_QUERY_METHOD_CONTAINS_IGNORE_CASE"
}

# Grant project to user (if set)
resource "zitadel_user_grant" "this" {
  count = var.admin_user == null ? 0 : 1

  org_id     = data.zitadel_orgs.this.ids[0]
  project_id = zitadel_project.this.id
  user_id    = data.zitadel_machine_users.this[0].user_ids[0]
}
