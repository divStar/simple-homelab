# Scanopy Daemon (standalone LXC)

Runs a standalone `scanopy-daemon` in a Debian LXC container, dual-homed onto
every VLAN (`vmbr1.5/10/20/30/40`) so it has genuine ARP-level presence on
each subnet - unlike SNMP-relayed discovery (via OPNsense's ARP/routing
tables), this catches hosts with no open ports and gets real MACs directly.

Replaces the native `scanopy-daemon` process that previously ran directly on
the Proxmox host (sanctum) for this same purpose - moving it into an
isolated LXC avoids giving the hypervisor itself a routable presence on
every VLAN. sanctum's own `snmpd`/`lldpd` (exposing its *physical* NIC's
LLDP neighbor data) are unrelated to this daemon and stay in place.

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Modules](#modules) _(nested and adjacent)_
  - [setup_container](#setup_container)
- [Resources](#resources)
  - _ssh_resource_.[configure_timezone](#ssh_resourceconfigure_timezone)
  - _ssh_resource_.[install_scanopy_daemon](#ssh_resourceinstall_scanopy_daemon)
  - _terraform_data_.[container_trigger](#terraform_datacontainer_trigger)
- [Variables](#variables)
  - [proxmox](#proxmox-required) (**Required**)
  - [scanopy_daemon_api_key](#scanopy_daemon_api_key-required) (**Required**)
- [Outputs](#outputs)
  - [root_password](#root_password)
  - [ssh_private_key](#ssh_private_key)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![proxmox](https://img.shields.io/badge/proxmox->=0.111.1-1e73c8?logo=proxmox)
![random](https://img.shields.io/badge/random->=3.9.0-82d72c?logo=random)
![loafoe/ssh](https://img.shields.io/badge/loafoe--ssh->=2.7.0-4fa4f9?logo=ssh)
![tls](https://img.shields.io/badge/tls->=4.3.0-54a9fe?logo=tls)

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
      <td><a href="./main.tf#L39"><code>main.tf#L39</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="../common/modules/debian/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"setup_container":end -->

## Resources
  
<blockquote><!-- resource:"ssh_resource.configure_timezone":start -->

### _ssh_resource_.`configure_timezone`

Set the container timezone
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L70"><code>main.tf#L70</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.configure_timezone":end -->
<blockquote><!-- resource:"ssh_resource.install_scanopy_daemon":start -->

### _ssh_resource_.`install_scanopy_daemon`

Install the daemon and register it with the Scanopy server. allow-self-signed-certs is needed the same way it was on the native sanctum daemon - the server's cert isn't in the daemon's compiled-in (rustls/webpki-roots) trust store; see scanopy/scanopy#708 upstream. Left with no --interfaces restriction (default: "all interfaces"), so it picks up every one of the five VLAN interfaces above.  Uninstalls any existing registration first (harmless no-op on a fresh container) - `scanopy-daemon install` alone only overwrites config.json and restarts the same systemd unit, which never tells the *server* the old daemon identity is gone. Without this, changing scanopy_daemon_api_key (e.g. after an org reset) would silently orphan the previous daemon_id as a stale, never-cleaned-up entry in Scanopy's own Daemons list.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L98"><code>main.tf#L98</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.install_scanopy_daemon":end -->
<blockquote><!-- resource:"terraform_data.container_trigger":start -->

### _terraform_data_.`container_trigger`

Trigger for container replacement - see modules/pihole/main.tf for why this pattern (terraform_data wrapping container_id) is needed on every ssh_resource below rather than relying on depends_on alone.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>terraform (hashicorp/terraform)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L65"><code>main.tf#L65</code></a></td>
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
<blockquote><!-- variable:"scanopy_daemon_api_key":start -->

### `scanopy_daemon_api_key` (**Required**)

API key for this scanopy-daemon instance, issued by the Scanopy server

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L17"><code>variables.tf#L17</code></a>

</details>
</blockquote><!-- variable:"scanopy_daemon_api_key":end -->

## Outputs
  
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