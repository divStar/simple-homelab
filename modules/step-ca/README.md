# Step-CA Setup

This module sets up Step-CA in an Alpine LXC container using the provided information.

## Contents

<blockquote><!-- contents:start -->

- [Requirements](#requirements)
- [Providers](#providers)
- [Modules](#modules) _(nested and adjacent)_
  - [setup_container](#setup_container)
- [Resources](#resources)
  - _ssh_resource_.[configure_container](#ssh_resourceconfigure_container)
  - _ssh_resource_.[configure_host](#ssh_resourceconfigure_host)
  - _ssh_resource_.[revert_host](#ssh_resourcerevert_host)
- [Variables](#variables)
  - [imagestore_id](#imagestore_id-required) (**Required**)
  - [mount_points](#mount_points-required) (**Required**)
  - [proxmox_endpoint](#proxmox_endpoint-required) (**Required**)
  - [proxmox_host](#proxmox_host-required) (**Required**)
  - [proxmox_node_name](#proxmox_node_name-required) (**Required**)
  - [proxmox_password](#proxmox_password-required) (**Required**)
  - [proxmox_ssh_key](#proxmox_ssh_key-required) (**Required**)
  - [proxmox_ssh_user](#proxmox_ssh_user-required) (**Required**)
  - [acme_contact](#acme_contact-optional) (*Optional*)
  - [acme_name](#acme_name-optional) (*Optional*)
  - [acme_proxmox_domains](#acme_proxmox_domains-optional) (*Optional*)
  - [description](#description-optional) (*Optional*)
  - [fingerprint_file](#fingerprint_file-optional) (*Optional*)
  - [hostname](#hostname-optional) (*Optional*)
  - [ni_bridge](#ni_bridge-optional) (*Optional*)
  - [ni_gateway](#ni_gateway-optional) (*Optional*)
  - [ni_ip](#ni_ip-optional) (*Optional*)
  - [ni_mac_address](#ni_mac_address-optional) (*Optional*)
  - [ni_name](#ni_name-optional) (*Optional*)
  - [ni_subnet_mask](#ni_subnet_mask-optional) (*Optional*)
  - [proxmox_insecure](#proxmox_insecure-optional) (*Optional*)
  - [skip_host_configuration](#skip_host_configuration-optional) (*Optional*)
  - [startup_order](#startup_order-optional) (*Optional*)
  - [tags](#tags-optional) (*Optional*)
  - [vm_id](#vm_id-optional) (*Optional*)
- [Outputs](#outputs)
  - [root_password](#root_password)
  - [ssh_private_key](#ssh_private_key)
</blockquote><!-- contents:end -->

## Requirements
![opentofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![proxmox](https://img.shields.io/badge/proxmox->=0.85.1-1e73c8?logo=proxmox)
![random](https://img.shields.io/badge/random->=3.7.2-82d72c?logo=random)
![ssh](https://img.shields.io/badge/loafoe--ssh->=2.7.0-4fa4f9?logo=ssh)

## Providers
![loafoe/ssh](https://img.shields.io/badge/loafoe--ssh->=2.7.0-4fa4f9)

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
      <td><a href="./main.tf#L14"><code>main.tf#L14</code></a></td>
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
      <td><a href="./main.tf#L38"><code>main.tf#L38</code></a></td>
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
      <td><a href="./main.tf#L73"><code>main.tf#L73</code></a></td>
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
      <td><a href="./main.tf#L113"><code>main.tf#L113</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.revert_host":end -->

## Variables
  
<blockquote><!-- variable:"imagestore_id":start -->

### `imagestore_id` (**Required**)

Step-CA imagestore ID

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L75"><code>variables.tf#L75</code></a>

</details>
</blockquote><!-- variable:"imagestore_id":end -->
<blockquote><!-- variable:"mount_points":start -->

### `mount_points` (**Required**)

List of mount points for the container

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(object({
    volume = string
    path   = string
  }))
  ```
  In file: <a href="./variables.tf#L66"><code>variables.tf#L66</code></a>

</details>
</blockquote><!-- variable:"mount_points":end -->
<blockquote><!-- variable:"proxmox_endpoint":start -->

### `proxmox_endpoint` (**Required**)

Proxmox API endpoint (e.g. https://pve.local:8006)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L2"><code>variables.tf#L2</code></a>

</details>
</blockquote><!-- variable:"proxmox_endpoint":end -->
<blockquote><!-- variable:"proxmox_host":start -->

### `proxmox_host` (**Required**)

Proxmox API host (e.g. pve.local or 192.168.178.37)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L7"><code>variables.tf#L7</code></a>

</details>
</blockquote><!-- variable:"proxmox_host":end -->
<blockquote><!-- variable:"proxmox_node_name":start -->

### `proxmox_node_name` (**Required**)

Proxmox node name

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L12"><code>variables.tf#L12</code></a>

</details>
</blockquote><!-- variable:"proxmox_node_name":end -->
<blockquote><!-- variable:"proxmox_password":start -->

### `proxmox_password` (**Required**)

Proxmox 'root' user password (API token does NOT work)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L17"><code>variables.tf#L17</code></a>

</details>
</blockquote><!-- variable:"proxmox_password":end -->
<blockquote><!-- variable:"proxmox_ssh_key":start -->

### `proxmox_ssh_key` (**Required**)

Proxmox SSH key

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L27"><code>variables.tf#L27</code></a>

</details>
</blockquote><!-- variable:"proxmox_ssh_key":end -->
<blockquote><!-- variable:"proxmox_ssh_user":start -->

### `proxmox_ssh_user` (**Required**)

Proxmox SSH user

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L22"><code>variables.tf#L22</code></a>

</details>
</blockquote><!-- variable:"proxmox_ssh_user":end -->
<blockquote><!-- variable:"acme_contact":start -->

### `acme_contact` (*Optional*)

E-Mail address of the ACME account in Proxmox

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "admin@my.world"
  ```
  In file: <a href="./variables.tf#L132"><code>variables.tf#L132</code></a>

</details>
</blockquote><!-- variable:"acme_contact":end -->
<blockquote><!-- variable:"acme_name":start -->

### `acme_name` (*Optional*)

ACME account name

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "step-ca-acme"
  ```
  In file: <a href="./variables.tf#L139"><code>variables.tf#L139</code></a>

</details>
</blockquote><!-- variable:"acme_name":end -->
<blockquote><!-- variable:"acme_proxmox_domains":start -->

### `acme_proxmox_domains` (*Optional*)

Proxmox ACME domains to order certificates for

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(string)
  ```
  **Default**:
  ```json
  [
  "sanctum.my.world"
]
  ```
  In file: <a href="./variables.tf#L146"><code>variables.tf#L146</code></a>

</details>
</blockquote><!-- variable:"acme_proxmox_domains":end -->
<blockquote><!-- variable:"description":start -->

### `description` (*Optional*)

Description of the container

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "Alpine Linux based LXC container with Step-CA"
  ```
  In file: <a href="./variables.tf#L52"><code>variables.tf#L52</code></a>

</details>
</blockquote><!-- variable:"description":end -->
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
  In file: <a href="./variables.tf#L154"><code>variables.tf#L154</code></a>

</details>
</blockquote><!-- variable:"fingerprint_file":end -->
<blockquote><!-- variable:"hostname":start -->

### `hostname` (*Optional*)

Step-CA host name

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "step-ca"
  ```
  In file: <a href="./variables.tf#L45"><code>variables.tf#L45</code></a>

</details>
</blockquote><!-- variable:"hostname":end -->
<blockquote><!-- variable:"ni_bridge":start -->

### `ni_bridge` (*Optional*)

Network interface bridge

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "vmbr0"
  ```
  In file: <a href="./variables.tf#L124"><code>variables.tf#L124</code></a>

</details>
</blockquote><!-- variable:"ni_bridge":end -->
<blockquote><!-- variable:"ni_gateway":start -->

### `ni_gateway` (*Optional*)

Network interface gateway

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "192.168.178.1"
  ```
  In file: <a href="./variables.tf#L96"><code>variables.tf#L96</code></a>

</details>
</blockquote><!-- variable:"ni_gateway":end -->
<blockquote><!-- variable:"ni_ip":start -->

### `ni_ip` (*Optional*)

Network interface IP address

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "192.168.178.155"
  ```
  In file: <a href="./variables.tf#L89"><code>variables.tf#L89</code></a>

</details>
</blockquote><!-- variable:"ni_ip":end -->
<blockquote><!-- variable:"ni_mac_address":start -->

### `ni_mac_address` (*Optional*)

Network interface MAC address

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "E8:31:0E:A5:D8:4C"
  ```
  In file: <a href="./variables.tf#L103"><code>variables.tf#L103</code></a>

</details>
</blockquote><!-- variable:"ni_mac_address":end -->
<blockquote><!-- variable:"ni_name":start -->

### `ni_name` (*Optional*)

Network interface name

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "eth0"
  ```
  In file: <a href="./variables.tf#L117"><code>variables.tf#L117</code></a>

</details>
</blockquote><!-- variable:"ni_name":end -->
<blockquote><!-- variable:"ni_subnet_mask":start -->

### `ni_subnet_mask` (*Optional*)

Network interface subnet mask in CIDR notation

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  number
  ```
  **Default**:
  ```json
  24
  ```
  In file: <a href="./variables.tf#L110"><code>variables.tf#L110</code></a>

</details>
</blockquote><!-- variable:"ni_subnet_mask":end -->
<blockquote><!-- variable:"proxmox_insecure":start -->

### `proxmox_insecure` (*Optional*)

Skip TLS verification

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  bool
  ```
  **Default**:
  ```json
  true
  ```
  In file: <a href="./variables.tf#L32"><code>variables.tf#L32</code></a>

</details>
</blockquote><!-- variable:"proxmox_insecure":end -->
<blockquote><!-- variable:"skip_host_configuration":start -->

### `skip_host_configuration` (*Optional*)

Controls whether the Proxmox host will be configured with ACME or not

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  bool
  ```
  **Default**:
  ```json
  false
  ```
  In file: <a href="./variables.tf#L161"><code>variables.tf#L161</code></a>

</details>
</blockquote><!-- variable:"skip_host_configuration":end -->
<blockquote><!-- variable:"startup_order":start -->

### `startup_order` (*Optional*)

Container startup order; shutdowns happen in reverse order

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  number
  ```
  **Default**:
  ```json
  1
  ```
  In file: <a href="./variables.tf#L81"><code>variables.tf#L81</code></a>

</details>
</blockquote><!-- variable:"startup_order":end -->
<blockquote><!-- variable:"tags":start -->

### `tags` (*Optional*)

Tags

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(string)
  ```
  **Default**:
  ```json
  [
  "alpine",
  "lxc",
  "pve-resources"
]
  ```
  In file: <a href="./variables.tf#L59"><code>variables.tf#L59</code></a>

</details>
</blockquote><!-- variable:"tags":end -->
<blockquote><!-- variable:"vm_id":start -->

### `vm_id` (*Optional*)

Step-CA VM ID

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  number
  ```
  **Default**:
  ```json
  701
  ```
  In file: <a href="./variables.tf#L38"><code>variables.tf#L38</code></a>

</details>
</blockquote><!-- variable:"vm_id":end -->

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