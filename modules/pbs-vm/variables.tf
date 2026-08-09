# Proxmox connection (identical shape to docker-vm's variables)
variable "proxmox_endpoint" {
  description = "Proxmox API endpoint (e.g. https://pve.local:8006)"
  type        = string
}

variable "proxmox_node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "proxmox_password" {
  description = "Proxmox 'root' user password (API token does NOT work)"
  type        = string
}

variable "proxmox_ssh_user" {
  description = "Proxmox SSH user"
  type        = string
}

variable "proxmox_ssh_key" {
  description = "Proxmox SSH key"
  type        = string
}

variable "proxmox_insecure" {
  description = "Skip TLS verification"
  type        = bool
  default     = false
}

# VM identity / network
variable "vm_id" {
  description = "VM ID"
  type        = number
}

variable "vm_hostname" {
  description = "VM Name and hostname"
  type        = string
}

variable "vm_domain" {
  description = "VM Domain for the host"
  type        = string
}

variable "vm_ip" {
  description = "VM IP (v4)"
  type        = string

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.vm_ip))
    error_message = "VM IP addresses must be in valid IPv4 format"
  }
}

variable "vm_gateway_ip" {
  description = "VM gateway IP (v4)"
  type        = string

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.vm_gateway_ip))
    error_message = "Gateway IP addresses must be in valid IPv4 format"
  }
}

variable "vm_dns_ip" {
  description = "VM DNS IP (v4)"
  type        = string

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.vm_dns_ip))
    error_message = "DNS IP addresses must be in valid IPv4 format"
  }
}

# Debian cloud image
variable "debian_image_datastore_id" {
  description = "Proxmox location for the Debian cloud image"
  type        = string
}

variable "debian_image_file_name" {
  description = "Filename of the Debian cloud image"
  type        = string
}

variable "debian_image_release" {
  description = "Debian release codename (e.g. trixie) used both for the cloud image URL and the Proxmox apt repo suite"
  type        = string
  default     = "trixie"
}

# Disks
variable "efi_disk_datastore_id" {
  description = "Proxmox location for the EFI disk"
  type        = string
}

variable "os_disk_datastore_id" {
  description = "Proxmox location for the OS disk"
  type        = string
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 32
}

variable "datastore_disk_datastore_id" {
  description = "Proxmox location for the PBS datastore disk (the new /mnt/backup-backed storage)"
  type        = string
}

variable "datastore_disk_size_gb" {
  description = "PBS datastore disk size in GB -- thin-provisioned, only consumes real space as data is written"
  type        = number
  default     = 8000
}

# PBS-specific
variable "pbs_datastore_name" {
  description = "Name PBS itself uses internally for the datastore (shows up in the PBS UI/API, and in proxmox-backup-client --repository references)"
  type        = string
  default     = "main"
}

# Step CA / ACME (mirrors modules/step-ca's own ACME setup, reused here for PBS's cert
# instead of the JWK-provisioner + step-cli approach docker-vm/pihole use, since PBS ships
# its own ACME client -- see files/setup-acme.sh for the reasoning)
variable "step_ca_domain" {
  description = "Step CA domain (ACME directory is served at https://<this>/acme/<account>/directory)"
  type        = string
}

variable "step_ca_acme_account_name" {
  description = "ACME account name to register with Step CA (reusing the same account name convention as modules/step-ca's own PVE-host ACME setup)"
  type        = string
  default     = "step-ca-acme"
}

variable "step_ca_acme_contact" {
  description = "Contact email for the ACME account"
  type        = string
}
