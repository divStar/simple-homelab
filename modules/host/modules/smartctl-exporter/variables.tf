variable "ssh" {
  description = "SSH configuration for remote connection"
  # @field host The target host to connect to using SSH
  # @field user SSH user to connect with
  # @field id Path to SSH private key file (defaults to ~/.ssh/id_rsa)
  # @type object
  type = object({
    host    = string
    user    = string
    id_file = optional(string, "~/.ssh/id_rsa")
  })
}

variable "smartctl_exporter_github_repository" {
  description = "Configuration of the storage (pools and directories) to import"
  type        = string
  default     = "https://api.github.com/repos/prometheus-community/smartctl_exporter/releases/latest"
}

variable "smartctl_exporter_version" {
  description = "Particular version to install; keep empty to install the latest"
  type        = string
  default     = null
}