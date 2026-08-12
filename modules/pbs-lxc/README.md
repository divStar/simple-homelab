# PBS LXC Setup

This module sets up Proxmox Backup Server in a Debian LXC container, using
/mnt/backup/pbs (bind-mounted from the host) as the datastore location.
Replaces modules/pbs-vm as the deployed PBS instance -- that module is kept
in the repo as a fallback option, but no longer applied. Reuses that VM's
former IP/MAC so sanctum-pbs.my.world keeps working unchanged.

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Modules](#modules) _(nested and adjacent)_
  - [setup_container](#setup_container)
- [Resources](#resources)
  - _ssh_resource_.[create_daily_update_override_directory](#ssh_resourcecreate_daily_update_override_directory)
  - _ssh_resource_.[install_pbs](#ssh_resourceinstall_pbs)
  - _ssh_resource_.[prepare_datastore_directory](#ssh_resourceprepare_datastore_directory)
  - _ssh_resource_.[retime_daily_update](#ssh_resourceretime_daily_update)
  - _ssh_resource_.[setup_acme](#ssh_resourcesetup_acme)
  - _ssh_resource_.[setup_datastore](#ssh_resourcesetup_datastore)
  - _terraform_data_.[container_trigger](#terraform_datacontainer_trigger)
- [Variables](#variables)
  - [proxmox](#proxmox-required) (**Required**)
  - [step_ca_acme_contact](#step_ca_acme_contact-required) (**Required**)
  - [step_ca_client_version](#step_ca_client_version-required) (**Required**)
  - [step_ca_domain](#step_ca_domain-required) (**Required**)
  - [pbs_datastore_name](#pbs_datastore_name-optional) (*Optional*)
  - [step_ca_acme_account_name](#step_ca_acme_account_name-optional) (*Optional*)
- [Outputs](#outputs)
  - [container_ip](#container_ip)
  - [pbs_datastore_name](#pbs_datastore_name)
  - [root_password](#root_password)
  - [ssh_private_key](#ssh_private_key)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![proxmox](https://img.shields.io/badge/proxmox->=0.111.1-1e73c8?logo=proxmox)
![random](https://img.shields.io/badge/random->=3.9.0-82d72c?logo=random)
![loafoe/ssh](https://img.shields.io/badge/loafoe--ssh->=2.7.0-4fa4f9?logo=ssh)

## Modules
  
<blockquote><!-- module:"setup_container":start -->

### `setup_container`

Debian LXC container setup
  <table>
    <tr>
      <td>Module location</td>
      <td><code>../common/modules/debian</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L66"><code>main.tf#L66</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="../common/modules/debian/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"setup_container":end -->

## Resources
  
<blockquote><!-- resource:"ssh_resource.create_daily_update_override_directory":start -->

### _ssh_resource_.`create_daily_update_override_directory`

systemd drop-in directories are never auto-created (a convention admins/ tooling create themselves, not something the base unit's package provides) and loafoe/ssh's file{} block doesn't create missing parent directories either -- confirmed by pihole's own create_pihole_directory precedent for the exact same reason. Needs its own preceding step, not combined with the file push below.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L240"><code>main.tf#L240</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.create_daily_update_override_directory":end -->
<blockquote><!-- resource:"ssh_resource.install_pbs":start -->

### _ssh_resource_.`install_pbs`

Install PBS itself (deb822 apt source + package). Connects as root directly, no sudo -- unlike pbs-vm's cloud-image VM (which blocks root SSH by default, hence its debian+sudo pattern), common/modules/debian's LXC template has no such restriction; pihole's entire main.tf already connects as root the same way. No qemu-guest-agent either -- that's QEMU/KVM-specific (talks over a virtio-serial channel the hypervisor provides to a VM); LXC containers share the host kernel directly, so there's no such channel and nothing for an agent to do.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L127"><code>main.tf#L127</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.install_pbs":end -->
<blockquote><!-- resource:"ssh_resource.prepare_datastore_directory":start -->

### _ssh_resource_.`prepare_datastore_directory`

Prepare the host-side datastore directory before the container references it as a mount point -- LXC mount_points need the host path to already exist, and Proxmox doesn't create it automatically. Chowned to 100000:100000 (this host's confirmed unprivileged UID/GID mapping base, from /etc/subuid: "root:100000:65536") ONLY on first-ever bootstrap, so container-root can initially write into it. Confirmed the hard way (2026-08-09, destroy/rebuild test): PBS's own `datastore create` takes ownership of this same directory itself, as the "backup" system user (uid 34 -> host 100034), once a real datastore is created in it -- unconditionally re-chowning to 100000:100000 on every apply stomps that back to root and breaks --reuse-datastore on the next rebuild ("permissions or owner not correct"). Same "assume data already exists" principle files/setup-datastore.sh already follows.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L52"><code>main.tf#L52</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.prepare_datastore_directory":end -->
<blockquote><!-- resource:"ssh_resource.retime_daily_update":start -->

### _ssh_resource_.`retime_daily_update`

Retime PBS's own daily-update service (package updates + ACME cert renewal -- they're the same bundled job, not separable, confirmed on modules/pbs-vm) off its default 1AM+5h-jitter schedule, which lands in the 2-3AM window the home router does its own reconnect. Fixed 4AM, no jitter -- same fix pbs-vm needed, for the same underlying reason (this is PBS's own timer, not anything VM/LXC-specific). A systemd drop-in, not an edit of the vendor-shipped unit, so it survives a proxmox-backup-server package upgrade.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L263"><code>main.tf#L263</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.retime_daily_update":end -->
<blockquote><!-- resource:"ssh_resource.setup_acme":start -->

### _ssh_resource_.`setup_acme`

Get PBS a trusted cert from Step CA via ACME -- identical to modules/pbs-vm, the mechanism (PBS's own built-in ACME client) doesn't care whether PBS is running in a VM or an LXC. Depends on install_pbs directly (also needs proxmox-backup-manager), not on setup_datastore -- the two don't actually depend on each other, only on PBS being installed, so there's no reason to serialize one after the other.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L203"><code>main.tf#L203</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.setup_acme":end -->
<blockquote><!-- resource:"ssh_resource.setup_datastore":start -->

### _ssh_resource_.`setup_datastore`

Register (or re-register) the PBS datastore at the mount_point path -- see files/setup-datastore.sh for why this assumes existing data by default rather than assuming an empty directory. Needs proxmox-backup-manager, hence depends on install_pbs directly.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L169"><code>main.tf#L169</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.setup_datastore":end -->
<blockquote><!-- resource:"terraform_data.container_trigger":start -->

### _terraform_data_.`container_trigger`

Trigger for container replacement - module outputs aren't valid replace_triggered_by references on their own (only resources are; confirmed via `tofu validate`: "Only resources, count.index, and each.key may be used in replace_triggered_by"), hence wrapping it in a terraform_data resource. Uses triggers_replace, NOT input -- confirmed via `tofu plan -replace` that terraform_data's .id stays stable across a plain input-only update (only regenerated when the terraform_data resource itself is destroyed/recreated). triggers_replace is the argument specifically documented to force that full replacement whenever its value changes, which is what actually makes .id change and propagate. modules/samba and modules/pihole both currently use `input = ...` for this same pattern, which means their own replace_triggered_by chains have this identical latent bug -- worth fixing there too.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>terraform (hashicorp/terraform)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L115"><code>main.tf#L115</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"terraform_data.container_trigger":end -->

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
  In file: <a href="./variables.tf#L2"><code>variables.tf#L2</code></a>

</details>
</blockquote><!-- variable:"proxmox":end -->
<blockquote><!-- variable:"step_ca_acme_contact":start -->

### `step_ca_acme_contact` (**Required**)

Contact email for the ACME account

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L47"><code>variables.tf#L47</code></a>

</details>
</blockquote><!-- variable:"step_ca_acme_contact":end -->
<blockquote><!-- variable:"step_ca_client_version":start -->

### `step_ca_client_version` (**Required**)

Version of the step CLI to install

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L34"><code>variables.tf#L34</code></a>

</details>
</blockquote><!-- variable:"step_ca_client_version":end -->
<blockquote><!-- variable:"step_ca_domain":start -->

### `step_ca_domain` (**Required**)

Step CA domain (ACME directory is served at https://<this>/acme/<account>/directory)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L28"><code>variables.tf#L28</code></a>

</details>
</blockquote><!-- variable:"step_ca_domain":end -->
<blockquote><!-- variable:"pbs_datastore_name":start -->

### `pbs_datastore_name` (*Optional*)

Name PBS itself uses internally for the datastore (shows up in the PBS UI/API, and in proxmox-backup-client --repository references). Matches the /mnt/datastore/primary mount path by design -- PBS's own removable-datastore convention names the path after the datastore, and this stays consistent with that even though this datastore isn't actually removable.

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "primary"
  ```
  In file: <a href="./variables.tf#L19"><code>variables.tf#L19</code></a>

</details>
</blockquote><!-- variable:"pbs_datastore_name":end -->
<blockquote><!-- variable:"step_ca_acme_account_name":start -->

### `step_ca_acme_account_name` (*Optional*)

ACME account name to register with Step CA

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
  In file: <a href="./variables.tf#L40"><code>variables.tf#L40</code></a>

</details>
</blockquote><!-- variable:"step_ca_acme_account_name":end -->

## Outputs
  
<blockquote><!-- output:"container_ip":start -->

#### `container_ip`

PBS LXC IP address

In file: <a href="./outputs.tf#L17"><code>outputs.tf#L17</code></a>
</blockquote><!-- output:"container_ip":end -->
<blockquote><!-- output:"pbs_datastore_name":start -->

#### `pbs_datastore_name`

Name PBS uses internally for its datastore

In file: <a href="./outputs.tf#L22"><code>outputs.tf#L22</code></a>
</blockquote><!-- output:"pbs_datastore_name":end -->
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