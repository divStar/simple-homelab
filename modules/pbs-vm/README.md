# PBS VM Setup

This module sets up a Debian VM running Proxmox Backup Server.

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Resources](#resources)
  - _proxmox_download_file_.[debian_image](#proxmox_download_filedebian_image)
  - _proxmox_virtual_environment_vm_.[pbs](#proxmox_virtual_environment_vmpbs)
  - _random_password_.[root_password](#random_passwordroot_password)
  - _ssh_resource_.[install_pbs](#ssh_resourceinstall_pbs)
  - _ssh_resource_.[retime_daily_update](#ssh_resourceretime_daily_update)
  - _ssh_resource_.[setup_acme](#ssh_resourcesetup_acme)
  - _ssh_resource_.[setup_datastore](#ssh_resourcesetup_datastore)
- [Variables](#variables)
  - [datastore_disk_datastore_id](#datastore_disk_datastore_id-required) (**Required**)
  - [debian_image_datastore_id](#debian_image_datastore_id-required) (**Required**)
  - [debian_image_file_name](#debian_image_file_name-required) (**Required**)
  - [efi_disk_datastore_id](#efi_disk_datastore_id-required) (**Required**)
  - [os_disk_datastore_id](#os_disk_datastore_id-required) (**Required**)
  - [proxmox_endpoint](#proxmox_endpoint-required) (**Required**)
  - [proxmox_node_name](#proxmox_node_name-required) (**Required**)
  - [proxmox_password](#proxmox_password-required) (**Required**)
  - [proxmox_ssh_key](#proxmox_ssh_key-required) (**Required**)
  - [proxmox_ssh_user](#proxmox_ssh_user-required) (**Required**)
  - [step_ca_acme_contact](#step_ca_acme_contact-required) (**Required**)
  - [step_ca_domain](#step_ca_domain-required) (**Required**)
  - [vm_dns_ip](#vm_dns_ip-required) (**Required**)
  - [vm_domain](#vm_domain-required) (**Required**)
  - [vm_gateway_ip](#vm_gateway_ip-required) (**Required**)
  - [vm_hostname](#vm_hostname-required) (**Required**)
  - [vm_id](#vm_id-required) (**Required**)
  - [vm_ip](#vm_ip-required) (**Required**)
  - [datastore_disk_size_gb](#datastore_disk_size_gb-optional) (*Optional*)
  - [debian_image_release](#debian_image_release-optional) (*Optional*)
  - [os_disk_size_gb](#os_disk_size_gb-optional) (*Optional*)
  - [pbs_datastore_name](#pbs_datastore_name-optional) (*Optional*)
  - [proxmox_insecure](#proxmox_insecure-optional) (*Optional*)
  - [step_ca_acme_account_name](#step_ca_acme_account_name-optional) (*Optional*)
- [Outputs](#outputs)
  - [pbs_datastore_name](#pbs_datastore_name)
  - [root_password](#root_password)
  - [vm_ip](#vm_ip)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![bpg/proxmox](https://img.shields.io/badge/bpg--proxmox-~>0.111-1e73c8?logo=proxmox)
![hashicorp/random](https://img.shields.io/badge/hashicorp--random->=3.7.2-82d72c?logo=random)
![loafoe/ssh](https://img.shields.io/badge/loafoe--ssh->=2.7.0-4fa4f9?logo=ssh)

## Resources
  
<blockquote><!-- resource:"proxmox_download_file.debian_image":start -->

### _proxmox_download_file_.`debian_image`

Download Debian genericcloud image (proxmox_download_file, not the deprecated proxmox_virtual_environment_download_file docker-vm still uses)
  <table>
    <tr>
      <td>Provider</td>
      <td><code>proxmox (bpg/proxmox)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L37"><code>main.tf#L37</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"proxmox_download_file.debian_image":end -->
<blockquote><!-- resource:"proxmox_virtual_environment_vm.pbs":start -->

### _proxmox_virtual_environment_vm_.`pbs`

Create the PBS VM
  <table>
    <tr>
      <td>Provider</td>
      <td><code>proxmox (bpg/proxmox)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L49"><code>main.tf#L49</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"proxmox_virtual_environment_vm.pbs":end -->
<blockquote><!-- resource:"random_password.root_password":start -->

### _random_password_.`root_password`

Recoverable root password (console access; day-to-day access is via the shared operator SSH key, same as docker-vm)
  <table>
    <tr>
      <td>Provider</td>
      <td><code>random (hashicorp/random)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L22"><code>main.tf#L22</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"random_password.root_password":end -->
<blockquote><!-- resource:"ssh_resource.install_pbs":start -->

### _ssh_resource_.`install_pbs`

Install PBS itself (deb822 apt source + package)
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L152"><code>main.tf#L152</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.install_pbs":end -->
<blockquote><!-- resource:"ssh_resource.retime_daily_update":start -->

### _ssh_resource_.`retime_daily_update`

Retime PBS's own daily-update service (package updates + ACME cert renewal -- they're the same bundled job, not separable) off its default 1AM+5h-jitter schedule, which lands in the 2-3AM window the home router does its own reconnect. Fixed 4AM, no jitter. A systemd drop-in, not an edit of the vendor-shipped unit, so it survives a proxmox-backup-server package upgrade.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L267"><code>main.tf#L267</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.retime_daily_update":end -->
<blockquote><!-- resource:"ssh_resource.setup_acme":start -->

### _ssh_resource_.`setup_acme`

Get PBS a trusted cert from Step CA via ACME
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L230"><code>main.tf#L230</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.setup_acme":end -->
<blockquote><!-- resource:"ssh_resource.setup_datastore":start -->

### _ssh_resource_.`setup_datastore`

Format/mount the datastore disk and create the PBS datastore on it
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L199"><code>main.tf#L199</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.setup_datastore":end -->

## Variables
  
<blockquote><!-- variable:"datastore_disk_datastore_id":start -->

### `datastore_disk_datastore_id` (**Required**)

Proxmox location for the PBS datastore disk (the new /mnt/backup-backed storage)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L113"><code>variables.tf#L113</code></a>

</details>
</blockquote><!-- variable:"datastore_disk_datastore_id":end -->
<blockquote><!-- variable:"debian_image_datastore_id":start -->

### `debian_image_datastore_id` (**Required**)

Proxmox location for the Debian cloud image

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L80"><code>variables.tf#L80</code></a>

</details>
</blockquote><!-- variable:"debian_image_datastore_id":end -->
<blockquote><!-- variable:"debian_image_file_name":start -->

### `debian_image_file_name` (**Required**)

Filename of the Debian cloud image

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L85"><code>variables.tf#L85</code></a>

</details>
</blockquote><!-- variable:"debian_image_file_name":end -->
<blockquote><!-- variable:"efi_disk_datastore_id":start -->

### `efi_disk_datastore_id` (**Required**)

Proxmox location for the EFI disk

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L97"><code>variables.tf#L97</code></a>

</details>
</blockquote><!-- variable:"efi_disk_datastore_id":end -->
<blockquote><!-- variable:"os_disk_datastore_id":start -->

### `os_disk_datastore_id` (**Required**)

Proxmox location for the OS disk

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L102"><code>variables.tf#L102</code></a>

</details>
</blockquote><!-- variable:"os_disk_datastore_id":end -->
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
<blockquote><!-- variable:"proxmox_node_name":start -->

### `proxmox_node_name` (**Required**)

Proxmox node name

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L7"><code>variables.tf#L7</code></a>

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
  In file: <a href="./variables.tf#L12"><code>variables.tf#L12</code></a>

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
  In file: <a href="./variables.tf#L22"><code>variables.tf#L22</code></a>

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
  In file: <a href="./variables.tf#L17"><code>variables.tf#L17</code></a>

</details>
</blockquote><!-- variable:"proxmox_ssh_user":end -->
<blockquote><!-- variable:"step_ca_acme_contact":start -->

### `step_ca_acme_contact` (**Required**)

Contact email for the ACME account

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L145"><code>variables.tf#L145</code></a>

</details>
</blockquote><!-- variable:"step_ca_acme_contact":end -->
<blockquote><!-- variable:"step_ca_domain":start -->

### `step_ca_domain` (**Required**)

Step CA domain (ACME directory is served at https://<this>/acme/<account>/directory)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L134"><code>variables.tf#L134</code></a>

</details>
</blockquote><!-- variable:"step_ca_domain":end -->
<blockquote><!-- variable:"vm_dns_ip":start -->

### `vm_dns_ip` (**Required**)

VM DNS IP (v4)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L69"><code>variables.tf#L69</code></a>

</details>
</blockquote><!-- variable:"vm_dns_ip":end -->
<blockquote><!-- variable:"vm_domain":start -->

### `vm_domain` (**Required**)

VM Domain for the host

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L44"><code>variables.tf#L44</code></a>

</details>
</blockquote><!-- variable:"vm_domain":end -->
<blockquote><!-- variable:"vm_gateway_ip":start -->

### `vm_gateway_ip` (**Required**)

VM gateway IP (v4)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L59"><code>variables.tf#L59</code></a>

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
  In file: <a href="./variables.tf#L39"><code>variables.tf#L39</code></a>

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
  In file: <a href="./variables.tf#L34"><code>variables.tf#L34</code></a>

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
  In file: <a href="./variables.tf#L49"><code>variables.tf#L49</code></a>

</details>
</blockquote><!-- variable:"vm_ip":end -->
<blockquote><!-- variable:"datastore_disk_size_gb":start -->

### `datastore_disk_size_gb` (*Optional*)

PBS datastore disk size in GB -- thin-provisioned, only consumes real space as data is written

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  number
  ```
  **Default**:
  ```json
  8000
  ```
  In file: <a href="./variables.tf#L118"><code>variables.tf#L118</code></a>

</details>
</blockquote><!-- variable:"datastore_disk_size_gb":end -->
<blockquote><!-- variable:"debian_image_release":start -->

### `debian_image_release` (*Optional*)

Debian release codename (e.g. trixie) used both for the cloud image URL and the Proxmox apt repo suite

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "trixie"
  ```
  In file: <a href="./variables.tf#L90"><code>variables.tf#L90</code></a>

</details>
</blockquote><!-- variable:"debian_image_release":end -->
<blockquote><!-- variable:"os_disk_size_gb":start -->

### `os_disk_size_gb` (*Optional*)

OS disk size in GB

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  number
  ```
  **Default**:
  ```json
  32
  ```
  In file: <a href="./variables.tf#L107"><code>variables.tf#L107</code></a>

</details>
</blockquote><!-- variable:"os_disk_size_gb":end -->
<blockquote><!-- variable:"pbs_datastore_name":start -->

### `pbs_datastore_name` (*Optional*)

Name PBS itself uses internally for the datastore (shows up in the PBS UI/API, and in proxmox-backup-client --repository references)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "main"
  ```
  In file: <a href="./variables.tf#L125"><code>variables.tf#L125</code></a>

</details>
</blockquote><!-- variable:"pbs_datastore_name":end -->
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
  In file: <a href="./variables.tf#L27"><code>variables.tf#L27</code></a>

</details>
</blockquote><!-- variable:"proxmox_insecure":end -->
<blockquote><!-- variable:"step_ca_acme_account_name":start -->

### `step_ca_acme_account_name` (*Optional*)

ACME account name to register with Step CA (reusing the same account name convention as modules/step-ca's own PVE-host ACME setup)

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
</blockquote><!-- variable:"step_ca_acme_account_name":end -->

## Outputs
  
<blockquote><!-- output:"pbs_datastore_name":start -->

#### `pbs_datastore_name`

Name PBS uses internally for its datastore

In file: <a href="./outputs.tf#L16"><code>outputs.tf#L16</code></a>
</blockquote><!-- output:"pbs_datastore_name":end -->
<blockquote><!-- output:"root_password":start -->

#### `root_password`

Root password

In file: <a href="./outputs.tf#L2"><code>outputs.tf#L2</code></a>
</blockquote><!-- output:"root_password":end -->
<blockquote><!-- output:"vm_ip":start -->

#### `vm_ip`

PBS VM IP address

In file: <a href="./outputs.tf#L11"><code>outputs.tf#L11</code></a>
</blockquote><!-- output:"vm_ip":end -->