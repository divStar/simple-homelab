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

variable "share_permissions" {
  description = "Share paths whose group permissions get repaired on a schedule"
  # @field paths         Host paths backing the Samba shares (e.g. "/mnt/storage/yuliia")
  # @field exclude_paths Subtrees to skip entirely (e.g. archives that must keep their original modes)
  # @field schedule      systemd `OnCalendar` expression
  type = object({
    paths         = list(string)
    exclude_paths = optional(list(string), [])
    schedule      = optional(string, "*-*-* 04:30:00")
  })
  default = {
    paths = []
  }
}

variable "textfile_directory" {
  description = "node_exporter textfile collector directory to write metrics to; keep empty to skip metrics"
  type        = string
  default     = null
}
