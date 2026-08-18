output "vm_id" {
  description = "VM ID of the OPNsense VM"
  value       = proxmox_virtual_environment_vm.opnsense.vm_id
}

output "opnsense_version" {
  description = "OPNsense version the install ISO was built from"
  value       = var.opnsense_version
}

output "mac_addresses" {
  description = "MAC addresses of the WAN and LAN network devices, in that order"
  value       = proxmox_virtual_environment_vm.opnsense.network_device[*].mac_address
}
