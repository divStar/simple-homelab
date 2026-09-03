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

variable "network_interfaces" {
  description = "Network interfaces for the container. The first entry is the primary interface (net0); any further entries dual-home the container onto additional networks (e.g. a second VLAN) and are left gateway-less unless one is explicitly given. `response_route`, if set, adds source-based routing (a dedicated table + an `ip rule from <this interface's ip>`) so replies to traffic addressed to this interface go back out via its own gateway instead of falling through to the primary interface's default route - without it, only same-subnet peers of this interface can actually reach it."
  type = list(object({
    name        = string
    bridge      = string
    mac_address = string
    ip          = string
    subnet_mask = optional(number, 24)
    vlan_id     = optional(number)
    gateway     = optional(string)
    response_route = optional(object({
      gateway    = string
      table_id   = number
      table_name = string
      priority   = optional(number, 100)
    }))
  }))
  nullable = false

  validation {
    condition     = length(var.network_interfaces) > 0
    error_message = "network_interfaces must contain at least one entry (the primary interface)."
  }

  validation {
    condition     = length([for ni in var.network_interfaces : ni if ni.gateway != null]) <= 1
    error_message = "At most one network_interfaces entry may set `gateway` - a second unqualified default route conflicts with the primary interface's (confirmed footgun, not a hypothetical). Use `response_route` for source-based routing on secondary interfaces instead."
  }
}

variable "provisioning_interface_index" {
  description = "Index into network_interfaces that Terraform's own SSH provisioning connects to. Defaults to the primary interface (0); change only if that one isn't reachable from wherever `tofu apply` runs."
  type        = number
  default     = 0
  nullable    = false

  validation {
    condition     = var.provisioning_interface_index >= 0 && var.provisioning_interface_index < length(var.network_interfaces)
    error_message = "provisioning_interface_index must be a valid index into network_interfaces."
  }
}

variable "dns_servers" {
  description = "DNS servers for the container's /etc/resolv.conf, in order. Defaults to null, which leaves Proxmox's own per-node default in place (not something this module should silently override for every consumer - callers on a network without their own DHCP-provided DNS need to set this explicitly)."
  type        = list(string)
  default     = null
}

variable "dns_search_domain" {
  description = "DNS search domain for the container. Defaults to null (Proxmox's own default)."
  type        = string
  default     = null
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
