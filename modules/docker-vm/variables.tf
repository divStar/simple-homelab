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

variable "vm_network_interface_name" {
  description = "Name of the network interface in the VM (e.g. eth0)"
  type        = string
  default     = "eth0"
}

variable "step_ca_client_version" {
  description = "Step CA client version (used in `step-ca.config.yaml.tftpl`)"
  type        = string
}

variable "step_ca_domain" {
  description = "Step CA domain"
  type        = string
}

variable "step_ca_provisioner" {
  description = "Step CA provisioner name"
  type        = string
}

variable "step_ca_provisioner_password" {
  description = "Step CA provisioner password"
  type        = string
  sensitive   = true
}

variable "ignition_config_datastore_id" {
  description = "Proxmox location of the Ignition configuration"
  type        = string
}

variable "ignition_config_file_name" {
  description = "Filename of the Ignition configuration; use `VM_ID` in the filename to replace it with the `vm_id` dynamically"
  type        = string
}

variable "flatcar_image_datastore_id" {
  description = "Proxmox location for the FlatCar image"
  type        = string
}

variable "flatcar_image_file_name" {
  description = "Filename of the FlatCar image (image type must match format of the boot disk in 'disks')"
  type        = string
}

variable "flatcar_image_channel" {
  description = "Image channel of the FlatCar image (alpha, beta, stable)"
  type        = string
  default     = "stable"

  validation {
    condition     = contains(["alpha", "beta", "stable", "lts"], var.flatcar_image_channel)
    error_message = "Channel must be one of: alpha, beta, stable, lts"
  }
}

variable "docker_daemon_configuration" {
  description = "Docker daemon.json configuration file content"
  type        = string

  validation {
    condition     = can(jsondecode(var.docker_daemon_configuration))
    error_message = "Docker daemon configuration must be valid JSON"
  }
}

variable "viritofs_resources" {
  description = "Map of VirtioFS mapping names to attach to all VMs"
  type        = map(string)
}

variable "efi_disk_datastore_id" {
  description = "Proxmox location for the EFI disk"
  type        = string
}

variable "disks" {
  description = "Disks, that should be mounted"
  type = list(object({
    datastore_id = string
    import_from  = string
    interface    = string
    file_format  = string
    size         = number
    serial       = string
    mount_path   = optional(string)
  }))
}