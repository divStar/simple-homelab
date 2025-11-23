output "client_id" {
  description = "Client ID"
  value       = zitadel_application_oidc.this.client_id
  sensitive   = true
}

output "client_secret" {
  description = "Client secret"
  value       = zitadel_application_oidc.this.client_secret
  sensitive   = true
}

output "project_id" {
  description = "ID of the newly created project in Zitadel"
  value       = zitadel_project.this.id
}