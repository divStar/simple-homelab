# Debian LXC container setup

This module creates a Debian LXC container on the Proxmox host,
generates a `root_password` and a `ssh_key`, installs `openssh` as well as
other Debian packages (if specified; `bash`, `curl`, `ca-certificates` and
`cron` are installed by default).

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Resources](#resources)
  - _proxmox_download_file_.[template](#proxmox_download_filetemplate)
  - _proxmox_virtual_environment_container_.[container](#proxmox_virtual_environment_containercontainer)
  - _random_password_.[root_password](#random_passwordroot_password)
  - _ssh_resource_.[disable_default_apt_timers](#ssh_resourcedisable_default_apt_timers)
  - _ssh_resource_.[install_default_aliases](#ssh_resourceinstall_default_aliases)
  - _ssh_resource_.[install_openssh](#ssh_resourceinstall_openssh)
  - _ssh_resource_.[install_packages](#ssh_resourceinstall_packages)
  - _ssh_resource_.[install_update_upgrade_scripts](#ssh_resourceinstall_update_upgrade_scripts)
  - _tls_private_key_.[ssh_key](#tls_private_keyssh_key)
- [Variables](#variables)
  - [hostname](#hostname-required) (**Required**)
  - [ni_gateway](#ni_gateway-required) (**Required**)
  - [ni_ip](#ni_ip-required) (**Required**)
  - [ni_mac_address](#ni_mac_address-required) (**Required**)
  - [proxmox](#proxmox-required) (**Required**)
  - [startup_order](#startup_order-required) (**Required**)
  - [vm_id](#vm_id-required) (**Required**)
  - [cpu_cores](#cpu_cores-optional) (*Optional*)
  - [cpu_units](#cpu_units-optional) (*Optional*)
  - [debian_image](#debian_image-optional) (*Optional*)
  - [description](#description-optional) (*Optional*)
  - [disk_size](#disk_size-optional) (*Optional*)
  - [imagestore_id](#imagestore_id-optional) (*Optional*)
  - [memory_dedicated](#memory_dedicated-optional) (*Optional*)
  - [mount_points](#mount_points-optional) (*Optional*)
  - [ni_bridge](#ni_bridge-optional) (*Optional*)
  - [ni_name](#ni_name-optional) (*Optional*)
  - [ni_subnet_mask](#ni_subnet_mask-optional) (*Optional*)
  - [packages](#packages-optional) (*Optional*)
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

Downloads the `debian` image.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>proxmox (bpg/proxmox)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L15"><code>main.tf#L15</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"proxmox_download_file.template":end -->
<blockquote><!-- resource:"proxmox_virtual_environment_container.container":start -->

### _proxmox_virtual_environment_container_.`container`

Create Debian LXC container
  <table>
    <tr>
      <td>Provider</td>
      <td><code>proxmox (bpg/proxmox)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L38"><code>main.tf#L38</code></a></td>
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
      <td><a href="./main.tf#L31"><code>main.tf#L31</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"random_password.root_password":end -->
<blockquote><!-- resource:"ssh_resource.disable_default_apt_timers":start -->

### _ssh_resource_.`disable_default_apt_timers`

Disable Debian's own default apt-daily.timer/apt-daily-upgrade.timer. Confirmed via live inspection (2026-08-09, pbs-lxc) that on this image, with no /etc/apt/apt.conf.d/20auto-upgrades or 10periodic present (the stock state), apt.systemd.daily's own stamp-check logic already makes both timers pure no-ops -- every APT::Periodic::* interval it checks defaults to 0 when unset, so nothing they'd otherwise do (index refresh, unattended-upgrade) ever actually runs. Disabling them costs nothing functionally; it just removes two enabled-but-inert timers cluttering `systemctl list-timers` and the confusion of two update-shaped timers next to debian-update.timer above, which is the one that actually performs upgrades.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L243"><code>main.tf#L243</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.disable_default_apt_timers":end -->
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
      <td><a href="./main.tf#L258"><code>main.tf#L258</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.install_default_aliases":end -->
<blockquote><!-- resource:"ssh_resource.install_openssh":start -->

### _ssh_resource_.`install_openssh`

Install OpenSSH into the Debian LXC container
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L129"><code>main.tf#L129</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.install_openssh":end -->
<blockquote><!-- resource:"ssh_resource.install_packages":start -->

### _ssh_resource_.`install_packages`

Install necessary Debian packages (includes cron, needed for the update schedule below)
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L163"><code>main.tf#L163</code></a></td>
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
      <td><a href="./main.tf#L182"><code>main.tf#L182</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.install_update_upgrade_scripts":end -->
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
      <td><a href="./main.tf#L25"><code>main.tf#L25</code></a></td>
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
<blockquote><!-- variable:"ni_gateway":start -->

### `ni_gateway` (**Required**)

Network interface gateway

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L123"><code>variables.tf#L123</code></a>

</details>
</blockquote><!-- variable:"ni_gateway":end -->
<blockquote><!-- variable:"ni_ip":start -->

### `ni_ip` (**Required**)

Network interface IP address

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L117"><code>variables.tf#L117</code></a>

</details>
</blockquote><!-- variable:"ni_ip":end -->
<blockquote><!-- variable:"ni_mac_address":start -->

### `ni_mac_address` (**Required**)

Network interface MAC address

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L129"><code>variables.tf#L129</code></a>

</details>
</blockquote><!-- variable:"ni_mac_address":end -->
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
<blockquote><!-- variable:"debian_image":start -->

### `debian_image` (*Optional*)

Debian image configuration

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
  "checksum": "4c0c27ca6ceab5ef0b84db57825a00f26157ef1854bafe97297813e1cbe8ecb8cc9c453cab6b3b0efe1ba193a50c47ece1e41d950e411b8730b835b71e9e754b",
  "checksum_algorithm": "sha512",
  "url": "http://download.proxmox.com/images/system/debian-13-standard_13.6-1_amd64.tar.zst"
}
  ```
  In file: <a href="./variables.tf#L43"><code>variables.tf#L43</code></a>

</details>
</blockquote><!-- variable:"debian_image":end -->
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
  "Debian Linux based LXC container"
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
  2
  ```
  In file: <a href="./variables.tf#L88"><code>variables.tf#L88</code></a>

</details>
</blockquote><!-- variable:"disk_size":end -->
<blockquote><!-- variable:"imagestore_id":start -->

### `imagestore_id` (*Optional*)

DataStore ID for the Debian template

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
  In file: <a href="./variables.tf#L165"><code>variables.tf#L165</code></a>

</details>
</blockquote><!-- variable:"mount_points":end -->
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
  In file: <a href="./variables.tf#L149"><code>variables.tf#L149</code></a>

</details>
</blockquote><!-- variable:"ni_bridge":end -->
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
  In file: <a href="./variables.tf#L142"><code>variables.tf#L142</code></a>

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
  In file: <a href="./variables.tf#L135"><code>variables.tf#L135</code></a>

</details>
</blockquote><!-- variable:"ni_subnet_mask":end -->
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
  In file: <a href="./variables.tf#L158"><code>variables.tf#L158</code></a>

</details>
</blockquote><!-- variable:"packages":end -->
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
  "debian"
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

systemd OnCalendar expression for automatic updates, or 'never' to disable

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "Sun *-*-* 05:00:00"
  ```
  In file: <a href="./variables.tf#L175"><code>variables.tf#L175</code></a>

</details>
</blockquote><!-- variable:"update_interval":end -->

## Outputs
  
<blockquote><!-- output:"container_id":start -->

#### `container_id`

Container id - see comment for why this is exported

In file: <a href="./outputs.tf#L23"><code>outputs.tf#L23</code></a>
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