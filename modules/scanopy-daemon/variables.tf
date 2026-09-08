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

variable "scanopy_daemon_api_key" {
  description = "API key for this scanopy-daemon instance, issued by the Scanopy server"
  type        = string
  sensitive   = true
  nullable    = false
}
