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

# PBS-specific

variable "pbs_datastore_name" {
  description = "Name PBS itself uses internally for the datastore (shows up in the PBS UI/API, and in proxmox-backup-client --repository references). Matches the /mnt/datastore/primary mount path by design -- PBS's own removable-datastore convention names the path after the datastore, and this stays consistent with that even though this datastore isn't actually removable."
  type        = string
  default     = "primary"
  nullable    = false
}

# Step CA / ACME (PBS's own built-in ACME client -- same mechanism modules/pbs-vm
# used, reused verbatim here since it doesn't care whether PBS runs in a VM or LXC)
variable "step_ca_domain" {
  description = "Step CA domain (ACME directory is served at https://<this>/acme/<account>/directory)"
  type        = string
  nullable    = false
}

variable "step_ca_client_version" {
  description = "Version of the step CLI to install"
  type        = string
  nullable    = false
}

variable "step_ca_acme_account_name" {
  description = "ACME account name to register with Step CA"
  type        = string
  default     = "step-ca-acme"
  nullable    = false
}

variable "step_ca_acme_contact" {
  description = "Contact email for the ACME account"
  type        = string
  nullable    = false
}
