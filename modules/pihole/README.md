# Pi-hole Setup

This module sets up Pi-hole in a Debian LXC container using the provided information.

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Modules](#modules) _(nested and adjacent)_
  - [setup_container](#setup_container)
- [Resources](#resources)
  - _ssh_resource_.[configure_admin_password](#ssh_resourceconfigure_admin_password)
  - _ssh_resource_.[configure_cert_renewal_timer](#ssh_resourceconfigure_cert_renewal_timer)
  - _ssh_resource_.[configure_provisioner_password](#ssh_resourceconfigure_provisioner_password)
  - _ssh_resource_.[configure_timezone](#ssh_resourceconfigure_timezone)
  - _ssh_resource_.[configure_upstream_dns](#ssh_resourceconfigure_upstream_dns)
  - _ssh_resource_.[create_pihole_directory](#ssh_resourcecreate_pihole_directory)
  - _ssh_resource_.[install_pihole](#ssh_resourceinstall_pihole)
  - _ssh_resource_.[install_step_cli](#ssh_resourceinstall_step_cli)
  - _ssh_resource_.[request_pihole_certificate](#ssh_resourcerequest_pihole_certificate)
  - _ssh_resource_.[run_gravity_update](#ssh_resourcerun_gravity_update)
  - _ssh_resource_.[seed_pihole_config](#ssh_resourceseed_pihole_config)
- [Variables](#variables)
  - [pihole_admin_password](#pihole_admin_password-required) (**Required**)
  - [proxmox](#proxmox-required) (**Required**)
  - [step_ca_client_version](#step_ca_client_version-required) (**Required**)
  - [step_ca_domain](#step_ca_domain-required) (**Required**)
  - [step_ca_provisioner](#step_ca_provisioner-required) (**Required**)
  - [step_ca_provisioner_password](#step_ca_provisioner_password-required) (**Required**)
  - [upstream_dns](#upstream_dns-optional) (*Optional*)
- [Outputs](#outputs)
  - [root_password](#root_password)
  - [ssh_private_key](#ssh_private_key)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![proxmox](https://img.shields.io/badge/proxmox->=0.85.1-1e73c8?logo=proxmox)
![random](https://img.shields.io/badge/random->=3.7.2-82d72c?logo=random)
![loafoe/ssh](https://img.shields.io/badge/loafoe--ssh->=2.7.0-4fa4f9?logo=ssh)
![tls](https://img.shields.io/badge/tls->=4.1.0-54a9fe?logo=tls)

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
      <td><a href="./main.tf#L14"><code>main.tf#L14</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="../common/modules/debian/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"setup_container":end -->

## Resources
  
<blockquote><!-- resource:"ssh_resource.configure_admin_password":start -->

### _ssh_resource_.`configure_admin_password`

Set the admin password via the CLI so it gets hashed correctly
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L160"><code>main.tf#L160</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.configure_admin_password":end -->
<blockquote><!-- resource:"ssh_resource.configure_cert_renewal_timer":start -->

### _ssh_resource_.`configure_cert_renewal_timer`

Renew the certificate every 12 hours - Step CA issues 24h-lived certs, same cadence docker-vm already uses for the same reason. Doesn't need to wait for Pi-hole to be installed - only for pihole-cert.sh to already be on disk.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L205"><code>main.tf#L205</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.configure_cert_renewal_timer":end -->
<blockquote><!-- resource:"ssh_resource.configure_provisioner_password":start -->

### _ssh_resource_.`configure_provisioner_password`

Store the provisioner password in a file rather than passing it as a raw CLI argument (keeps it out of the process list / shell history)
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L85"><code>main.tf#L85</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.configure_provisioner_password":end -->
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
      <td><a href="./main.tf#L38"><code>main.tf#L38</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.configure_timezone":end -->
<blockquote><!-- resource:"ssh_resource.configure_upstream_dns":start -->

### _ssh_resource_.`configure_upstream_dns`

Upstream DNS servers - the one setting Terraform keeps managing after first boot
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L190"><code>main.tf#L190</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.configure_upstream_dns":end -->
<blockquote><!-- resource:"ssh_resource.create_pihole_directory":start -->

### _ssh_resource_.`create_pihole_directory`

Ensure /etc/pihole exists before the certificate and seed config are pushed into it
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L51"><code>main.tf#L51</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.create_pihole_directory":end -->
<blockquote><!-- resource:"ssh_resource.install_pihole":start -->

### _ssh_resource_.`install_pihole`

Run the official Pi-hole installer, unattended. The pre-seeded pihole.toml above is what makes --unattended actually skip prompts, and since the certificate already exists by this point, Pi-hole comes up HTTPS-only from the very first start.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L145"><code>main.tf#L145</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.install_pihole":end -->
<blockquote><!-- resource:"ssh_resource.install_step_cli":start -->

### _ssh_resource_.`install_step_cli`

Install the step CLI and bootstrap trust in Step CA, so Pi-hole's own webserver can get a real certificate instead of depending on Traefik
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L65"><code>main.tf#L65</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.install_step_cli":end -->
<blockquote><!-- resource:"ssh_resource.request_pihole_certificate":start -->

### _ssh_resource_.`request_pihole_certificate`

Request the certificate for Pi-hole's webserver *before* Pi-hole itself is installed, so the seeded pihole.toml below can declare HTTPS-only from the start instead of ever falling back to plain HTTP.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L102"><code>main.tf#L102</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.request_pihole_certificate":end -->
<blockquote><!-- resource:"ssh_resource.run_gravity_update":start -->

### _ssh_resource_.`run_gravity_update`

One-time resource: the installer sets up cron and its own weekly gravity update job (/etc/cron.d/pihole), but apparently doesn't run gravity itself during an unattended install (yet?) - without this, Pi-hole is up and resolving but not actually blocking anything until that cron job first fires on its own, up to a week later.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L177"><code>main.tf#L177</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.run_gravity_update":end -->
<blockquote><!-- resource:"ssh_resource.seed_pihole_config":start -->

### _ssh_resource_.`seed_pihole_config`

Push the seed pihole.toml. This is a one-time bootstrap so the unattended installer below has a config to work with - Pi-hole's own UI/API is the source of truth for everything in it afterward.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L125"><code>main.tf#L125</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.seed_pihole_config":end -->

## Variables
  
<blockquote><!-- variable:"pihole_admin_password":start -->

### `pihole_admin_password` (**Required**)

Pi-hole web interface admin password

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L17"><code>variables.tf#L17</code></a>

</details>
</blockquote><!-- variable:"pihole_admin_password":end -->
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
<blockquote><!-- variable:"step_ca_client_version":start -->

### `step_ca_client_version` (**Required**)

Version of the step CLI to install

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L37"><code>variables.tf#L37</code></a>

</details>
</blockquote><!-- variable:"step_ca_client_version":end -->
<blockquote><!-- variable:"step_ca_domain":start -->

### `step_ca_domain` (**Required**)

Domain of the Step CA server used to issue Pi-hole's webserver TLS certificate

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L31"><code>variables.tf#L31</code></a>

</details>
</blockquote><!-- variable:"step_ca_domain":end -->
<blockquote><!-- variable:"step_ca_provisioner":start -->

### `step_ca_provisioner` (**Required**)

Step CA provisioner name used to issue Pi-hole's webserver TLS certificate

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L43"><code>variables.tf#L43</code></a>

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
  In file: <a href="./variables.tf#L49"><code>variables.tf#L49</code></a>

</details>
</blockquote><!-- variable:"step_ca_provisioner_password":end -->
<blockquote><!-- variable:"upstream_dns":start -->

### `upstream_dns` (*Optional*)

Upstream DNS servers for Pi-hole to forward non-local queries to

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(string)
  ```
  **Default**:
  ```json
  [
  "8.8.8.8",
  "8.8.4.4"
]
  ```
  In file: <a href="./variables.tf#L24"><code>variables.tf#L24</code></a>

</details>
</blockquote><!-- variable:"upstream_dns":end -->

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