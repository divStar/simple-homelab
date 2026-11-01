# share-permissions

Runs a daily systemd timer that adds missing group permissions (dirs: `g+rwxs`, files: `g+rw`) on the host paths backing
the Samba shares. Anything written by a root process on the host or through `virtiofs` (restores, rsync without `-p`,
containers running as root) otherwise lands with root's umask `022` and can't be moved or deleted by share users.

Only ever adds bits, never removes them or changes owners. Changed entries are printed to the journal
(`journalctl -u share-permissions`). With `textfile_directory` set, per-share counts
(`share_permissions_fixed_entries{path, type}`) and `share_permissions_last_run_timestamp_seconds` are exposed via
node\_exporter's textfile collector.

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Resources](#resources)
  - _ssh_resource_.[install_share_permissions](#ssh_resourceinstall_share_permissions)
  - _ssh_resource_.[uninstall_share_permissions](#ssh_resourceuninstall_share_permissions)
  - _terraform_data_.[share_permissions_trigger](#terraform_datashare_permissions_trigger)
- [Variables](#variables)
  - [ssh](#ssh-required) (**Required**)
  - [share_permissions](#share_permissions-optional) (*Optional*)
  - [textfile_directory](#textfile_directory-optional) (*Optional*)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)

## Resources
  
<blockquote><!-- resource:"ssh_resource.install_share_permissions":start -->

### _ssh_resource_.`install_share_permissions`

Installs the script, its config and the systemd service + timer.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L34"><code>main.tf#L34</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.install_share_permissions":end -->
<blockquote><!-- resource:"ssh_resource.uninstall_share_permissions":start -->

### _ssh_resource_.`uninstall_share_permissions`

Uninstalls everything again.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L91"><code>main.tf#L91</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.uninstall_share_permissions":end -->
<blockquote><!-- resource:"terraform_data.share_permissions_trigger":start -->

### _terraform_data_.`share_permissions_trigger`

`file { source }` content isn't diffed by the ssh provider - this forces a re-push whenever a file or the config changes.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>terraform (hashicorp/terraform)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L23"><code>main.tf#L23</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"terraform_data.share_permissions_trigger":end -->

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
<blockquote><!-- variable:"share_permissions":start -->

### `share_permissions` (*Optional*)

Share paths whose group permissions get repaired on a schedule

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  object({
    paths         = list(string)
    exclude_paths = optional(list(string), [])
    schedule      = optional(string, "*-*-* 04:30:00")
  })
  ```
  **Default**:
  ```json
  {
  "paths": []
}
  ```
  In file: <a href="./variables.tf#L14"><code>variables.tf#L14</code></a>

</details>
</blockquote><!-- variable:"share_permissions":end -->
<blockquote><!-- variable:"textfile_directory":start -->

### `textfile_directory` (*Optional*)

node_exporter textfile collector directory to write metrics to; keep empty to skip metrics

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
  In file: <a href="./variables.tf#L29"><code>variables.tf#L29</code></a>

</details>
</blockquote><!-- variable:"textfile_directory":end -->