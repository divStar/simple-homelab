# Alpine LXC container setup

This module creates an Alpine LXC container on the Proxmox host,
generates a `root_password` and a `ssh_key`, installs `openssh` as well as
other Alpine packages (if specified; `bash` is installed by default).

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Resources](#resources)
  - _proxmox_download_file_.[template](#proxmox_download_filetemplate)
  - _proxmox_virtual_environment_container_.[container](#proxmox_virtual_environment_containercontainer)
  - _random_password_.[root_password](#random_passwordroot_password)
  - _ssh_resource_.[configure_response_routes](#ssh_resourceconfigure_response_routes)
  - _ssh_resource_.[install_default_aliases](#ssh_resourceinstall_default_aliases)
  - _ssh_resource_.[install_openssh](#ssh_resourceinstall_openssh)
  - _ssh_resource_.[install_packages](#ssh_resourceinstall_packages)
  - _ssh_resource_.[install_update_upgrade_scripts](#ssh_resourceinstall_update_upgrade_scripts)
  - _ssh_resource_.[remove_response_routes](#ssh_resourceremove_response_routes)
  - _tls_private_key_.[ssh_key](#tls_private_keyssh_key)
- [Variables](#variables)
  - [hostname](#hostname-required) (**Required**)
  - [network_interfaces](#network_interfaces-required) (**Required**)
  - [proxmox](#proxmox-required) (**Required**)
  - [startup_order](#startup_order-required) (**Required**)
  - [vm_id](#vm_id-required) (**Required**)
  - [alpine_image](#alpine_image-optional) (*Optional*)
  - [cpu_cores](#cpu_cores-optional) (*Optional*)
  - [cpu_units](#cpu_units-optional) (*Optional*)
  - [description](#description-optional) (*Optional*)
  - [disk_size](#disk_size-optional) (*Optional*)
  - [dns_search_domain](#dns_search_domain-optional) (*Optional*)
  - [dns_servers](#dns_servers-optional) (*Optional*)
  - [imagestore_id](#imagestore_id-optional) (*Optional*)
  - [memory_dedicated](#memory_dedicated-optional) (*Optional*)
  - [mount_points](#mount_points-optional) (*Optional*)
  - [packages](#packages-optional) (*Optional*)
  - [provisioning_interface_index](#provisioning_interface_index-optional) (*Optional*)
  - [startup_down_delay](#startup_down_delay-optional) (*Optional*)
  - [startup_up_delay](#startup_up_delay-optional) (*Optional*)
  - [tags](#tags-optional) (*Optional*)
  - [unprivileged](#unprivileged-optional) (*Optional*)
  - [update_interval](#update_interval-optional) (*Optional*)
- [Outputs](#outputs)
  - [container_id](#container_id)
  - [root_password](#root_password)
  - [ssh_private_key](#ssh_private_key)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![bpg/proxmox](https://img.shields.io/badge/bpg--proxmox->=0.111.1-1e73c8?logo=proxmox)
![hashicorp/random](https://img.shields.io/badge/hashicorp--random->=3.9.0-82d72c?logo=random)
![loafoe/ssh](https://img.shields.io/badge/loafoe--ssh->=2.7-4fa4f9?logo=ssh)
![hashicorp/tls](https://img.shields.io/badge/hashicorp--tls->=4.3.0-54a9fe?logo=tls)

## Resources
  
<blockquote><!-- resource:"proxmox_download_file.template":start -->

### _proxmox_download_file_.`template`

Downloads the `alpine` image.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>proxmox (bpg/proxmox)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L24"><code>main.tf#L24</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"proxmox_download_file.template":end -->
<blockquote><!-- resource:"proxmox_virtual_environment_container.container":start -->

### _proxmox_virtual_environment_container_.`container`

Create Alpine LXC container
  <table>
    <tr>
      <td>Provider</td>
      <td><code>proxmox (bpg/proxmox)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L47"><code>main.tf#L47</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"proxmox_virtual_environment_container.container":end -->
<blockquote><!-- resource:"random_password.root_password":start -->

### _random_password_.`root_password`

Generate a random password for the container
  <table>
    <tr>
      <td>Provider</td>
      <td><code>random (hashicorp/random)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L40"><code>main.tf#L40</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"random_password.root_password":end -->
<blockquote><!-- resource:"ssh_resource.configure_response_routes":start -->

### _ssh_resource_.`configure_response_routes`

Source-based routing for secondary interfaces, via ifupdown-ng's native if-up.d/if-down.d hook directories (confirmed these are the only split-config convention this package actually ships - no interfaces.d equivalent exists or is documented for ifupdown-ng, unlike Debian's ifupdown2, so this deliberately stays script-based rather than borrowing Debian's convention).  `ifdown <iface>` then `ifup -f <iface>` is the confirmed-reliable way to make these hooks fire immediately for an interface that's already up (needed since the interface came up once before this hook existed to catch that first ifup): live-tested that `ifup -f` alone does NOT reliably re-fire if-up.d hooks on an already-up interface (a pushed marker script silently never ran), while a real down-then-up cycle does (marker fired, table 10 correctly repopulated). Also avoids a stale/duplicate address lingering if the address itself ever changes - `ifup -f` alone doesn't necessarily clear the old one first.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L275"><code>main.tf#L275</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.configure_response_routes":end -->
<blockquote><!-- resource:"ssh_resource.install_default_aliases":start -->

### _ssh_resource_.`install_default_aliases`

Install default aliases
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L344"><code>main.tf#L344</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.install_default_aliases":end -->
<blockquote><!-- resource:"ssh_resource.install_openssh":start -->

### _ssh_resource_.`install_openssh`

Install OpenSSH into the Alpine LXC container
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L155"><code>main.tf#L155</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.install_openssh":end -->
<blockquote><!-- resource:"ssh_resource.install_packages":start -->

### _ssh_resource_.`install_packages`

Install necessary Alpine packages
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L236"><code>main.tf#L236</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.install_packages":end -->
<blockquote><!-- resource:"ssh_resource.install_update_upgrade_scripts":start -->

### _ssh_resource_.`install_update_upgrade_scripts`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L201"><code>main.tf#L201</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.install_update_upgrade_scripts":end -->
<blockquote><!-- resource:"ssh_resource.remove_response_routes":start -->

### _ssh_resource_.`remove_response_routes`

Cleanup counterpart to configure_response_routes - without this, removing a response_route entry later would orphan its hook scripts and ip rule/table.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L323"><code>main.tf#L323</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.remove_response_routes":end -->
<blockquote><!-- resource:"tls_private_key.ssh_key":start -->

### _tls_private_key_.`ssh_key`

Generate SSH key for the container
  <table>
    <tr>
      <td>Provider</td>
      <td><code>tls (hashicorp/tls)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L34"><code>main.tf#L34</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"tls_private_key.ssh_key":end -->

## Variables
  
<blockquote><!-- variable:"hostname":start -->

### `hostname` (**Required**)

Container host name

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L25"><code>variables.tf#L25</code></a>

</details>
</blockquote><!-- variable:"hostname":end -->
<blockquote><!-- variable:"network_interfaces":start -->

### `network_interfaces` (**Required**)

Network interfaces for the container. The first entry is the primary interface (net0); any further entries dual-home the container onto additional networks (e.g. a second VLAN) and are left gateway-less unless one is explicitly given. `response_route`, if set, adds source-based routing (a dedicated table + an `ip rule from <this interface's ip>`) so replies to traffic addressed to this interface go back out via its own gateway instead of falling through to the primary interface's default route - without it, only same-subnet peers of this interface can actually reach it.

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(object({
    name        = string
    bridge      = string
    mac_address = string
    ip          = string
    subnet_mask = optional(number, 24)
    vlan_id     = optional(number)
    gateway     = optional(string)
    response_route = optional(object({
      gateway    = string
      table_id   = number
      table_name = string
      priority   = optional(number, 100)
    }))
  }))
  ```
  In file: <a href="./variables.tf#L117"><code>variables.tf#L117</code></a>

</details>
</blockquote><!-- variable:"network_interfaces":end -->
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
  })
  ```
  In file: <a href="./variables.tf#L2"><code>variables.tf#L2</code></a>

</details>
</blockquote><!-- variable:"proxmox":end -->
<blockquote><!-- variable:"startup_order":start -->

### `startup_order` (**Required**)

Container startup order; shutdowns happen in reverse order

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  number
  ```
  In file: <a href="./variables.tf#L95"><code>variables.tf#L95</code></a>

</details>
</blockquote><!-- variable:"startup_order":end -->
<blockquote><!-- variable:"vm_id":start -->

### `vm_id` (**Required**)

Container (VM)ID

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  number
  ```
  In file: <a href="./variables.tf#L12"><code>variables.tf#L12</code></a>

</details>
</blockquote><!-- variable:"vm_id":end -->
<blockquote><!-- variable:"alpine_image":start -->

### `alpine_image` (*Optional*)

Alpine image configuration

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  object({
    url                = string
    checksum           = string
    checksum_algorithm = string
  })
  ```
  **Default**:
  ```json
  {
  "checksum": "9877b74de4c4878b70450502618f7b02952e792afdbc91f146f6cba507432dae516674d0bb3a306484d58edc722ff63db1ed3c4e5b0954fb2a2773ec8d8f33bd",
  "checksum_algorithm": "sha512",
  "url": "http://download.proxmox.com/images/system/alpine-3.24-default_20260714_amd64.tar.xz"
}
  ```
  In file: <a href="./variables.tf#L43"><code>variables.tf#L43</code></a>

</details>
</blockquote><!-- variable:"alpine_image":end -->
<blockquote><!-- variable:"cpu_cores":start -->

### `cpu_cores` (*Optional*)

Amount of CPU (v)cores; SMT/HT cores count as cores.

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
  In file: <a href="./variables.tf#L60"><code>variables.tf#L60</code></a>

</details>
</blockquote><!-- variable:"cpu_cores":end -->
<blockquote><!-- variable:"cpu_units":start -->

### `cpu_units` (*Optional*)

CPU scheduler priority relative to other containers; higher values mean more CPU time when under contention.

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  number
  ```
  **Default**:
  ```json
  100
  ```
  In file: <a href="./variables.tf#L67"><code>variables.tf#L67</code></a>

</details>
</blockquote><!-- variable:"cpu_units":end -->
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
  "Alpine Linux based LXC container"
  ```
  In file: <a href="./variables.tf#L31"><code>variables.tf#L31</code></a>

</details>
</blockquote><!-- variable:"description":end -->
<blockquote><!-- variable:"disk_size":start -->

### `disk_size` (*Optional*)

Size of the main container disk (in gigabytes)

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
  In file: <a href="./variables.tf#L88"><code>variables.tf#L88</code></a>

</details>
</blockquote><!-- variable:"disk_size":end -->
<blockquote><!-- variable:"dns_search_domain":start -->

### `dns_search_domain` (*Optional*)

DNS search domain for the container. Defaults to null (Proxmox's own default).

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  null
  ```
  In file: <a href="./variables.tf#L165"><code>variables.tf#L165</code></a>

</details>
</blockquote><!-- variable:"dns_search_domain":end -->
<blockquote><!-- variable:"dns_servers":start -->

### `dns_servers` (*Optional*)

DNS servers for the container's /etc/resolv.conf, in order. Defaults to null, which leaves Proxmox's own per-node default in place (not something this module should silently override for every consumer - callers on a network without their own DHCP-provided DNS need to set this explicitly).

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(string)
  ```
  **Default**:
  ```json
  null
  ```
  In file: <a href="./variables.tf#L159"><code>variables.tf#L159</code></a>

</details>
</blockquote><!-- variable:"dns_servers":end -->
<blockquote><!-- variable:"imagestore_id":start -->

### `imagestore_id` (*Optional*)

DataStore ID for the Alpine template

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "pve-resources"
  ```
  In file: <a href="./variables.tf#L81"><code>variables.tf#L81</code></a>

</details>
</blockquote><!-- variable:"imagestore_id":end -->
<blockquote><!-- variable:"memory_dedicated":start -->

### `memory_dedicated` (*Optional*)

RAM (in megabytes) dedicated to this container.

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  number
  ```
  **Default**:
  ```json
  1024
  ```
  In file: <a href="./variables.tf#L74"><code>variables.tf#L74</code></a>

</details>
</blockquote><!-- variable:"memory_dedicated":end -->
<blockquote><!-- variable:"mount_points":start -->

### `mount_points` (*Optional*)

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
  **Default**:
  ```json
  []
  ```
  In file: <a href="./variables.tf#L180"><code>variables.tf#L180</code></a>

</details>
</blockquote><!-- variable:"mount_points":end -->
<blockquote><!-- variable:"packages":start -->

### `packages` (*Optional*)

List of packages to install on the container

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(string)
  ```
  **Default**:
  ```json
  [
  "bash",
  "curl",
  "ca-certificates"
]
  ```
  In file: <a href="./variables.tf#L173"><code>variables.tf#L173</code></a>

</details>
</blockquote><!-- variable:"packages":end -->
<blockquote><!-- variable:"provisioning_interface_index":start -->

### `provisioning_interface_index` (*Optional*)

Index into network_interfaces that Terraform's own SSH provisioning connects to. Defaults to the primary interface (0); change only if that one isn't reachable from wherever `tofu apply` runs.

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  number
  ```
  **Default**:
  ```json
  0
  ```
  In file: <a href="./variables.tf#L147"><code>variables.tf#L147</code></a>

</details>
</blockquote><!-- variable:"provisioning_interface_index":end -->
<blockquote><!-- variable:"startup_down_delay":start -->

### `startup_down_delay` (*Optional*)

Delay (in seconds) before next container is shutdown

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  number
  ```
  **Default**:
  ```json
  20
  ```
  In file: <a href="./variables.tf#L108"><code>variables.tf#L108</code></a>

</details>
</blockquote><!-- variable:"startup_down_delay":end -->
<blockquote><!-- variable:"startup_up_delay":start -->

### `startup_up_delay` (*Optional*)

Delay (in seconds) before next container is started

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  number
  ```
  **Default**:
  ```json
  20
  ```
  In file: <a href="./variables.tf#L101"><code>variables.tf#L101</code></a>

</details>
</blockquote><!-- variable:"startup_up_delay":end -->
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
  "lxc",
  "alpine"
]
  ```
  In file: <a href="./variables.tf#L37"><code>variables.tf#L37</code></a>

</details>
</blockquote><!-- variable:"tags":end -->
<blockquote><!-- variable:"unprivileged":start -->

### `unprivileged` (*Optional*)

Whether the LXC container will be created as an unprivileged container (default) or as a privileged one

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
  In file: <a href="./variables.tf#L18"><code>variables.tf#L18</code></a>

</details>
</blockquote><!-- variable:"unprivileged":end -->
<blockquote><!-- variable:"update_interval":start -->

### `update_interval` (*Optional*)

Cron expression for automatic updates, or 'never' to disable

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "0 3 * * 1"
  ```
  In file: <a href="./variables.tf#L190"><code>variables.tf#L190</code></a>

</details>
</blockquote><!-- variable:"update_interval":end -->

## Outputs
  
<blockquote><!-- output:"container_id":start -->

#### `container_id`

Container id - see comment for why this is exported

In file: <a href="./outputs.tf#L25"><code>outputs.tf#L25</code></a>
</blockquote><!-- output:"container_id":end -->
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