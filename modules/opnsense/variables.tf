variable "proxmox" {
  description = "Proxmox host configuration"
  sensitive   = true
  nullable    = false
  type = object({
    name     = string
    host     = string
    ssh_user = string
    ssh_key  = string
    insecure = bool
    username = string
    password = string
  })
}

variable "proxmox_node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "vm_id" {
  description = "VM ID for the OPNsense VM"
  type        = number
}

variable "vm_name" {
  description = "Name of the OPNsense VM"
  type        = string
  default     = "opnsense"
}

variable "opnsense_version" {
  description = "OPNsense release version to install (used to build the ISO download URL, e.g. https://pkg.opnsense.org/releases/mirror/OPNsense-<version>-dvd-amd64.iso.bz2)"
  type        = string
  default     = "26.7"
}

variable "wan_bridge" {
  description = "Proxmox bridge to attach the WAN interface to (untagged - gets its address from upstream, e.g. via DHCP during the test phase)"
  type        = string
  default     = "vmbr0"
}

variable "lan_bridge" {
  description = "Proxmox bridge to attach the LAN interface to (untagged/trunk - OPNsense handles VLAN tagging internally on top of this one interface)"
  type        = string
  default     = "vmbr1"
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 4
}

variable "memory" {
  description = "Dedicated memory in MB"
  type        = number
  default     = 8192
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 24
}

variable "disk_datastore_id" {
  description = "Datastore to place the VM's main disk on"
  type        = string
  default     = "disk-images"
}

variable "iso_datastore_id" {
  description = "Datastore to store the downloaded install ISO on"
  type        = string
  default     = "pve-resources"
}

variable "efi_disk_datastore_id" {
  description = "Datastore for the EFI disk"
  type        = string
  default     = "pve-resources"
}

variable "boot_from_installer" {
  description = "Whether to boot from the install ISO. true for the initial manual install; set to false afterwards (and re-apply) to boot from disk and eject the ISO."
  type        = bool
  default     = true
}
