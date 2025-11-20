# Portainer OIDC

This module uses the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary `client_id` and `client_secret` to set up OIDC/OAuth in Portainer with Zitadel.

## Contents

<blockquote><!-- contents:start -->

- [Requirements](#requirements)
- [Providers](#providers)
- [Modules](#modules) _(nested and adjacent)_
  - [portainer_web_ui_oidc](#portainer_web_ui_oidc)
- [Resources](#resources)
  - _portainer_settings_.[this](#portainer_settingsthis)
- [Variables](#variables)
  - [portainer_password](#portainer_password-required) (**Required**)
- [Outputs](#outputs)
  - [client_id](#client_id)
  - [client_secret](#client_secret)
</blockquote><!-- contents:end -->

## Requirements
![opentofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![portainer](https://img.shields.io/badge/portainer--portainer->=1.17.0-d52a7f?logo=portainer)
![zitadel](https://img.shields.io/badge/zitadel->=2.3.0-ee4398?logo=zitadel)

## Providers
![portainer/portainer](https://img.shields.io/badge/portainer--portainer->=1.17.0-d52a7f)

## Modules
  
<blockquote><!-- module:"portainer_web_ui_oidc":start -->

### `portainer_web_ui_oidc`

Call to the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary resources in Zitadel.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>../../../common/modules/oidc</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L44"><code>main.tf#L44</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="../../../common/modules/oidc/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"portainer_web_ui_oidc":end -->

## Resources
  
<blockquote><!-- resource:"portainer_settings.this":start -->

### _portainer_settings_.`this`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>portainer (portainer/portainer)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L61"><code>main.tf#L61</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"portainer_settings.this":end -->

## Variables
  
<blockquote><!-- variable:"portainer_password":start -->

### `portainer_password` (**Required**)

Containers the portainer password

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./main.tf#L38"><code>main.tf#L38</code></a>

</details>
</blockquote><!-- variable:"portainer_password":end -->

## Outputs
  
<blockquote><!-- output:"client_id":start -->

#### `client_id`

Portainer Client ID

In file: <a href="./main.tf#L80"><code>main.tf#L80</code></a>
</blockquote><!-- output:"client_id":end -->
<blockquote><!-- output:"client_secret":start -->

#### `client_secret`

Portainer Client Secret

In file: <a href="./main.tf#L87"><code>main.tf#L87</code></a>
</blockquote><!-- output:"client_secret":end -->