# Scanopy OIDC

This module uses the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary `client_id` and `client_secret` to set up OIDC/OAuth in Scanopy with Zitadel.

Scanopy's OIDC support supplements rather than replaces its own username/password login - users
link it to their existing account via Account Settings. Config is a mounted `oidc.toml` file
(fixed container path `/oidc.toml`), not env vars - Scanopy's own format, not ours.

<!-- docs-meta: order=220 icon=scanopy,postgres -->

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Modules](#modules) _(nested and adjacent)_
  - [scanopy_web_ui_oidc](#scanopy_web_ui_oidc)
- [Variables](#variables)
- [Outputs](#outputs)
  - [client_id](#client_id)
  - [client_secret](#client_secret)
  - [scanopy_oidc_toml](#scanopy_oidc_toml)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![zitadel](https://img.shields.io/badge/zitadel->=2.5.0-ee4398?logo=zitadel)

## Modules
  
<blockquote><!-- module:"scanopy_web_ui_oidc":start -->

### `scanopy_web_ui_oidc`

Call to the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary resources in Zitadel.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>../../../common/modules/oidc</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L38"><code>main.tf#L38</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="../../../common/modules/oidc/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"scanopy_web_ui_oidc":end -->

## Outputs
  
<blockquote><!-- output:"client_id":start -->

#### `client_id`

Scanopy Client ID

In file: <a href="./main.tf#L91"><code>main.tf#L91</code></a>
</blockquote><!-- output:"client_id":end -->
<blockquote><!-- output:"client_secret":start -->

#### `client_secret`

Scanopy Client Secret

In file: <a href="./main.tf#L98"><code>main.tf#L98</code></a>
</blockquote><!-- output:"client_secret":end -->
<blockquote><!-- output:"scanopy_oidc_toml":start -->

#### `scanopy_oidc_toml`

Copy and paste this into oidc.toml

In file: <a href="./main.tf#L76"><code>main.tf#L76</code></a>
</blockquote><!-- output:"scanopy_oidc_toml":end -->