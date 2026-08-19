# Network Bridges

Handles the creation of Linux bridges and VLAN interfaces on the Proxmox host. Uses the
`proxmox` provider inherited from the parent `host` module - no provider configuration of its
own.

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Resources](#resources)
  - _proxmox_network_linux_bridge_.[this](#proxmox_network_linux_bridgethis)
  - _proxmox_network_linux_vlan_.[this](#proxmox_network_linux_vlanthis)
- [Variables](#variables)
  - [proxmox_node_name](#proxmox_node_name-required) (**Required**)
  - [bridges](#bridges-optional) (*Optional*)
  - [vlan_interfaces](#vlan_interfaces-optional) (*Optional*)
- [Outputs](#outputs)
  - [bridges](#bridges)
  - [vlan_interfaces](#vlan_interfaces)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)

## Resources
  
<blockquote><!-- resource:"proxmox_network_linux_bridge.this":start -->

### _proxmox_network_linux_bridge_.`this`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>proxmox (bpg/proxmox)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L8"><code>main.tf#L8</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"proxmox_network_linux_bridge.this":end -->
<blockquote><!-- resource:"proxmox_network_linux_vlan.this":start -->

### _proxmox_network_linux_vlan_.`this`

Depends on every bridge, not just the one a given VLAN interface's name implies, since that relationship only exists inside a string (e.g. "vmbr1.5") that OpenTofu has no native way to parse - without this, a from-scratch apply has no guarantee the parent bridge is created first.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>proxmox (bpg/proxmox)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L26"><code>main.tf#L26</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"proxmox_network_linux_vlan.this":end -->

## Variables
  
<blockquote><!-- variable:"proxmox_node_name":start -->

### `proxmox_node_name` (**Required**)

Proxmox node name

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L1"><code>variables.tf#L1</code></a>

</details>
</blockquote><!-- variable:"proxmox_node_name":end -->
<blockquote><!-- variable:"bridges":start -->

### `bridges` (*Optional*)

Linux bridges to create on the Proxmox host

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(object({
    name       = string
    ports      = list(string)
    vlan_aware = optional(bool, false)
    vids       = optional(string, "2-4094")
    comment    = optional(string, "")
    address    = optional(string)
    autostart  = optional(bool, true)
  }))
  ```
  **Default**:
  ```json
  []
  ```
  In file: <a href="./variables.tf#L6"><code>variables.tf#L6</code></a>

</details>
</blockquote><!-- variable:"bridges":end -->
<blockquote><!-- variable:"vlan_interfaces":start -->

### `vlan_interfaces` (*Optional*)

VLAN-tagged sub-interfaces to create on the Proxmox host, giving it a presence on a specific VLAN over an existing VLAN-aware bridge

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(object({
    name      = string
    address   = string
    gateway   = optional(string)
    comment   = optional(string, "")
    autostart = optional(bool, true)
  }))
  ```
  **Default**:
  ```json
  []
  ```
  In file: <a href="./variables.tf#L27"><code>variables.tf#L27</code></a>

</details>
</blockquote><!-- variable:"vlan_interfaces":end -->

## Outputs
  
<blockquote><!-- output:"bridges":start -->

#### `bridges`

Linux bridges created on the Proxmox host, keyed by name

In file: <a href="./outputs.tf#L1"><code>outputs.tf#L1</code></a>
</blockquote><!-- output:"bridges":end -->
<blockquote><!-- output:"vlan_interfaces":start -->

#### `vlan_interfaces`

VLAN interfaces created on the Proxmox host, keyed by name

In file: <a href="./outputs.tf#L11"><code>outputs.tf#L11</code></a>
</blockquote><!-- output:"vlan_interfaces":end -->