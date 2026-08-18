# node-exporter

Handles exporting host-level metrics (CPU, memory, network interfaces, etc.) every couple of seconds so that e.g. Prometheus can scrape it.

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Resources](#resources)
  - _ssh_resource_.[install_node_exporter](#ssh_resourceinstall_node_exporter)
  - _ssh_resource_.[uninstall_node_exporter](#ssh_resourceuninstall_node_exporter)
- [Variables](#variables)
  - [ssh](#ssh-required) (**Required**)
  - [node_exporter_github_repository](#node_exporter_github_repository-optional) (*Optional*)
  - [node_exporter_version](#node_exporter_version-optional) (*Optional*)
- [Outputs](#outputs)
  - [node_exporter_version](#node_exporter_version)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)

## Resources
  
<blockquote><!-- resource:"ssh_resource.install_node_exporter":start -->

### _ssh_resource_.`install_node_exporter`

Installs node_exporter.
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
</blockquote><!-- resource:"ssh_resource.install_node_exporter":end -->
<blockquote><!-- resource:"ssh_resource.uninstall_node_exporter":start -->

### _ssh_resource_.`uninstall_node_exporter`

Uninstalls node_exporter.
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
</blockquote><!-- resource:"ssh_resource.uninstall_node_exporter":end -->

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
<blockquote><!-- variable:"node_exporter_github_repository":start -->

### `node_exporter_github_repository` (*Optional*)

GitHub repository to fetch releases from

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "https://api.github.com/repos/prometheus/node_exporter/releases/latest"
  ```
  In file: <a href="./variables.tf#L14"><code>variables.tf#L14</code></a>

</details>
</blockquote><!-- variable:"node_exporter_github_repository":end -->
<blockquote><!-- variable:"node_exporter_version":start -->

### `node_exporter_version` (*Optional*)

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
</blockquote><!-- variable:"node_exporter_version":end -->

## Outputs
  
<blockquote><!-- output:"node_exporter_version":start -->

#### `node_exporter_version`

Version of `node_exporter`, that was installed

In file: <a href="./outputs.tf#L1"><code>outputs.tf#L1</code></a>
</blockquote><!-- output:"node_exporter_version":end -->