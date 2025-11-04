

## Contents

<blockquote><!-- contents:start -->

- [Requirements](#requirements)
- [Providers](#providers)
- [Resources](#resources)
  - _local_file_.[butane_file](#local_filebutane_file)
  - _local_file_.[ignition_file](#local_fileignition_file)
  - _proxmox_virtual_environment_download_file_.[flatcar_image](#proxmox_virtual_environment_download_fileflatcar_image)
  - _proxmox_virtual_environment_file_.[ignition_config](#proxmox_virtual_environment_fileignition_config)
  - _proxmox_virtual_environment_vm_.[flatcar](#proxmox_virtual_environment_vmflatcar)
- [Variables](#variables)
  - [disks](#disks-required) (**Required**)
  - [docker_daemon_configuration](#docker_daemon_configuration-required) (**Required**)
  - [efi_disk_datastore_id](#efi_disk_datastore_id-required) (**Required**)
  - [flatcar_image_datastore_id](#flatcar_image_datastore_id-required) (**Required**)
  - [flatcar_image_file_name](#flatcar_image_file_name-required) (**Required**)
  - [ignition_config_datastore_id](#ignition_config_datastore_id-required) (**Required**)
  - [ignition_config_file_name](#ignition_config_file_name-required) (**Required**)
  - [proxmox_endpoint](#proxmox_endpoint-required) (**Required**)
  - [proxmox_node_name](#proxmox_node_name-required) (**Required**)
  - [proxmox_password](#proxmox_password-required) (**Required**)
  - [proxmox_ssh_key](#proxmox_ssh_key-required) (**Required**)
  - [proxmox_ssh_user](#proxmox_ssh_user-required) (**Required**)
  - [step_ca_client_version](#step_ca_client_version-required) (**Required**)
  - [step_ca_domain](#step_ca_domain-required) (**Required**)
  - [step_ca_provisioner](#step_ca_provisioner-required) (**Required**)
  - [step_ca_provisioner_password](#step_ca_provisioner_password-required) (**Required**)
  - [viritofs_resources](#viritofs_resources-required) (**Required**)
  - [vm_dns_ip](#vm_dns_ip-required) (**Required**)
  - [vm_gateway_ip](#vm_gateway_ip-required) (**Required**)
  - [vm_hostname](#vm_hostname-required) (**Required**)
  - [vm_id](#vm_id-required) (**Required**)
  - [vm_ip](#vm_ip-required) (**Required**)
  - [flatcar_image_channel](#flatcar_image_channel-optional) (*Optional*)
  - [proxmox_insecure](#proxmox_insecure-optional) (*Optional*)
  - [vm_network_interface_name](#vm_network_interface_name-optional) (*Optional*)
</blockquote><!-- contents:end -->

## Requirements
![opentofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![ct](https://img.shields.io/badge/ct-0.13.0-d82d82?logo=ct)
![proxmox](https://img.shields.io/badge/proxmox-~>0.86.0-1e73c8?logo=proxmox)

## Providers
  
![ct](https://img.shields.io/badge/ct-0.13.0-d82d82)
![http](https://img.shields.io/badge/http--c1166b)
![local](https://img.shields.io/badge/local--0c61b6)
![proxmox](https://img.shields.io/badge/proxmox-~>0.86.0-1e73c8)

## Resources
  
<blockquote><!-- resource:"local_file.butane_file":start -->

### _local_file_.`butane_file`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>local (hashicorp/local)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./outputs.tf#L6"><code>outputs.tf#L6</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"local_file.butane_file":end -->
<blockquote><!-- resource:"local_file.ignition_file":start -->

### _local_file_.`ignition_file`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>local (hashicorp/local)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./outputs.tf#L1"><code>outputs.tf#L1</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"local_file.ignition_file":end -->
<blockquote><!-- resource:"proxmox_virtual_environment_download_file.flatcar_image":start -->

### _proxmox_virtual_environment_download_file_.`flatcar_image`

Download Flatcar stable image
  <table>
    <tr>
      <td>Provider</td>
      <td><code>proxmox (bpg/proxmox)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L84"><code>main.tf#L84</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"proxmox_virtual_environment_download_file.flatcar_image":end -->
<blockquote><!-- resource:"proxmox_virtual_environment_file.ignition_config":start -->

### _proxmox_virtual_environment_file_.`ignition_config`

Upload the transpiled Ignition config as a snippet
  <table>
    <tr>
      <td>Provider</td>
      <td><code>proxmox (bpg/proxmox)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L72"><code>main.tf#L72</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"proxmox_virtual_environment_file.ignition_config":end -->
<blockquote><!-- resource:"proxmox_virtual_environment_vm.flatcar":start -->

### _proxmox_virtual_environment_vm_.`flatcar`

Create the Flatcar VM
  <table>
    <tr>
      <td>Provider</td>
      <td><code>proxmox (bpg/proxmox)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L96"><code>main.tf#L96</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"proxmox_virtual_environment_vm.flatcar":end -->

## Variables
  
<blockquote><!-- variable:"disks":start -->

### `disks` (**Required**)

Disks, that should be mounted

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(object({
    datastore_id = string
    import_from  = string
    interface    = string
    file_format  = string
    size         = number
    serial       = string
    mount_path   = optional(string)
  }))
  ```
  In file: <a href="./variables.tf#L150"><code>variables.tf#L150</code></a>

</details>
</blockquote><!-- variable:"disks":end -->
<blockquote><!-- variable:"docker_daemon_configuration":start -->

### `docker_daemon_configuration` (**Required**)

Docker daemon.json configuration file content

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L130"><code>variables.tf#L130</code></a>

</details>
</blockquote><!-- variable:"docker_daemon_configuration":end -->
<blockquote><!-- variable:"efi_disk_datastore_id":start -->

### `efi_disk_datastore_id` (**Required**)

Proxmox location for the EFI disk

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L145"><code>variables.tf#L145</code></a>

</details>
</blockquote><!-- variable:"efi_disk_datastore_id":end -->
<blockquote><!-- variable:"flatcar_image_datastore_id":start -->

### `flatcar_image_datastore_id` (**Required**)

Proxmox location for the FlatCar image

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L109"><code>variables.tf#L109</code></a>

</details>
</blockquote><!-- variable:"flatcar_image_datastore_id":end -->
<blockquote><!-- variable:"flatcar_image_file_name":start -->

### `flatcar_image_file_name` (**Required**)

Filename of the FlatCar image (image type must match format of the boot disk in 'disks')

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L114"><code>variables.tf#L114</code></a>

</details>
</blockquote><!-- variable:"flatcar_image_file_name":end -->
<blockquote><!-- variable:"ignition_config_datastore_id":start -->

### `ignition_config_datastore_id` (**Required**)

Proxmox location of the Ignition configuration

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L99"><code>variables.tf#L99</code></a>

</details>
</blockquote><!-- variable:"ignition_config_datastore_id":end -->
<blockquote><!-- variable:"ignition_config_file_name":start -->

### `ignition_config_file_name` (**Required**)

Filename of the Ignition configuration; use `VM_ID` in the filename to replace it with the `vm_id` dynamically

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L104"><code>variables.tf#L104</code></a>

</details>
</blockquote><!-- variable:"ignition_config_file_name":end -->
<blockquote><!-- variable:"proxmox_endpoint":start -->

### `proxmox_endpoint` (**Required**)

Proxmox API endpoint (e.g. https://pve.local:8006)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L1"><code>variables.tf#L1</code></a>

</details>
</blockquote><!-- variable:"proxmox_endpoint":end -->
<blockquote><!-- variable:"proxmox_node_name":start -->

### `proxmox_node_name` (**Required**)

Proxmox node name

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L6"><code>variables.tf#L6</code></a>

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
  In file: <a href="./variables.tf#L11"><code>variables.tf#L11</code></a>

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
  In file: <a href="./variables.tf#L21"><code>variables.tf#L21</code></a>

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
  In file: <a href="./variables.tf#L16"><code>variables.tf#L16</code></a>

</details>
</blockquote><!-- variable:"proxmox_ssh_user":end -->
<blockquote><!-- variable:"step_ca_client_version":start -->

### `step_ca_client_version` (**Required**)

Step CA client version (used in `step-ca.config.yaml.tftpl`)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L78"><code>variables.tf#L78</code></a>

</details>
</blockquote><!-- variable:"step_ca_client_version":end -->
<blockquote><!-- variable:"step_ca_domain":start -->

### `step_ca_domain` (**Required**)

Step CA domain

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L83"><code>variables.tf#L83</code></a>

</details>
</blockquote><!-- variable:"step_ca_domain":end -->
<blockquote><!-- variable:"step_ca_provisioner":start -->

### `step_ca_provisioner` (**Required**)

Step CA provisioner name

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L88"><code>variables.tf#L88</code></a>

</details>
</blockquote><!-- variable:"step_ca_provisioner":end -->
<blockquote><!-- variable:"step_ca_provisioner_password":start -->

### `step_ca_provisioner_password` (**Required**)

Step CA provisioner password

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L93"><code>variables.tf#L93</code></a>

</details>
</blockquote><!-- variable:"step_ca_provisioner_password":end -->
<blockquote><!-- variable:"viritofs_resources":start -->

### `viritofs_resources` (**Required**)

Map of VirtioFS mapping names to attach to all VMs

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  map(string)
  ```
  In file: <a href="./variables.tf#L140"><code>variables.tf#L140</code></a>

</details>
</blockquote><!-- variable:"viritofs_resources":end -->
<blockquote><!-- variable:"vm_dns_ip":start -->

### `vm_dns_ip` (**Required**)

VM DNS IP (v4)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L62"><code>variables.tf#L62</code></a>

</details>
</blockquote><!-- variable:"vm_dns_ip":end -->
<blockquote><!-- variable:"vm_gateway_ip":start -->

### `vm_gateway_ip` (**Required**)

VM gateway IP (v4)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L52"><code>variables.tf#L52</code></a>

</details>
</blockquote><!-- variable:"vm_gateway_ip":end -->
<blockquote><!-- variable:"vm_hostname":start -->

### `vm_hostname` (**Required**)

VM Name and hostname

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L37"><code>variables.tf#L37</code></a>

</details>
</blockquote><!-- variable:"vm_hostname":end -->
<blockquote><!-- variable:"vm_id":start -->

### `vm_id` (**Required**)

VM ID

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  number
  ```
  In file: <a href="./variables.tf#L32"><code>variables.tf#L32</code></a>

</details>
</blockquote><!-- variable:"vm_id":end -->
<blockquote><!-- variable:"vm_ip":start -->

### `vm_ip` (**Required**)

VM IP (v4)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L42"><code>variables.tf#L42</code></a>

</details>
</blockquote><!-- variable:"vm_ip":end -->
<blockquote><!-- variable:"flatcar_image_channel":start -->

### `flatcar_image_channel` (*Optional*)

Image channel of the FlatCar image (alpha, beta, stable)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "stable"
  ```
  In file: <a href="./variables.tf#L119"><code>variables.tf#L119</code></a>

</details>
</blockquote><!-- variable:"flatcar_image_channel":end -->
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
  false
  ```
  In file: <a href="./variables.tf#L26"><code>variables.tf#L26</code></a>

</details>
</blockquote><!-- variable:"proxmox_insecure":end -->
<blockquote><!-- variable:"vm_network_interface_name":start -->

### `vm_network_interface_name` (*Optional*)

Name of the network interface in the VM (e.g. eth0)

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
  In file: <a href="./variables.tf#L72"><code>variables.tf#L72</code></a>

</details>
</blockquote><!-- variable:"vm_network_interface_name":end -->