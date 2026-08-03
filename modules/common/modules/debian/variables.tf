# General container configuration
variable "proxmox" {
  description = "Proxmox host configuration"
  type = object({
    name     = string
    host     = string
    ssh_user = string
    ssh_key  = string
  })
}

variable "vm_id" {
  description = "Container (VM)ID"
  type        = number
  nullable    = false
}

variable "unprivileged" {
  description = "Whether the LXC container will be created as an unprivileged container (default) or as a privileged one"
  type        = bool
  default     = true
  nullable    = false
}

variable "hostname" {
  description = "Container host name"
  type        = string
  nullable    = false
}

variable "description" {
  description = "Description of the container"
  type        = string
  default     = "Debian Linux based LXC container"
}

variable "tags" {
  description = "Tags"
  type        = list(string)
  default     = ["lxc", "debian"]
}

variable "debian_image" {
  description = "Debian image configuration"
  type = object({
    url                = string
    checksum           = string
    checksum_algorithm = string
  })
  default = {
    url                = "http://download.proxmox.com/images/system/debian-13-standard_13.6-1_amd64.tar.zst"
    checksum           = "4c0c27ca6ceab5ef0b84db57825a00f26157ef1854bafe97297813e1cbe8ecb8cc9c453cab6b3b0efe1ba193a50c47ece1e41d950e411b8730b835b71e9e754b"
    checksum_algorithm = "sha512"
  }
  nullable = false
}

# Resource configuration

variable "cpu_cores" {
  description = "Amount of CPU (v)cores; SMT/HT cores count as cores."
  type        = number
  default     = 1
  nullable    = false
}

variable "cpu_units" {
  description = "CPU scheduler priority relative to other containers; higher values mean more CPU time when under contention."
  type        = number
  default     = 100
  nullable    = false
}

variable "memory_dedicated" {
  description = "RAM (in megabytes) dedicated to this container."
  type        = number
  default     = 1024
  nullable    = false
}

variable "imagestore_id" {
  description = "DataStore ID for the Debian template"
  type        = string
  default     = "pve-resources"
  nullable    = false
}

variable "disk_size" {
  description = "Size of the main container disk (in gigabytes)"
  type        = number
  default     = 2
  nullable    = false
}

variable "startup_order" {
  description = "Container startup order; shutdowns happen in reverse order"
  type        = number
  nullable    = false
}

variable "startup_up_delay" {
  description = "Delay (in seconds) before next container is started"
  type        = number
  default     = 20
  nullable    = false
}

variable "startup_down_delay" {
  description = "Delay (in seconds) before next container is shutdown"
  type        = number
  default     = 20
  nullable    = false
}

# Network configuration

variable "ni_ip" {
  description = "Network interface IP address"
  type        = string
  nullable    = false
}

variable "ni_gateway" {
  description = "Network interface gateway"
  type        = string
  nullable    = false
}

variable "ni_mac_address" {
  description = "Network interface MAC address"
  type        = string
  nullable    = false
}

variable "ni_subnet_mask" {
  description = "Network interface subnet mask in CIDR notation"
  type        = number
  default     = 24
  nullable    = false
}

variable "ni_name" {
  description = "Network interface name"
  type        = string
  default     = "eth0"
  nullable    = false
}

variable "ni_bridge" {
  description = "Network interface bridge"
  type        = string
  default     = "vmbr0"
  nullable    = false
}

# General container configuration

variable "packages" {
  description = "List of packages to install on the container"
  type        = list(string)
  default     = ["bash", "curl", "ca-certificates"]
  nullable    = false
}

variable "mount_points" {
  description = "List of mount points for the container"
  type = list(object({
    volume = string
    path   = string
  }))
  default  = []
  nullable = false
}

variable "update_interval" {
  type        = string
  description = "systemd OnCalendar expression for automatic updates, or 'never' to disable"
  default     = "Sun *-*-* 05:00:00"

  validation {
    condition     = var.update_interval == "never" || length(var.update_interval) > 0
    error_message = "update_interval must be 'never' or a non-empty systemd OnCalendar expression"
  }
}
