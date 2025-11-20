# Portainer OIDC

This module uses the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary `client_id` and `client_secret` to set up OIDC/OAuth in Portainer with Zitadel.

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Modules](#modules) _(nested and adjacent)_
  - [portainer_web_ui_oidc](#portainer_web_ui_oidc)
- [Resources](#resources)
  - _restapi_object_.[portainer_admin_init](#restapi_objectportainer_admin_init)
  - _restapi_object_.[portainer_jwt](#restapi_objectportainer_jwt)
  - _restapi_object_.[portainer_license](#restapi_objectportainer_license)
  - _restapi_object_.[portainer_settings](#restapi_objectportainer_settings)
- [Variables](#variables)
  - [admin_password](#admin_password-required) (**Required**)
  - [portainer_license](#portainer_license-required) (**Required**)
- [Outputs](#outputs)
  - [client_id](#client_id)
  - [client_secret](#client_secret)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![mastercard/restapi](https://img.shields.io/badge/mastercard--restapi->=2.0.1-f94ea3?logo=restapi)
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
      <td><a href="./main.tf#L112"><code>main.tf#L112</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="../../../common/modules/oidc/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"portainer_web_ui_oidc":end -->

## Resources
  
<blockquote><!-- resource:"restapi_object.portainer_admin_init":start -->

### _restapi_object_.`portainer_admin_init`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>restapi (mastercard/restapi)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L75"><code>main.tf#L75</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"restapi_object.portainer_admin_init":end -->
<blockquote><!-- resource:"restapi_object.portainer_jwt":start -->

### _restapi_object_.`portainer_jwt`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>restapi (mastercard/restapi)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L86"><code>main.tf#L86</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"restapi_object.portainer_jwt":end -->
<blockquote><!-- resource:"restapi_object.portainer_license":start -->

### _restapi_object_.`portainer_license`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>restapi (mastercard/restapi)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L99"><code>main.tf#L99</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"restapi_object.portainer_license":end -->
<blockquote><!-- resource:"restapi_object.portainer_settings":start -->

### _restapi_object_.`portainer_settings`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>restapi (mastercard/restapi)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L157"><code>main.tf#L157</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"restapi_object.portainer_settings":end -->

## Variables
  
<blockquote><!-- variable:"admin_password":start -->

### `admin_password` (**Required**)

Portainer admin password

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./main.tf#L28"><code>main.tf#L28</code></a>

</details>
</blockquote><!-- variable:"admin_password":end -->
<blockquote><!-- variable:"portainer_license":start -->

### `portainer_license` (**Required**)

Portainer license key

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./main.tf#L35"><code>main.tf#L35</code></a>

</details>
</blockquote><!-- variable:"portainer_license":end -->

## Outputs
  
<blockquote><!-- output:"client_id":start -->

#### `client_id`

Portainer Client ID

In file: <a href="./main.tf#L191"><code>main.tf#L191</code></a>
</blockquote><!-- output:"client_id":end -->
<blockquote><!-- output:"client_secret":start -->

#### `client_secret`

Portainer Client Secret

In file: <a href="./main.tf#L198"><code>main.tf#L198</code></a>
</blockquote><!-- output:"client_secret":end -->