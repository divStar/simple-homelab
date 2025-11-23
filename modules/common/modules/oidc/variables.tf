variable "org_name" {
  description = "Name of the organization to create the project in (must be `active`)"
  type        = string
}

variable "project_name" {
  description = "Name of the project to create in the organization"
  type        = string
}

variable "application_name" {
  description = "Name of the application to create in the project"
  type        = string
}

variable "app_type" {
  description = "Application type"
  type        = string
}

variable "auth_method_type" {
  description = "Auth-method type"
  type        = string
}

variable "redirect_uris" {
  description = "RedirectURIs"
  type        = list(string)
}

variable "response_types" {
  description = "Response types"
  type        = list(string)
}

variable "grant_types" {
  description = "Grant types"
  type        = list(string)
}

variable "access_token_type" {
  description = "Access token type (Bearer Token or JWT)"
  type        = string
  nullable    = false
  default     = "OIDC_TOKEN_TYPE_BEARER"
}

variable "access_token_role_assertion" {
  description = "Whether the roles in the access token are to be asserted or not"
  type        = bool
  default     = false
}

variable "id_token_role_assertion" {
  description = "Whether to add the roles directly to the ID token"
  type        = bool
  default     = false
}

variable "id_token_userinfo_assertion" {
  description = "Whether to include information such as email in the ID token"
  type        = bool
  default     = false
}

variable "post_logout_redirect_uris" {
  description = "Post-logout redirectURIs"
  type        = list(string)
}

variable "admin_user" {
  description = "Administrator of the project; user `user_name` or leave empty if unknown or set manually at a later point"
  type        = string
  nullable    = true
  default     = null
}

variable "project_roles" {
  description = "Roles to create for the project in Zitadel (the key is the `role_key` name)"
  type = map(object({
    display_name = string
    group        = string
  }))
  default = {}
}


variable "actions" {
  description = "List of Zitadel actions to create and assign to flows"
  type = list(object({
    name            = string
    script          = string
    timeout         = optional(string, "10s")
    allowed_to_fail = optional(bool, false)
    triggers = list(object({
      flow_type    = string # e.g., "FLOW_TYPE_CUSTOMISE_TOKEN"
      trigger_type = string # e.g., "TRIGGER_TYPE_PRE_USERINFO_CREATION"
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for action in var.actions : alltrue([
        for trigger in action.triggers : contains([
          "FLOW_TYPE_EXTERNAL_AUTHENTICATION",
          "FLOW_TYPE_CUSTOMISE_TOKEN",
          "FLOW_TYPE_INTERNAL_AUTHENTICATION",
          "FLOW_TYPE_SAML_RESPONSE"
        ], trigger.flow_type)
      ])
    ])
    error_message = "flow_type must be one of: FLOW_TYPE_EXTERNAL_AUTHENTICATION, FLOW_TYPE_CUSTOMISE_TOKEN, FLOW_TYPE_INTERNAL_AUTHENTICATION, FLOW_TYPE_SAML_RESPONSE"
  }

  validation {
    condition = alltrue([
      for action in var.actions : alltrue([
        for trigger in action.triggers : contains([
          "TRIGGER_TYPE_POST_AUTHENTICATION",
          "TRIGGER_TYPE_PRE_CREATION",
          "TRIGGER_TYPE_POST_CREATION",
          "TRIGGER_TYPE_PRE_USERINFO_CREATION",
          "TRIGGER_TYPE_PRE_ACCESS_TOKEN_CREATION",
          "TRIGGER_TYPE_PRE_SAML_RESPONSE_CREATION"
        ], trigger.trigger_type)
      ])
    ])
    error_message = "trigger_type must be one of: TRIGGER_TYPE_POST_AUTHENTICATION, TRIGGER_TYPE_PRE_CREATION, TRIGGER_TYPE_POST_CREATION, TRIGGER_TYPE_PRE_USERINFO_CREATION, TRIGGER_TYPE_PRE_ACCESS_TOKEN_CREATION, TRIGGER_TYPE_PRE_SAML_RESPONSE_CREATION"
  }
}