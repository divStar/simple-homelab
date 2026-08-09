# Root password (console access; day-to-day access is via the shared operator SSH key)
output "root_password" {
  description = "Root password"
  value       = module.setup_container.root_password
  sensitive   = true
}

# Private SSH key
output "ssh_private_key" {
  description = "Private SSH key"
  value       = module.setup_container.ssh_private_key
  sensitive   = true
}

# Convenience outputs for wiring up modules/host's future proxmox_storage_pbs
# registration, same purpose these served on modules/pbs-vm
output "container_ip" {
  description = "PBS LXC IP address"
  value       = local.container_ip
}

output "pbs_datastore_name" {
  description = "Name PBS uses internally for its datastore"
  value       = var.pbs_datastore_name
}
