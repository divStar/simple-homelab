# Host Setup

This module and its sub-modules setup the Proxmox host.

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Modules](#modules) _(nested and adjacent)_
  - [authorized_keys_appender](#authorized_keys_appender)
  - [copy_configs](#copy_configs)
  - [directory_mappings](#directory_mappings)
  - [gitops_user](#gitops_user)
  - [interface_adjustments](#interface_adjustments)
  - [network_bridges](#network_bridges)
  - [node_exporter](#node_exporter)
  - [packages](#packages)
  - [proxmox_storage_import](#proxmox_storage_import)
  - [repositories](#repositories)
  - [scripts](#scripts)
  - [share_user](#share_user)
  - [smartctl_exporter](#smartctl_exporter)
  - [terraform_user](#terraform_user)
  - [trust_proxmox_ca](#trust_proxmox_ca)
  - [zfs_storage](#zfs_storage)
- [Variables](#variables)
  - [configuration_files](#configuration_files-required) (**Required**)
  - [proxmox](#proxmox-required) (**Required**)
  - [proxmox_node_name](#proxmox_node_name-required) (**Required**)
  - [ssh](#ssh-required) (**Required**)
  - [bridges](#bridges-optional) (*Optional*)
  - [directory_mappings](#directory_mappings-optional) (*Optional*)
  - [gitops_user](#gitops_user-optional) (*Optional*)
  - [nic_link_advertise](#nic_link_advertise-optional) (*Optional*)
  - [no_subscription](#no_subscription-optional) (*Optional*)
  - [org_source_repo_owner](#org_source_repo_owner-optional) (*Optional*)
  - [packages](#packages-optional) (*Optional*)
  - [response_routes](#response_routes-optional) (*Optional*)
  - [scripts](#scripts-optional) (*Optional*)
  - [share_user](#share_user-optional) (*Optional*)
  - [storage_directories](#storage_directories-optional) (*Optional*)
  - [storage_pools](#storage_pools-optional) (*Optional*)
  - [terraform_user](#terraform_user-optional) (*Optional*)
  - [vlan_interfaces](#vlan_interfaces-optional) (*Optional*)
- [Outputs](#outputs)
  - [configuration_files](#configuration_files)
  - [directory_mappings](#directory_mappings)
  - [gitops_user](#gitops_user)
  - [imported_directories](#imported_directories)
  - [installed_packages](#installed_packages)
  - [installed_scripts](#installed_scripts)
  - [no_subscription](#no_subscription)
  - [node_exporter_version](#node_exporter_version)
  - [share_user](#share_user)
  - [smartctl_exporter_version](#smartctl_exporter_version)
  - [storage_pools](#storage_pools)
  - [terraform_user](#terraform_user)
</blockquote><!-- contents:end -->

## Providers
![proxmox](https://img.shields.io/badge/proxmox->=0.111.1-1e73c8?logo=proxmox)
![ssh](https://img.shields.io/badge/ssh-~>2.7-4fa4f9?logo=ssh)
![time](https://img.shields.io/badge/time->=0.13.0-b0055a?logo=time)
![tls](https://img.shields.io/badge/tls->=4.3.0-54a9fe?logo=tls)

## Modules
  
<blockquote><!-- module:"authorized_keys_appender":start -->

### `authorized_keys_appender`

Handles adding the SSH key of the machine running this script to the gitops user and git+ssh repository.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>./modules/authorized-keys-appender</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L154"><code>main.tf#L154</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="./modules/authorized-keys-appender/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"authorized_keys_appender":end -->
<blockquote><!-- module:"copy_configs":start -->

### `copy_configs`

Handles copying configuration files.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>./modules/copy-configs</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L39"><code>main.tf#L39</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="./modules/copy-configs/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"copy_configs":end -->
<blockquote><!-- module:"directory_mappings":start -->

### `directory_mappings`

Handles mapping directories for future use (e.g. file sharing via `virtiofs` into VMs).
  <table>
    <tr>
      <td>Module location</td>
      <td><code>./modules/directory-mappings</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L131"><code>main.tf#L131</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="./modules/directory-mappings/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"directory_mappings":end -->
<blockquote><!-- module:"gitops_user":start -->

### `gitops_user`

Handles creating a gitops user, providing it with access to the gitops git repository and exposing it for git+ssh access (gitops). > [!NOTE] > In order to make use of the gitops git repository and user, public SSH keys of users/applications, > who need access, have to be introduced into the `/home/<user, e.g. gitops>/.ssh/authorized_keys` file.<br> > You can use the [`authorized-keys-appender`](./modules/authorized-keys-appender/README.md) module for this.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>./modules/gitops-user</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L146"><code>main.tf#L146</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="./modules/gitops-user/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"gitops_user":end -->
<blockquote><!-- module:"interface_adjustments":start -->

### `interface_adjustments`

Handles persisting ethtool advertised link modes and source-based routing for specific interfaces via /etc/network/interfaces.d/ drop-ins. Depends on network_bridges since response_routes entries generally target VLAN interfaces that module creates.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>./modules/interface-adjustments</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L103"><code>main.tf#L103</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="./modules/interface-adjustments/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"interface_adjustments":end -->
<blockquote><!-- module:"network_bridges":start -->

### `network_bridges`

Handles the creation of Linux bridges and VLAN interfaces on the Proxmox host.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>./modules/network-bridges</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L92"><code>main.tf#L92</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="./modules/network-bridges/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"network_bridges":end -->
<blockquote><!-- module:"node_exporter":start -->

### `node_exporter`

Handles the installation of `node-exporter`.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>./modules/node-exporter</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L85"><code>main.tf#L85</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="./modules/node-exporter/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"node_exporter":end -->
<blockquote><!-- module:"packages":start -->

### `packages`

Handles the installation of additional `apt` packages.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>./modules/packages</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L122"><code>main.tf#L122</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="./modules/packages/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"packages":end -->
<blockquote><!-- module:"proxmox_storage_import":start -->

### `proxmox_storage_import`

Handles the import of directories into Proxmox.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>./modules/proxmox-storage-import</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L113"><code>main.tf#L113</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="./modules/proxmox-storage-import/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"proxmox_storage_import":end -->
<blockquote><!-- module:"repositories":start -->

### `repositories`

Handles the deactivation of the enterprise `apt` repository and the activation of the `pve-no-subscription` `apt` repository.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>./modules/repositories</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L47"><code>main.tf#L47</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="./modules/repositories/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"repositories":end -->
<blockquote><!-- module:"scripts":start -->

### `scripts`

Handles the execution of various *non-interactive* scripts.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>./modules/scripts</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L55"><code>main.tf#L55</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="./modules/scripts/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"scripts":end -->
<blockquote><!-- module:"share_user":start -->

### `share_user`

Handles creating a share user.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>./modules/share-user</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L31"><code>main.tf#L31</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="./modules/share-user/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"share_user":end -->
<blockquote><!-- module:"smartctl_exporter":start -->

### `smartctl_exporter`

Handles the installation of the `smartctl-exporter`.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>./modules/smartctl-exporter</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L78"><code>main.tf#L78</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="./modules/smartctl-exporter/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"smartctl_exporter":end -->
<blockquote><!-- module:"terraform_user":start -->

### `terraform_user`

Handles the creation of a Terraform user and API token. This user can be used for various Proxmox interactions.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>./modules/terraform-user</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L23"><code>main.tf#L23</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="./modules/terraform-user/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"terraform_user":end -->
<blockquote><!-- module:"trust_proxmox_ca":start -->

### `trust_proxmox_ca`

Handles letting Proxmox trust its own CA certificate.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>./modules/trust-proxmox-ca</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L71"><code>main.tf#L71</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="./modules/trust-proxmox-ca/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"trust_proxmox_ca":end -->
<blockquote><!-- module:"zfs_storage":start -->

### `zfs_storage`

Handles the import of ZFS pools.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>./modules/zfs-storage</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L63"><code>main.tf#L63</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="./modules/zfs-storage/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"zfs_storage":end -->

## Variables
  
<blockquote><!-- variable:"configuration_files":start -->

### `configuration_files` (**Required**)

Configuration files to copy to the host

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(object({
    source      = string
    destination = string
    permissions = optional(number)
    owner       = optional(string)
    group       = optional(string)
  }))
  ```
  In file: <a href="./variables.tf#L111"><code>variables.tf#L111</code></a>

</details>
</blockquote><!-- variable:"configuration_files":end -->
<blockquote><!-- variable:"proxmox":start -->

### `proxmox` (**Required**)

Proxmox API connection details, separate from the SSH-based `ssh` variable - needed for `bpg/proxmox`-backed resources such as network bridges/VLANs

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
  In file: <a href="./variables.tf#L19"><code>variables.tf#L19</code></a>

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
  In file: <a href="./variables.tf#L14"><code>variables.tf#L14</code></a>

</details>
</blockquote><!-- variable:"proxmox_node_name":end -->
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
  In file: <a href="./variables.tf#L34"><code>variables.tf#L34</code></a>

</details>
</blockquote><!-- variable:"bridges":end -->
<blockquote><!-- variable:"directory_mappings":start -->

### `directory_mappings` (*Optional*)

Directory mappings for the Proxmox node

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(object({
    id      = string
    path    = string
    comment = optional(string, "")
  }))
  ```
  **Default**:
  ```json
  []
  ```
  In file: <a href="./variables.tf#L294"><code>variables.tf#L294</code></a>

</details>
</blockquote><!-- variable:"directory_mappings":end -->
<blockquote><!-- variable:"gitops_user":start -->

### `gitops_user` (*Optional*)

Configuration of GitOps user.

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  object({
    user        = optional(string, "gitops")
    group       = optional(string, "gitops")
    repo_name   = optional(string, "repo")
    source_repo = optional(string, "/storage-pool/gitops")
  })
  ```
  **Default**:
  ```json
  {}
  ```
  In file: <a href="./variables.tf#L220"><code>variables.tf#L220</code></a>

</details>
</blockquote><!-- variable:"gitops_user":end -->
<blockquote><!-- variable:"nic_link_advertise":start -->

### `nic_link_advertise` (*Optional*)

NICs that should have specific ethtool link modes force-advertised via a persistent /etc/network/interfaces.d/ drop-in - works around NIC drivers (e.g. ixgbe/X550) that don't advertise their full hardware-supported mode set by default, silently capping negotiated speed even with a good cable and a capable link partner.

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
  In file: <a href="./variables.tf#L283"><code>variables.tf#L283</code></a>

</details>
</blockquote><!-- variable:"nic_link_advertise":end -->
<blockquote><!-- variable:"no_subscription":start -->

### `no_subscription` (*Optional*)

Whether to use no-subscription repository instead of enterprise repository or not

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
  In file: <a href="./variables.tf#L262"><code>variables.tf#L262</code></a>

</details>
</blockquote><!-- variable:"no_subscription":end -->
<blockquote><!-- variable:"org_source_repo_owner":start -->

### `org_source_repo_owner` (*Optional*)

Original owner of the source repository (before, e.g. root:root)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  object({
    owner = optional(string, "root")
    group = optional(string, "root")
  })
  ```
  **Default**:
  ```json
  {}
  ```
  In file: <a href="./variables.tf#L232"><code>variables.tf#L232</code></a>

</details>
</blockquote><!-- variable:"org_source_repo_owner":end -->
<blockquote><!-- variable:"packages":start -->

### `packages` (*Optional*)

List of packages to install via apt-get

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(string)
  ```
  **Default**:
  ```json
  []
  ```
  In file: <a href="./variables.tf#L127"><code>variables.tf#L127</code></a>

</details>
</blockquote><!-- variable:"packages":end -->
<blockquote><!-- variable:"response_routes":start -->

### `response_routes` (*Optional*)

Per-interface source-based routing: traffic sourced from a specific address uses its own gateway, without disturbing the system's main default route - needed for dual-homed hosts where a secondary interface has no gateway of its own. Governs only how sanctum's own replies get routed back out; it has no bearing on who's allowed to reach it in the first place - that's OPNsense's firewall's job entirely.

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
  In file: <a href="./variables.tf#L72"><code>variables.tf#L72</code></a>

</details>
</blockquote><!-- variable:"response_routes":end -->
<blockquote><!-- variable:"scripts":start -->

### `scripts` (*Optional*)

Configuration for script management including shared directory and script items

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  object({
    directory = optional(string, "scripts")
    items = list(object({
      name           = string
      url            = string
      apply_params   = optional(string, "")
      destroy_params = optional(string, "")
      run_on_destroy = optional(bool, true)
    }))
  })
  ```
  **Default**:
  ```json
  {
  "directory": "scripts",
  "items": []
}
  ```
  In file: <a href="./variables.tf#L134"><code>variables.tf#L134</code></a>

</details>
</blockquote><!-- variable:"scripts":end -->
<blockquote><!-- variable:"share_user":start -->

### `share_user` (*Optional*)

Configuration of GitOps user.

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  object({
    user  = string
    group = string
    uid   = number
    gid   = number
  })
  ```
  **Default**:
  ```json
  {
  "gid": 1400,
  "group": "share-users",
  "uid": 1400,
  "user": "share-user"
}
  ```
  In file: <a href="./variables.tf#L242"><code>variables.tf#L242</code></a>

</details>
</blockquote><!-- variable:"share_user":end -->
<blockquote><!-- variable:"storage_directories":start -->

### `storage_directories` (*Optional*)

Map of storage directories to configure; the key is the name of the directory.

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  map(object({
    path    = string
    content = string
  }))
  ```
  **Default**:
  ```json
  {}
  ```
  In file: <a href="./variables.tf#L274"><code>variables.tf#L274</code></a>

</details>
</blockquote><!-- variable:"storage_directories":end -->
<blockquote><!-- variable:"storage_pools":start -->

### `storage_pools` (*Optional*)

Configuration of the storage (pools and directories) to import

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(string)
  ```
  **Default**:
  ```json
  []
  ```
  In file: <a href="./variables.tf#L268"><code>variables.tf#L268</code></a>

</details>
</blockquote><!-- variable:"storage_pools":end -->
<blockquote><!-- variable:"terraform_user":start -->

### `terraform_user` (*Optional*)

Configuration for Terraform provisioner user. Individual fields can be overridden.

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  object({
    name    = optional(string, "terraform@pve")
    comment = optional(string, "Terraform automation user")
    role = object({
      name = optional(string, "TerraformProv")
      privileges = optional(list(string), [
        "VM.Allocate",
        "VM.Clone",
        "VM.Audit",
        "VM.Config.HWType",
        "VM.Config.Disk",
        "VM.Config.CPU",
        "VM.Config.Memory",
        "VM.Config.Network",
        "VM.Config.Cloudinit",
        "VM.Config.Options",
        "VM.PowerMgmt",
        "Datastore.Allocate",
        "Datastore.AllocateSpace",
        "Datastore.AllocateTemplate",
        "Datastore.Audit",
        "SDN.Use",
        "Sys.Audit",
        "Sys.Modify",
        "Mapping.Use",
        "Mapping.Modify"
      ])
    })
    token = object({
      name    = optional(string, "terraform-token")
      comment = optional(string, "Terraform automation user API token")
    })
  })
  ```
  **Default**:
  ```json
  {
  "role": {},
  "token": {}
}
  ```
  In file: <a href="./variables.tf#L170"><code>variables.tf#L170</code></a>

</details>
</blockquote><!-- variable:"terraform_user":end -->
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
  In file: <a href="./variables.tf#L55"><code>variables.tf#L55</code></a>

</details>
</blockquote><!-- variable:"vlan_interfaces":end -->

## Outputs
  
<blockquote><!-- output:"configuration_files":start -->

#### `configuration_files`

Configuration files copied to host

In file: <a href="./outputs.tf#L1"><code>outputs.tf#L1</code></a>
</blockquote><!-- output:"configuration_files":end -->
<blockquote><!-- output:"directory_mappings":start -->

#### `directory_mappings`

List of directories mapped for further use in Proxmox

In file: <a href="./outputs.tf#L6"><code>outputs.tf#L6</code></a>
</blockquote><!-- output:"directory_mappings":end -->
<blockquote><!-- output:"gitops_user":start -->

#### `gitops_user`

User and git+ssh URL for gitops purposes

In file: <a href="./outputs.tf#L54"><code>outputs.tf#L54</code></a>
</blockquote><!-- output:"gitops_user":end -->
<blockquote><!-- output:"imported_directories":start -->

#### `imported_directories`

Imported directories

In file: <a href="./outputs.tf#L40"><code>outputs.tf#L40</code></a>
</blockquote><!-- output:"imported_directories":end -->
<blockquote><!-- output:"installed_packages":start -->

#### `installed_packages`

The packages, that have been installed/removed

In file: <a href="./outputs.tf#L11"><code>outputs.tf#L11</code></a>
</blockquote><!-- output:"installed_packages":end -->
<blockquote><!-- output:"installed_scripts":start -->

#### `installed_scripts`

The scripts, that have been installed/removed

In file: <a href="./outputs.tf#L16"><code>outputs.tf#L16</code></a>
</blockquote><!-- output:"installed_scripts":end -->
<blockquote><!-- output:"no_subscription":start -->

#### `no_subscription`

States, whether a no-subscription repository was used (and some further details)

In file: <a href="./outputs.tf#L21"><code>outputs.tf#L21</code></a>
</blockquote><!-- output:"no_subscription":end -->
<blockquote><!-- output:"node_exporter_version":start -->

#### `node_exporter_version`

Version of `node-exporter`, that was installed

In file: <a href="./outputs.tf#L70"><code>outputs.tf#L70</code></a>
</blockquote><!-- output:"node_exporter_version":end -->
<blockquote><!-- output:"share_user":start -->

#### `share_user`

The user to manage file shares on the Proxmox host storage

In file: <a href="./outputs.tf#L26"><code>outputs.tf#L26</code></a>
</blockquote><!-- output:"share_user":end -->
<blockquote><!-- output:"smartctl_exporter_version":start -->

#### `smartctl_exporter_version`

Version of `smartctl-exporter`, that was installed

In file: <a href="./outputs.tf#L65"><code>outputs.tf#L65</code></a>
</blockquote><!-- output:"smartctl_exporter_version":end -->
<blockquote><!-- output:"storage_pools":start -->

#### `storage_pools`

List of storage pools that were imported and added to Proxmox

In file: <a href="./outputs.tf#L35"><code>outputs.tf#L35</code></a>
</blockquote><!-- output:"storage_pools":end -->
<blockquote><!-- output:"terraform_user":start -->

#### `terraform_user`

The user and role created to manage the Proxmox host via Terraform/OpenTofu

In file: <a href="./outputs.tf#L45"><code>outputs.tf#L45</code></a>
</blockquote><!-- output:"terraform_user":end -->