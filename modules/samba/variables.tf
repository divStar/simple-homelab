# Proxmox host configuration
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

variable "samba_users" {
  description = "List of Samba users with their passwords"
  type = list(object({
    username = string
    password = string
  }))
  sensitive = true
}