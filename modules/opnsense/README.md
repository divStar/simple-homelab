# OPNsense VM

Creates the OPNsense router/firewall VM. WAN attaches untagged to `var.wan_bridge` (gets its
address from upstream, e.g. via DHCP during the test phase). LAN attaches untagged/trunk to
`var.lan_bridge` - OPNsense itself defines VLAN sub-interfaces on top of that one interface.

OPNsense has no unattended-install path, so the initial OS install is a one-time manual step
through the Proxmox console. Set `boot_from_installer = true` (the default) for that first
boot, then flip it to `false` and re-apply afterwards to boot from disk and eject the ISO.

OPNsense's own configuration lives entirely in one file (`/conf/config.xml`) on the guest -
this module deliberately does not wire up a full-VM PBS backup job, since the config is backed
up separately (see project notes) and a full-disk backup of an otherwise-reproducible install
isn't needed.

<!-- docs-meta: order=20 icon=opnsense -->

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Resources](#resources)
  - _proxmox_download_file_.[opnsense_iso](#proxmox_download_fileopnsense_iso)
  - _proxmox_virtual_environment_vm_.[opnsense](#proxmox_virtual_environment_vmopnsense)
- [Variables](#variables)
  - [proxmox](#proxmox-required) (**Required**)
  - [proxmox_node_name](#proxmox_node_name-required) (**Required**)
  - [vm_id](#vm_id-required) (**Required**)
  - [boot_from_installer](#boot_from_installer-optional) (*Optional*)
  - [cpu_cores](#cpu_cores-optional) (*Optional*)
  - [disk_datastore_id](#disk_datastore_id-optional) (*Optional*)
  - [disk_size](#disk_size-optional) (*Optional*)
  - [efi_disk_datastore_id](#efi_disk_datastore_id-optional) (*Optional*)
  - [iso_datastore_id](#iso_datastore_id-optional) (*Optional*)
  - [lan_bridge](#lan_bridge-optional) (*Optional*)
  - [memory](#memory-optional) (*Optional*)
  - [opnsense_version](#opnsense_version-optional) (*Optional*)
  - [vm_name](#vm_name-optional) (*Optional*)
  - [wan_bridge](#wan_bridge-optional) (*Optional*)
- [Outputs](#outputs)
  - [mac_addresses](#mac_addresses)
  - [opnsense_version](#opnsense_version)
  - [vm_id](#vm_id)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![bpg/proxmox](https://img.shields.io/badge/bpg--proxmox->=0.111.1-1e73c8?logo=proxmox)

## Resources
  
<blockquote><!-- resource:"proxmox_download_file.opnsense_iso":start -->

### _proxmox_download_file_.`opnsense_iso`

Download and decompress the OPNsense install ISO.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>proxmox (bpg/proxmox)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L27"><code>main.tf#L27</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"proxmox_download_file.opnsense_iso":end -->
<blockquote><!-- resource:"proxmox_virtual_environment_vm.opnsense":start -->

### _proxmox_virtual_environment_vm_.`opnsense`
      
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
</blockquote><!-- resource:"proxmox_virtual_environment_vm.opnsense":end -->

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
<blockquote><!-- variable:"vm_id":start -->

### `vm_id` (**Required**)

VM ID for the OPNsense VM

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  number
  ```
  In file: <a href="./variables.tf#L21"><code>variables.tf#L21</code></a>

</details>
</blockquote><!-- variable:"vm_id":end -->
<blockquote><!-- variable:"boot_from_installer":start -->

### `boot_from_installer` (*Optional*)

Whether to boot from the install ISO. true for the initial manual install; set to false afterwards (and re-apply) to boot from disk and eject the ISO.

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
  In file: <a href="./variables.tf#L86"><code>variables.tf#L86</code></a>

</details>
</blockquote><!-- variable:"boot_from_installer":end -->
<blockquote><!-- variable:"cpu_cores":start -->

### `cpu_cores` (*Optional*)

Number of CPU cores

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  number
  ```
  **Default**:
  ```json
  4
  ```
  In file: <a href="./variables.tf#L50"><code>variables.tf#L50</code></a>

</details>
</blockquote><!-- variable:"cpu_cores":end -->
<blockquote><!-- variable:"disk_datastore_id":start -->

### `disk_datastore_id` (*Optional*)

Datastore to place the VM's main disk on

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "disk-images"
  ```
  In file: <a href="./variables.tf#L68"><code>variables.tf#L68</code></a>

</details>
</blockquote><!-- variable:"disk_datastore_id":end -->
<blockquote><!-- variable:"disk_size":start -->

### `disk_size` (*Optional*)

Disk size in GB

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
  In file: <a href="./variables.tf#L62"><code>variables.tf#L62</code></a>

</details>
</blockquote><!-- variable:"disk_size":end -->
<blockquote><!-- variable:"efi_disk_datastore_id":start -->

### `efi_disk_datastore_id` (*Optional*)

Datastore for the EFI disk

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
  In file: <a href="./variables.tf#L80"><code>variables.tf#L80</code></a>

</details>
</blockquote><!-- variable:"efi_disk_datastore_id":end -->
<blockquote><!-- variable:"iso_datastore_id":start -->

### `iso_datastore_id` (*Optional*)

Datastore to store the downloaded install ISO on

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
  In file: <a href="./variables.tf#L74"><code>variables.tf#L74</code></a>

</details>
</blockquote><!-- variable:"iso_datastore_id":end -->
<blockquote><!-- variable:"lan_bridge":start -->

### `lan_bridge` (*Optional*)

Proxmox bridge to attach the LAN interface to (untagged/trunk - OPNsense handles VLAN tagging internally on top of this one interface)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "vmbr1"
  ```
  In file: <a href="./variables.tf#L44"><code>variables.tf#L44</code></a>

</details>
</blockquote><!-- variable:"lan_bridge":end -->
<blockquote><!-- variable:"memory":start -->

### `memory` (*Optional*)

Dedicated memory in MB

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  number
  ```
  **Default**:
  ```json
  8192
  ```
  In file: <a href="./variables.tf#L56"><code>variables.tf#L56</code></a>

</details>
</blockquote><!-- variable:"memory":end -->
<blockquote><!-- variable:"opnsense_version":start -->

### `opnsense_version` (*Optional*)

OPNsense release version to install (used to build the ISO download URL, e.g. https://pkg.opnsense.org/releases/mirror/OPNsense-<version>-dvd-amd64.iso.bz2)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "26.7"
  ```
  In file: <a href="./variables.tf#L32"><code>variables.tf#L32</code></a>

</details>
</blockquote><!-- variable:"opnsense_version":end -->
<blockquote><!-- variable:"vm_name":start -->

### `vm_name` (*Optional*)

Name of the OPNsense VM

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "opnsense"
  ```
  In file: <a href="./variables.tf#L26"><code>variables.tf#L26</code></a>

</details>
</blockquote><!-- variable:"vm_name":end -->
<blockquote><!-- variable:"wan_bridge":start -->

### `wan_bridge` (*Optional*)

Proxmox bridge to attach the WAN interface to (untagged - gets its address from upstream, e.g. via DHCP during the test phase)

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
  In file: <a href="./variables.tf#L38"><code>variables.tf#L38</code></a>

</details>
</blockquote><!-- variable:"wan_bridge":end -->

## Outputs
  
<blockquote><!-- output:"mac_addresses":start -->

#### `mac_addresses`

MAC addresses of the WAN and LAN network devices, in that order

In file: <a href="./outputs.tf#L11"><code>outputs.tf#L11</code></a>
</blockquote><!-- output:"mac_addresses":end -->
<blockquote><!-- output:"opnsense_version":start -->

#### `opnsense_version`

OPNsense version the install ISO was built from

In file: <a href="./outputs.tf#L6"><code>outputs.tf#L6</code></a>
</blockquote><!-- output:"opnsense_version":end -->
<blockquote><!-- output:"vm_id":start -->

#### `vm_id`

VM ID of the OPNsense VM

In file: <a href="./outputs.tf#L1"><code>outputs.tf#L1</code></a>
</blockquote><!-- output:"vm_id":end -->