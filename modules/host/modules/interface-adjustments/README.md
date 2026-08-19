# Interface Adjustments

Persists per-interface OS-level tweaks on the Proxmox host that don't survive a reboot on
their own, via `/etc/network/interfaces.d/` drop-ins tied to each interface's own `post-up`
hook (`ifupdown2` reapplies these every time the interface comes up, boot included):

- `ethtool` advertised link modes, for NIC drivers (e.g. `ixgbe`/X550) that don't advertise
  their full hardware-supported mode set by default, silently capping negotiated speed even
  with a good cable and a capable link partner.
- Source-based routing, for dual-homed interfaces (e.g. a VLAN interface created by
  `network-bridges`) that deliberately have no gateway of their own, so replies to traffic
  addressed to them don't fall back to the system's main default route out the wrong interface.

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Resources](#resources)
  - _ssh_resource_.[push_nic_advertise_dropin](#ssh_resourcepush_nic_advertise_dropin)
  - _ssh_resource_.[push_response_route_dropin](#ssh_resourcepush_response_route_dropin)
  - _ssh_resource_.[remove_nic_advertise_dropins](#ssh_resourceremove_nic_advertise_dropins)
  - _ssh_resource_.[remove_response_route_dropins](#ssh_resourceremove_response_route_dropins)
- [Variables](#variables)
  - [ssh](#ssh-required) (**Required**)
  - [nic_link_advertise](#nic_link_advertise-optional) (*Optional*)
  - [response_routes](#response_routes-optional) (*Optional*)
- [Outputs](#outputs)
  - [nic_link_advertise](#nic_link_advertise)
  - [response_routes](#response_routes)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)

## Resources
  
<blockquote><!-- resource:"ssh_resource.push_nic_advertise_dropin":start -->

### _ssh_resource_.`push_nic_advertise_dropin`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L27"><code>main.tf#L27</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.push_nic_advertise_dropin":end -->
<blockquote><!-- resource:"ssh_resource.push_response_route_dropin":start -->

### _ssh_resource_.`push_response_route_dropin`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L65"><code>main.tf#L65</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.push_response_route_dropin":end -->
<blockquote><!-- resource:"ssh_resource.remove_nic_advertise_dropins":start -->

### _ssh_resource_.`remove_nic_advertise_dropins`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L48"><code>main.tf#L48</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.remove_nic_advertise_dropins":end -->
<blockquote><!-- resource:"ssh_resource.remove_response_route_dropins":start -->

### _ssh_resource_.`remove_response_route_dropins`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L92"><code>main.tf#L92</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.remove_response_route_dropins":end -->

## Variables
  
<blockquote><!-- variable:"ssh":start -->

### `ssh` (**Required**)

SSH configuration for remote connection

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  object({
    host    = string
    user    = string
    id_file = optional(string, "~/.ssh/id_rsa")
  })
  ```
  In file: <a href="./variables.tf#L1"><code>variables.tf#L1</code></a>

</details>
</blockquote><!-- variable:"ssh":end -->
<blockquote><!-- variable:"nic_link_advertise":start -->

### `nic_link_advertise` (*Optional*)

NICs that should have specific ethtool link modes force-advertised via a persistent /etc/network/interfaces.d/ drop-in

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(object({
    interface = string
    modes     = list(string)
  }))
  ```
  **Default**:
  ```json
  []
  ```
  In file: <a href="./variables.tf#L14"><code>variables.tf#L14</code></a>

</details>
</blockquote><!-- variable:"nic_link_advertise":end -->
<blockquote><!-- variable:"response_routes":start -->

### `response_routes` (*Optional*)

Per-interface source-based routing: traffic sourced from a specific address uses its own gateway, without disturbing the system's main default route - needed for dual-homed hosts where a secondary interface has no gateway of its own. Governs only how this host's own replies get routed back out; it has no bearing on who's allowed to reach it in the first place - that's the firewall's job entirely.

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(object({
    interface      = string
    source_address = string
    gateway        = string
    table_id       = number
    table_name     = string
    priority       = optional(number, 100)
  }))
  ```
  **Default**:
  ```json
  []
  ```
  In file: <a href="./variables.tf#L25"><code>variables.tf#L25</code></a>

</details>
</blockquote><!-- variable:"response_routes":end -->

## Outputs
  
<blockquote><!-- output:"nic_link_advertise":start -->

#### `nic_link_advertise`

Interfaces that had a persistent ethtool advertise drop-in applied, and which modes

In file: <a href="./outputs.tf#L1"><code>outputs.tf#L1</code></a>
</blockquote><!-- output:"nic_link_advertise":end -->
<blockquote><!-- output:"response_routes":start -->

#### `response_routes`

Interfaces that had a persistent source-routing drop-in applied, and via which gateway/table

In file: <a href="./outputs.tf#L6"><code>outputs.tf#L6</code></a>
</blockquote><!-- output:"response_routes":end -->