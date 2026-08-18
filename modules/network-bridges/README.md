# Network Bridges

Handles the creation of Linux bridges on the Proxmox host.

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Resources](#resources)
  - _proxmox_network_linux_bridge_.[this](#proxmox_network_linux_bridgethis)
- [Variables](#variables)
  - [proxmox](#proxmox-required) (**Required**)
  - [proxmox_node_name](#proxmox_node_name-required) (**Required**)
  - [bridges](#bridges-optional) (*Optional*)
- [Outputs](#outputs)
  - [bridges](#bridges)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![bpg/proxmox](https://img.shields.io/badge/bpg--proxmox->=0.111.1-1e73c8?logo=proxmox)

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
      <td><a href="./main.tf#L10"><code>main.tf#L10</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"proxmox_network_linux_bridge.this":end -->

## Variables
  
<blockquote><!-- variable:"proxmox":start -->

### `proxmox` (**Required**)

Proxmox host configuration

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  object({
    name     = string
    host     = string
    ssh_user = string
    ssh_key  = string
    insecure = bool
    username = string
    password = string
  })
  ```
  In file: <a href="./variables.tf#L1"><code>variables.tf#L1</code></a>

</details>
</blockquote><!-- variable:"proxmox":end -->
<blockquote><!-- variable:"proxmox_node_name":start -->

### `proxmox_node_name` (**Required**)

Proxmox node name

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L16"><code>variables.tf#L16</code></a>

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
  In file: <a href="./variables.tf#L21"><code>variables.tf#L21</code></a>

</details>
</blockquote><!-- variable:"bridges":end -->

## Outputs
  
<blockquote><!-- output:"bridges":start -->

#### `bridges`

Linux bridges created on the Proxmox host, keyed by name

In file: <a href="./outputs.tf#L1"><code>outputs.tf#L1</code></a>
</blockquote><!-- output:"bridges":end -->