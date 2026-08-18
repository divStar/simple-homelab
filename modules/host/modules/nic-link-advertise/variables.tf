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
