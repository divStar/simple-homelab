/**
 * # OIDC (Zitadel) module
 *
 * This module creates a project and application and grants a specified admin user (if set) permissions to it.
 *
 * This module is as rigid as I need it, but of course it does not (yet?) allow for e.g. roles assignments etc. since I do not use them currently.
 */

locals {
  # Organization ID
  organization_id = data.zitadel_orgs.this.ids[0]

  # Create a unique key for each action-trigger combination
  action_triggers = flatten([
    for action in var.actions : [
      for trigger in action.triggers : {
        action_name  = action.name
        flow_type    = trigger.flow_type
        trigger_type = trigger.trigger_type
      }
    ]
  ])

  # Group actions by flow_type and trigger_type
  trigger_groups_raw = {
    for trigger in local.action_triggers :
    "${trigger.flow_type}:${trigger.trigger_type}" => trigger...
  }

  # Create readable keys with snake_case and action names
  trigger_groups = {
    for key, triggers in local.trigger_groups_raw :
    "${replace(lower(split(":", key)[0]), "flow_type_", "")}:${replace(lower(split(":", key)[1]), "trigger_type_", "")}:${join(",", sort([for t in triggers : t.action_name]))}" => {
      flow_type    = split(":", key)[0]
      trigger_type = split(":", key)[1]
      action_names = [for t in triggers : t.action_name]
    }
  }
}

# Data source to find the ID of the desired organization.
data "zitadel_orgs" "this" {
  name        = var.org_name
  name_method = "TEXT_QUERY_METHOD_CONTAINS_IGNORE_CASE"
  state       = "ORG_STATE_ACTIVE"
}

# Project to create in the organization found via the data source `zitadel_orgs`.
resource "zitadel_project" "this" {
  name                   = var.project_name
  org_id                 = local.organization_id
  project_role_assertion = true
  project_role_check     = true
}

# Application to create in the newly created project.
resource "zitadel_application_oidc" "this" {
  depends_on = [zitadel_project.this]
  project_id = zitadel_project.this.id

  name                        = var.application_name
  app_type                    = var.app_type
  auth_method_type            = var.auth_method_type
  redirect_uris               = var.redirect_uris
  response_types              = var.response_types
  grant_types                 = var.grant_types
  access_token_type           = var.access_token_type
  access_token_role_assertion = var.access_token_role_assertion
  id_token_role_assertion     = var.id_token_role_assertion
  id_token_userinfo_assertion = var.id_token_userinfo_assertion
  post_logout_redirect_uris   = var.post_logout_redirect_uris
}

# Project roles to create
resource "zitadel_project_role" "this" {
  depends_on = [zitadel_project.this]
  for_each   = var.project_roles

  org_id     = local.organization_id
  project_id = zitadel_project.this.id

  role_key     = each.key
  display_name = each.value.display_name
  group        = each.value.group
}

# Find user, that should be granted the project (if set)
data "zitadel_machine_users" "this" {
  count = var.admin_user == null ? 0 : 1

  org_id           = local.organization_id
  user_name        = var.admin_user
  user_name_method = "TEXT_QUERY_METHOD_CONTAINS_IGNORE_CASE"
}

# Grant project to user (if set)
resource "zitadel_user_grant" "this" {
  depends_on = [zitadel_application_oidc.this]
  count      = var.admin_user == null ? 0 : 1

  org_id     = local.organization_id
  project_id = zitadel_project.this.id
  user_id    = data.zitadel_machine_users.this[0].user_ids[0]
  role_keys  = keys(var.project_roles)
}

# Create all actions
resource "zitadel_action" "this" {
  for_each = { for action in var.actions : action.name => action }

  org_id          = local.organization_id
  name            = each.value.name
  script          = each.value.script
  timeout         = each.value.timeout
  allowed_to_fail = each.value.allowed_to_fail
}

# Assign actions to triggers
resource "zitadel_trigger_actions" "this" {
  for_each = local.trigger_groups

  org_id       = local.organization_id
  flow_type    = each.value.flow_type
  trigger_type = each.value.trigger_type

  action_ids = [
    for action_name in each.value.action_names :
    zitadel_action.this[action_name].id
  ]
}