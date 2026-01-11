# Grafana OIDC

This module uses the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary `client_id` to set up OIDC/OAuth in Grafana with Zitadel.

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Modules](#modules) _(nested and adjacent)_
  - [grafana_web_ui_oidc](#grafana_web_ui_oidc)
- [Resources](#resources)
  - _grafana_sso_settings_.[name](#grafana_sso_settingsname)
- [Variables](#variables)
  - [admin_password](#admin_password-required) (**Required**)
  - [admin_user](#admin_user-required) (**Required**)
- [Outputs](#outputs)
  - [client_id](#client_id)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![grafana/grafana](https://img.shields.io/badge/grafana--grafana->=4.17.0-d1267b?logo=grafana)
![zitadel](https://img.shields.io/badge/zitadel->=2.5.0-ee4398?logo=zitadel)

## Modules
  
<blockquote><!-- module:"grafana_web_ui_oidc":start -->

### `grafana_web_ui_oidc`

Call to the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary resources in Zitadel.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>../../../common/modules/oidc</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L55"><code>main.tf#L55</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="../../../common/modules/oidc/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"grafana_web_ui_oidc":end -->

## Resources
  
<blockquote><!-- resource:"grafana_sso_settings.name":start -->

### _grafana_sso_settings_.`name`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>grafana (grafana/grafana)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L93"><code>main.tf#L93</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"grafana_sso_settings.name":end -->

## Variables
  
<blockquote><!-- variable:"admin_password":start -->

### `admin_password` (**Required**)

Grafana admin password

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./main.tf#L33"><code>main.tf#L33</code></a>

</details>
</blockquote><!-- variable:"admin_password":end -->
<blockquote><!-- variable:"admin_user":start -->

### `admin_user` (**Required**)

Grafana admin username

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./main.tf#L27"><code>main.tf#L27</code></a>

</details>
</blockquote><!-- variable:"admin_user":end -->

## Outputs
  
<blockquote><!-- output:"client_id":start -->

#### `client_id`

Grafana Client ID

In file: <a href="./main.tf#L122"><code>main.tf#L122</code></a>
</blockquote><!-- output:"client_id":end -->