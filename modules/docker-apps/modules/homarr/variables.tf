variable "proxmox" {
  description = "Proxmox API connection details, used to create Homarr's own read-only PVEAuditor API user/token. Reduced from the shared shape used elsewhere in this repo (no ssh_user/ssh_key) since only bpg/proxmox API calls happen here, no SSH-based provisioning."
  sensitive   = true
  nullable    = false
  type = object({
    host     = string
    insecure = bool
    username = string
    password = string
  })
}
