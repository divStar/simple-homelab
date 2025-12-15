

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Modules](#modules) _(nested and adjacent)_
  - [jellyfin_web_ui_oidc](#jellyfin_web_ui_oidc)
- [Resources](#resources)
  - _restapi_object_.[jellyfin_sso](#restapi_objectjellyfin_sso)
- [Variables](#variables)
  - [jellyfin_api_key](#jellyfin_api_key-required) (**Required**)
- [Outputs](#outputs)
  - [client_id](#client_id)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![mastercard/restapi](https://img.shields.io/badge/mastercard--restapi->=2.0.1-f94ea3?logo=restapi)
![zitadel](https://img.shields.io/badge/zitadel->=2.3.0-ee4398?logo=zitadel)

## Modules
  
<blockquote><!-- module:"jellyfin_web_ui_oidc":start -->

### `jellyfin_web_ui_oidc`

Call to the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary resources in Zitadel.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>../../../common/modules/oidc</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main-before-automation.tf#L54"><code>main-before-automation.tf#L54</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="../../../common/modules/oidc/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"jellyfin_web_ui_oidc":end -->

## Resources
  
<blockquote><!-- resource:"restapi_object.jellyfin_sso":start -->

### _restapi_object_.`jellyfin_sso`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>restapi (mastercard/restapi)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main-before-automation.tf#L135"><code>main-before-automation.tf#L135</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"restapi_object.jellyfin_sso":end -->

## Variables
  
<blockquote><!-- variable:"jellyfin_api_key":start -->

### `jellyfin_api_key` (**Required**)

API key to use to access the Jellyfin API

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./main-before-automation.tf#L27"><code>main-before-automation.tf#L27</code></a>

</details>
</blockquote><!-- variable:"jellyfin_api_key":end -->

## Outputs
  
<blockquote><!-- output:"client_id":start -->

#### `client_id`

Jellyfin Client ID

In file: <a href="./main-before-automation.tf#L163"><code>main-before-automation.tf#L163</code></a>
</blockquote><!-- output:"client_id":end -->