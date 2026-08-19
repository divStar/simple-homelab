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

variable "proxmox_node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "proxmox" {
  description = "Proxmox API connection details, separate from the SSH-based `ssh` variable - needed for `bpg/proxmox`-backed resources such as network bridges/VLANs"
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

variable "response_routes" {
  description = "Per-interface source-based routing: traffic sourced from a specific address uses its own gateway, without disturbing the system's main default route - needed for dual-homed hosts where a secondary interface has no gateway of its own. Governs only how sanctum's own replies get routed back out; it has no bearing on who's allowed to reach it in the first place - that's OPNsense's firewall's job entirely."
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

  validation {
    condition     = length(distinct([for route in var.response_routes : route.interface])) == length(var.response_routes)
    error_message = "Each response_routes entry must have a unique interface - it's used as a map key, so a duplicate would silently drop one entry instead of erroring."
  }

  validation {
    condition     = length(distinct([for route in var.response_routes : route.table_id])) == length(var.response_routes)
    error_message = "Each response_routes entry must have a unique table_id."
  }

  validation {
    condition     = length(distinct([for route in var.response_routes : route.table_name])) == length(var.response_routes)
    error_message = "Each response_routes entry must have a unique table_name."
  }

  validation {
    condition     = length(distinct([for route in var.response_routes : route.priority])) == length(var.response_routes)
    error_message = "Each response_routes entry must have a unique priority."
  }
}

variable "configuration_files" {
  description = "Configuration files to copy to the host"
  # @field item.source Source of the file on the system, that OpenTofu / Terraform is running on
  # @field item.destination Destination of the file on the host
  # @field item.permissions Permissions of the file to be set on the host
  # @field item.owner (optional) Owner of the file to be set on the host
  # @field item.group (optional) Group of the file to be set on the host
  type = list(object({
    source      = string
    destination = string
    permissions = optional(number)
    owner       = optional(string)
    group       = optional(string)
  }))
}

variable "packages" {
  description = "List of packages to install via apt-get"
  # @example ["git", "curl", "wget"]
  type    = list(string)
  default = []
}

variable "scripts" {
  description = "Configuration for script management including shared directory and script items"
  # @field directory Shared directory where all scripts will be downloaded to
  # @field items.name Name of the script file
  # @field items.url URL to download the script from
  # @field items.apply_params Parameters to pass when executing the script (defaults to "")
  # @field items.destroy_params Parameters to pass when cleaning up the script (defaults to "")
  # @field items.run_on_destroy Whether to execute the script with destroy_params before removal (defaults to true)
  # @example
  #   {
  #     directory = "/opt/scripts"
  #     items = [
  #       {
  #         name = "setup.sh"
  #         url = "https://example.com/setup.sh"
  #         apply_params = "--verbose"
  #       }
  #     ]
  #   }
  # @type object
  type = object({
    directory = optional(string, "scripts")
    items = list(object({
      name           = string
      url            = string
      apply_params   = optional(string, "")
      destroy_params = optional(string, "")
      run_on_destroy = optional(bool, true)
    }))
  })
  default = {
    directory = "scripts"
    items     = []
  }
}

variable "terraform_user" {
  description = "Configuration for Terraform provisioner user. Individual fields can be overridden."
  type = object({
    name    = optional(string, "terraform@pve")
    comment = optional(string, "Terraform automation user")
    role = object({
      name = optional(string, "TerraformProv")
      privileges = optional(list(string), [
        "VM.Allocate",
        "VM.Clone",
        "VM.Audit",
        "VM.Config.HWType",
        "VM.Config.Disk",
        "VM.Config.CPU",
        "VM.Config.Memory",
        "VM.Config.Network",
        "VM.Config.Cloudinit",
        "VM.Config.Options",
        "VM.PowerMgmt",
        "Datastore.Allocate",
        "Datastore.AllocateSpace",
        "Datastore.AllocateTemplate",
        "Datastore.Audit",
        "SDN.Use",
        "Sys.Audit",
        "Sys.Modify",
        "Mapping.Use",
        "Mapping.Modify"
      ])
    })
    token = object({
      name    = optional(string, "terraform-token")
      comment = optional(string, "Terraform automation user API token")
    })
  })

  default = {
    role  = {}
    token = {}
  }

  validation {
    condition = alltrue([
      for privilege in var.terraform_user.role.privileges :
      can(regex("^[A-Za-z]+\\.[A-Za-z]+(\\.?[A-Za-z]+)*$", privilege))
    ])
    error_message = "Each privilege must be in the format of 'Category.Action' or 'Category.Subcategory.Action'"
  }
}

variable "gitops_user" {
  description = "Configuration of GitOps user."
  type = object({
    user        = optional(string, "gitops")
    group       = optional(string, "gitops")
    repo_name   = optional(string, "repo")
    source_repo = optional(string, "/storage-pool/gitops")
  })

  default = {}
}

variable "org_source_repo_owner" {
  description = "Original owner of the source repository (before, e.g. root:root)"
  type = object({
    owner = optional(string, "root")
    group = optional(string, "root")
  })

  default = {}
}

variable "share_user" {
  description = "Configuration of GitOps user."

  type = object({
    user  = string
    group = string
    uid   = number
    gid   = number
  })

  default = {
    user  = "share-user"
    group = "share-users"
    uid   = 1400
    gid   = 1400
  }

  nullable = false
}

variable "no_subscription" {
  description = "Whether to use no-subscription repository instead of enterprise repository or not"
  type        = bool
  default     = true
}

variable "storage_pools" {
  description = "Configuration of the storage (pools and directories) to import"
  type        = list(string)
  default     = []
}

variable "storage_directories" {
  description = "Map of storage directories to configure; the key is the name of the directory."
  type = map(object({
    path    = string
    content = string
  }))
  default = {}
}

variable "nic_link_advertise" {
  description = "NICs that should have specific ethtool link modes force-advertised via a persistent /etc/network/interfaces.d/ drop-in - works around NIC drivers (e.g. ixgbe/X550) that don't advertise their full hardware-supported mode set by default, silently capping negotiated speed even with a good cable and a capable link partner."
  # @field interface Interface name (e.g. "enp193s0f1") - stable on Debian/Proxmox, derived from PCI topology rather than enumeration order
  # @field modes      Ordered list of ethtool link mode names to advertise (e.g. ["100baseT/Full", "1000baseT/Full", "2500baseT/Full", "5000baseT/Full", "10000baseT/Full"])
  type = list(object({
    interface = string
    modes     = list(string)
  }))
  default = []
}

variable "directory_mappings" {
  description = "Directory mappings for the Proxmox node"
  # @field id name of the directory-mapping
  # @field path path to the actual directory, that's to be mapped
  # @field comment comment for the directory-mapping
  type = list(object({
    id      = string
    path    = string
    comment = optional(string, "")
  }))
  default = []
}