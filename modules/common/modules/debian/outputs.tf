# Root password
output "root_password" {
  description = "Root password"
  value       = random_password.root_password.result
  sensitive   = true
}

# Private SSH key
output "ssh_private_key" {
  description = "Private SSH key"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}

# Container id - not for identifying the container (callers already know vm_id),
# but so callers can use it as a `replace_triggered_by` target: when the
# container is destroyed and recreated (e.g. a template change forcing
# replacement), this value becomes "known after apply" during planning even
# though it settles back to the same vm_id, which is what actually propagates
# the replacement to dependent provisioning resources. Without this, a
# container replace silently leaves in-guest config un-reprovisioned against a
# fresh container - see the same output in ../alpine/outputs.tf.
output "container_id" {
  description = "Container id - see comment for why this is exported"
  value       = proxmox_virtual_environment_container.container.id
}
