# External (Docker) resources

This module creates resources, that are not supposed to be part of a `docker-compose.yml`.

It e.g. creates networks and volumes, that should not be removed if a docker compose stack is undeployed.

## Contents

<blockquote><!-- contents:start -->

- [Requirements](#requirements)
- [Providers](#providers)
- [Resources](#resources)
  - _docker_network_.[this](#docker_networkthis)
  - _docker_volume_.[this](#docker_volumethis)
- [Variables](#variables)
  - [remote_docker_host](#remote_docker_host-required) (**Required**)
  - [ssl_client_certificates](#ssl_client_certificates-required) (**Required**)
  - [networks](#networks-optional) (*Optional*)
  - [volumes](#volumes-optional) (*Optional*)
- [Outputs](#outputs)
  - [networks](#networks)
  - [volumes](#volumes)
</blockquote><!-- contents:end -->

## Requirements
![opentofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![docker](https://img.shields.io/badge/kreuzwerker--docker-3.8.0-79ce23?logo=docker)

## Providers
![kreuzwerker/docker](https://img.shields.io/badge/kreuzwerker--docker-3.8.0-79ce23)

## Resources
  
<blockquote><!-- resource:"docker_network.this":start -->

### _docker_network_.`this`

Set up Docker networks, which will be used as `external` networks
  <table>
    <tr>
      <td>Provider</td>
      <td><code>docker (kreuzwerker/docker)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L10"><code>main.tf#L10</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"docker_network.this":end -->
<blockquote><!-- resource:"docker_volume.this":start -->

### _docker_volume_.`this`

Set up Docker volumes, which will be used as `external` volumes
  <table>
    <tr>
      <td>Provider</td>
      <td><code>docker (kreuzwerker/docker)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L31"><code>main.tf#L31</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"docker_volume.this":end -->

## Variables
  
<blockquote><!-- variable:"remote_docker_host":start -->

### `remote_docker_host` (**Required**)

IP/Hostname of the Docker instance to use

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L1"><code>variables.tf#L1</code></a>

</details>
</blockquote><!-- variable:"remote_docker_host":end -->
<blockquote><!-- variable:"ssl_client_certificates":start -->

### `ssl_client_certificates` (**Required**)

Path to the `ca.pem`, the `cert.pem` and the `key.pem` certificates.

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L6"><code>variables.tf#L6</code></a>

</details>
</blockquote><!-- variable:"ssl_client_certificates":end -->
<blockquote><!-- variable:"networks":start -->

### `networks` (*Optional*)

Networks in Docker to create

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  map(object({
    subnet  = string
    gateway = string
    driver  = optional(string)
    labels  = optional(map(string), {})
  }))
  ```
  **Default**:
  ```json
  {}
  ```
  In file: <a href="./variables.tf#L11"><code>variables.tf#L11</code></a>

</details>
</blockquote><!-- variable:"networks":end -->
<blockquote><!-- variable:"volumes":start -->

### `volumes` (*Optional*)

Volumes in Docker to create (to be used as `external` volumes)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  map(object({
    labels      = optional(map(string), {})
    driver      = optional(string)
    driver_opts = optional(map(string), null)
  }))
  ```
  **Default**:
  ```json
  {}
  ```
  In file: <a href="./variables.tf#L22"><code>variables.tf#L22</code></a>

</details>
</blockquote><!-- variable:"volumes":end -->

## Outputs
  
<blockquote><!-- output:"networks":start -->

#### `networks`

Networks in Docker

In file: <a href="./outputs.tf#L1"><code>outputs.tf#L1</code></a>
</blockquote><!-- output:"networks":end -->
<blockquote><!-- output:"volumes":start -->

#### `volumes`

Volumes in Docker

In file: <a href="./outputs.tf#L16"><code>outputs.tf#L16</code></a>
</blockquote><!-- output:"volumes":end -->