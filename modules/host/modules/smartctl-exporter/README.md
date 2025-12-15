# smartctl-exporter

Handles exporting `smartctl` information every couple of seconds so that e.g. Prometheus can scrape it.

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Resources](#resources)
  - _ssh_resource_.[install_smartctl_exporter](#ssh_resourceinstall_smartctl_exporter)
  - _ssh_resource_.[uninstall_smartctl_exporter](#ssh_resourceuninstall_smartctl_exporter)
- [Variables](#variables)
  - [ssh](#ssh-required) (**Required**)
  - [smartctl_exporter_github_repository](#smartctl_exporter_github_repository-optional) (*Optional*)
  - [smartctl_exporter_version](#smartctl_exporter_version-optional) (*Optional*)
- [Outputs](#outputs)
  - [smartctl_exporter_version](#smartctl_exporter_version)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)

## Resources
  
<blockquote><!-- resource:"ssh_resource.install_smartctl_exporter":start -->

### _ssh_resource_.`install_smartctl_exporter`

Installs the smartctl-exporter.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L42"><code>main.tf#L42</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.install_smartctl_exporter":end -->
<blockquote><!-- resource:"ssh_resource.uninstall_smartctl_exporter":start -->

### _ssh_resource_.`uninstall_smartctl_exporter`

Uninstalls the smartctl-exporter.
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
</blockquote><!-- resource:"ssh_resource.uninstall_smartctl_exporter":end -->

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
<blockquote><!-- variable:"smartctl_exporter_github_repository":start -->

### `smartctl_exporter_github_repository` (*Optional*)

Configuration of the storage (pools and directories) to import

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "https://api.github.com/repos/prometheus-community/smartctl_exporter/releases/latest"
  ```
  In file: <a href="./variables.tf#L14"><code>variables.tf#L14</code></a>

</details>
</blockquote><!-- variable:"smartctl_exporter_github_repository":end -->
<blockquote><!-- variable:"smartctl_exporter_version":start -->

### `smartctl_exporter_version` (*Optional*)

Particular version to install; keep empty to install the latest

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
  In file: <a href="./variables.tf#L20"><code>variables.tf#L20</code></a>

</details>
</blockquote><!-- variable:"smartctl_exporter_version":end -->

## Outputs
  
<blockquote><!-- output:"smartctl_exporter_version":start -->

#### `smartctl_exporter_version`

Version of `smartctl-exporter`, that was installed

In file: <a href="./outputs.tf#L1"><code>outputs.tf#L1</code></a>
</blockquote><!-- output:"smartctl_exporter_version":end -->