variable "proxmox_node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "bridges" {
  description = "Linux bridges to create on the Proxmox host"
  # @field name Bridge interface name (e.g. "vmbr1")
  # @field ports Physical NIC(s) to attach as bridge members - each port should lead to a physically separate, non-interconnected destination (e.g. a different room); this module configures no STP/bonding, so two ports reaching the same switch will loop
  # @field vlan_aware Whether to enable 802.1Q VLAN tagging support on this bridge
  # @field vids Space-separated list of VLAN IDs and/or hyphenated ranges allowed on this bridge; only relevant when vlan_aware is true
  # @field comment Optional comment for the bridge
  # @field address Optional IPv4 address (CIDR) for the bridge itself, if the host needs a presence on it
  # @field autostart Whether the bridge should come up automatically on boot
  type = list(object({
    name       = string
    ports      = list(string)
    vlan_aware = optional(bool, false)
    vids       = optional(string, "2-4094")
    comment    = optional(string, "")
    address    = optional(string)
    autostart  = optional(bool, true)
  }))
  default = []
}

variable "vlan_interfaces" {
  description = "VLAN-tagged sub-interfaces to create on the Proxmox host, giving it a presence on a specific VLAN over an existing VLAN-aware bridge"
  # @field name      Interface name as "<bridge>.<vlan>" (e.g. "vmbr1.5") - the VLAN tag is inferred from the name, the parent bridge must already exist
  # @field address   IPv4 address (CIDR) for the host on this VLAN
  # @field gateway   Optional default gateway - leave unset to avoid creating a second default route on a dual-homed host
  # @field comment   Optional comment
  # @field autostart Whether the interface comes up automatically on boot
  type = list(object({
    name      = string
    address   = string
    gateway   = optional(string)
    comment   = optional(string, "")
    autostart = optional(bool, true)
  }))
  default = []
}
