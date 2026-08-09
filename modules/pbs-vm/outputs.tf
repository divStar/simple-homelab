# Root password (console access; day-to-day access is via the shared operator SSH key)
output "root_password" {
  description = "Root password"
  value       = random_password.root_password.result
  sensitive   = true
}

# Convenience outputs for wiring up modules/host's future proxmox_storage_pbs
# registration (that resource also needs a fingerprint + API token generated on
# the PBS box itself during setup, which isn't something this module can output)
output "vm_ip" {
  description = "PBS VM IP address"
  value       = var.vm_ip
}

output "pbs_datastore_name" {
  description = "Name PBS uses internally for its datastore"
  value       = var.pbs_datastore_name
}
