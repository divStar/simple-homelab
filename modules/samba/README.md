# Samba Setup

This module sets up Samba server in an Alpine LXC container using the provided information.

<!-- docs-meta: order=30 icon=samba -->

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Modules](#modules) _(nested and adjacent)_
  - [setup_container](#setup_container)
- [Resources](#resources)
  - _ssh_resource_.[configure_samba](#ssh_resourceconfigure_samba)
  - _ssh_resource_.[configure_users](#ssh_resourceconfigure_users)
  - _terraform_data_.[container_trigger](#terraform_datacontainer_trigger)
  - _terraform_data_.[users_trigger](#terraform_datausers_trigger)
- [Variables](#variables)
  - [proxmox](#proxmox-required) (**Required**)
  - [samba_users](#samba_users-required) (**Required**)
- [Outputs](#outputs)
  - [root_password](#root_password)
  - [ssh_private_key](#ssh_private_key)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![proxmox](https://img.shields.io/badge/proxmox->=0.111.1-1e73c8?logo=proxmox)
![random](https://img.shields.io/badge/random->=3.9.0-82d72c?logo=random)
![loafoe/ssh](https://img.shields.io/badge/loafoe--ssh->=2.7.0-4fa4f9?logo=ssh)
![tls](https://img.shields.io/badge/tls->=4.3.0-54a9fe?logo=tls)

## Modules
  
<blockquote><!-- module:"setup_container":start -->

### `setup_container`

Alpine LXC container setup
  <table>
    <tr>
      <td>Module location</td>
      <td><code>../common/modules/alpine</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L16"><code>main.tf#L16</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="../common/modules/alpine/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"setup_container":end -->

## Resources
  
<blockquote><!-- resource:"ssh_resource.configure_samba":start -->

### _ssh_resource_.`configure_samba`

Deploy Samba configuration
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L75"><code>main.tf#L75</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.configure_samba":end -->
<blockquote><!-- resource:"ssh_resource.configure_users":start -->

### _ssh_resource_.`configure_users`

Create system users, set Samba passwords, and configure the shared write group
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L103"><code>main.tf#L103</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.configure_users":end -->
<blockquote><!-- resource:"terraform_data.container_trigger":start -->

### _terraform_data_.`container_trigger`

Trigger for container replacement - module outputs aren't valid replace_triggered_by references on their own (only resources are), hence wrapping it the same way users_trigger wraps var.samba_users above. Same triggers_replace requirement as users_trigger above, for the same reason.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>terraform (hashicorp/terraform)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L70"><code>main.tf#L70</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"terraform_data.container_trigger":end -->
<blockquote><!-- resource:"terraform_data.users_trigger":start -->

### _terraform_data_.`users_trigger`

Trigger for user list changes. Uses triggers_replace, NOT input -- input-only changes make terraform_data update in-place, which leaves its own .id unchanged (only regenerated on a real create/replace of the terraform_data resource itself). Since every replace_triggered_by below references .id, using plain `input` here meant a samba_users change silently never actually triggered reprovisioning -- confirmed via `tofu plan -replace` while fixing the identical bug in modules/pbs-lxc's container_trigger, 2026-08-09.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>terraform (hashicorp/terraform)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L62"><code>main.tf#L62</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"terraform_data.users_trigger":end -->

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
  In file: <a href="./variables.tf#L2"><code>variables.tf#L2</code></a>

</details>
</blockquote><!-- variable:"proxmox":end -->
<blockquote><!-- variable:"samba_users":start -->

### `samba_users` (**Required**)

List of Samba users with their passwords

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(object({
    username = string
    password = string
  }))
  ```
  In file: <a href="./variables.tf#L17"><code>variables.tf#L17</code></a>

</details>
</blockquote><!-- variable:"samba_users":end -->

## Outputs
  
<blockquote><!-- output:"root_password":start -->

#### `root_password`

Root password

In file: <a href="./outputs.tf#L2"><code>outputs.tf#L2</code></a>
</blockquote><!-- output:"root_password":end -->
<blockquote><!-- output:"ssh_private_key":start -->

#### `ssh_private_key`

Private SSH key

In file: <a href="./outputs.tf#L9"><code>outputs.tf#L9</code></a>
</blockquote><!-- output:"ssh_private_key":end -->