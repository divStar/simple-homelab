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

variable "pihole_admin_password" {
  description = "Pi-hole web interface admin password"
  type        = string
  sensitive   = true
  nullable    = false
}

variable "upstream_dns" {
  description = "Upstream DNS servers for Pi-hole to forward non-local queries to"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
  nullable    = false
}

variable "step_ca_domain" {
  description = "Domain of the Step CA server used to issue Pi-hole's webserver TLS certificate"
  type        = string
  nullable    = false
}

variable "step_ca_client_version" {
  description = "Version of the step CLI to install"
  type        = string
  nullable    = false
}

variable "step_ca_provisioner" {
  description = "Step CA provisioner name used to issue Pi-hole's webserver TLS certificate"
  type        = string
  nullable    = false
}

variable "step_ca_provisioner_password" {
  description = "Step CA provisioner password"
  type        = string
  sensitive   = true
  nullable    = false
}
