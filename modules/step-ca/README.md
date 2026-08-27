# Step-CA Setup

This module sets up Step-CA in an Alpine LXC container using the provided information.

<!-- docs-meta: order=30 icon=step-ca -->

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Modules](#modules) _(nested and adjacent)_
  - [setup_container](#setup_container)
- [Resources](#resources)
  - _ssh_resource_.[configure_container](#ssh_resourceconfigure_container)
  - _ssh_resource_.[configure_host](#ssh_resourceconfigure_host)
  - _ssh_resource_.[revert_host](#ssh_resourcerevert_host)
  - _terraform_data_.[container_trigger](#terraform_datacontainer_trigger)
- [Variables](#variables)
  - [acme](#acme-required) (**Required**)
  - [proxmox](#proxmox-required) (**Required**)
  - [fingerprint_file](#fingerprint_file-optional) (*Optional*)
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
      <td><a href="./main.tf#L51"><code>main.tf#L51</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="../common/modules/alpine/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"setup_container":end -->

## Resources
  
<blockquote><!-- resource:"ssh_resource.configure_container":start -->

### _ssh_resource_.`configure_container`

Configure Step-CA
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L82"><code>main.tf#L82</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.configure_container":end -->
<blockquote><!-- resource:"ssh_resource.configure_host":start -->

### _ssh_resource_.`configure_host`

Configure ACME domain and order certificates
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L113"><code>main.tf#L113</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.configure_host":end -->
<blockquote><!-- resource:"ssh_resource.revert_host":start -->

### _ssh_resource_.`revert_host`

ACME Cleanup on destroy
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L153"><code>main.tf#L153</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.revert_host":end -->
<blockquote><!-- resource:"terraform_data.container_trigger":start -->

### _terraform_data_.`container_trigger`

Wraps container_id into a valid replace_triggered_by target (module outputs alone aren't). Only configure_container needs it - configure_host/revert_host hit the Proxmox host, not the container.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>terraform (hashicorp/terraform)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L77"><code>main.tf#L77</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"terraform_data.container_trigger":end -->

## Variables
  
<blockquote><!-- variable:"acme":start -->

### `acme` (**Required**)

ACME configuration

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  object({
    contact         = string
    name            = string
    proxmox_domains = list(string)
  })
  ```
  In file: <a href="./variables.tf#L17"><code>variables.tf#L17</code></a>

</details>
</blockquote><!-- variable:"acme":end -->
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
<blockquote><!-- variable:"fingerprint_file":start -->

### `fingerprint_file` (*Optional*)

File containing the fingerprint

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  ""
  ```
  In file: <a href="./variables.tf#L29"><code>variables.tf#L29</code></a>

</details>
</blockquote><!-- variable:"fingerprint_file":end -->

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