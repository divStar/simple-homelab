# Outline OIDC

This module uses the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary `client_id` and `client_secret` to set up OIDC/OAuth in Outline with Zitadel.

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Modules](#modules) _(nested and adjacent)_
  - [outline_web_ui_oidc](#outline_web_ui_oidc)
- [Variables](#variables)
- [Outputs](#outputs)
  - [client_id](#client_id)
  - [client_secret](#client_secret)
  - [outline_oidc_env_vars](#outline_oidc_env_vars)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![zitadel](https://img.shields.io/badge/zitadel->=2.5.0-ee4398?logo=zitadel)

## Modules
  
<blockquote><!-- module:"outline_web_ui_oidc":start -->

### `outline_web_ui_oidc`

Call to the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary resources in Zitadel.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>../../../common/modules/oidc</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L32"><code>main.tf#L32</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="../../../common/modules/oidc/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"outline_web_ui_oidc":end -->

## Outputs
  
<blockquote><!-- output:"client_id":start -->

#### `client_id`

Outline Client ID

In file: <a href="./main.tf#L82"><code>main.tf#L82</code></a>
</blockquote><!-- output:"client_id":end -->
<blockquote><!-- output:"client_secret":start -->

#### `client_secret`

Outline Client ID

In file: <a href="./main.tf#L89"><code>main.tf#L89</code></a>
</blockquote><!-- output:"client_secret":end -->
<blockquote><!-- output:"outline_oidc_env_vars":start -->

#### `outline_oidc_env_vars`

Copy and paste these into the `stack.env` file

In file: <a href="./main.tf#L67"><code>main.tf#L67</code></a>
</blockquote><!-- output:"outline_oidc_env_vars":end -->