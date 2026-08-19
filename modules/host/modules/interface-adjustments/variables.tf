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

variable "nic_link_advertise" {
  description = "NICs that should have specific ethtool link modes force-advertised via a persistent /etc/network/interfaces.d/ drop-in"
  # @field interface Interface name (e.g. "enp193s0f1") - stable on Debian/Proxmox since it's derived from PCI topology, not enumeration order
  # @field modes      Ordered list of ethtool link mode names to advertise (e.g. ["100baseT/Full", "1000baseT/Full", "2500baseT/Full", "5000baseT/Full", "10000baseT/Full"])
  type = list(object({
    interface = string
    modes     = list(string)
  }))
  default = []
}

variable "response_routes" {
  description = "Per-interface source-based routing: traffic sourced from a specific address uses its own gateway, without disturbing the system's main default route - needed for dual-homed hosts where a secondary interface has no gateway of its own. Governs only how this host's own replies get routed back out; it has no bearing on who's allowed to reach it in the first place - that's the firewall's job entirely."
  # @field interface      Interface name whose bring-up should trigger this (e.g. "vmbr1.5")
  # @field source_address The source IP that should be routed via this table (e.g. "10.0.5.3")
  # @field gateway         Gateway for this source's traffic (e.g. "10.0.5.1")
  # @field table_id        Numeric routing table ID to register in /etc/iproute2/rt_tables (must be unique across all entries)
  # @field table_name      Name for that routing table (must be unique across all entries)
  # @field priority        ip rule priority - lower is evaluated first, must be unique across all entries
  type = list(object({
    interface      = string
    source_address = string
    gateway        = string
    table_id       = number
    table_name     = string
    priority       = optional(number, 100)
  }))
  default = []
}
