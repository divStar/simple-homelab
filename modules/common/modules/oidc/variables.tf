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