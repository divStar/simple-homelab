# NIC Link Advertise

Persists explicit `ethtool` advertised link modes per NIC via an `/etc/network/interfaces.d/`
drop-in, so drivers that don't advertise their full hardware-supported mode set by default
(e.g. `ixgbe`/X550 skipping NBASE-T 2.5G/5G) don't silently cap negotiated speed below what
both the NIC and its link partner actually support. Runtime-only `ethtool -s` changes don't
survive a reboot; this makes the setting reapply every time the interface comes up via
`ifupdown2`'s own `post-up` hook, boot included.

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Resources](#resources)
  - _ssh_resource_.[push_nic_advertise_dropin](#ssh_resourcepush_nic_advertise_dropin)
  - _ssh_resource_.[remove_nic_advertise_dropins](#ssh_resourceremove_nic_advertise_dropins)
- [Variables](#variables)
  - [ssh](#ssh-required) (**Required**)
  - [nic_link_advertise](#nic_link_advertise-optional) (*Optional*)
- [Outputs](#outputs)
  - [nic_link_advertise](#nic_link_advertise)
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
      <td><a href="./main.tf#L22"><code>main.tf#L22</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.push_nic_advertise_dropin":end -->
<blockquote><!-- resource:"ssh_resource.remove_nic_advertise_dropins":start -->

### _ssh_resource_.`remove_nic_advertise_dropins`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L43"><code>main.tf#L43</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.remove_nic_advertise_dropins":end -->

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

## Outputs
  
<blockquote><!-- output:"nic_link_advertise":start -->

#### `nic_link_advertise`

Interfaces that had a persistent ethtool advertise drop-in applied, and which modes

In file: <a href="./outputs.tf#L1"><code>outputs.tf#L1</code></a>
</blockquote><!-- output:"nic_link_advertise":end -->