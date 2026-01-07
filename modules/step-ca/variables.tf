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

variable "acme" {
  description = "ACME configuration"
  sensitive   = true
  nullable    = false
  type = object({
    contact         = string
    name            = string
    proxmox_domains = list(string)
  })
}

# General Step CA server configuration
variable "fingerprint_file" {
  description = "File containing the fingerprint"
  type        = string
  default     = ""
  nullable    = false
}
