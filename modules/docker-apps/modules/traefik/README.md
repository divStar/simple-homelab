# Traefik dashboard OIDC

This module uses the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary `client_id` to set up OIDC/OAuth for Traefik (dashboard) with Zitadel.

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Modules](#modules) _(nested and adjacent)_
  - [traefik_dashboard_oidc](#traefik_dashboard_oidc)
- [Variables](#variables)
- [Outputs](#outputs)
  - [client_id](#client_id)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![zitadel](https://img.shields.io/badge/zitadel->=2.3.0-ee4398?logo=zitadel)

## Modules
  
<blockquote><!-- module:"traefik_dashboard_oidc":start -->

### `traefik_dashboard_oidc`

Call to the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary resources in Zitadel.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>../../../common/modules/oidc</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L28"><code>main.tf#L28</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="../../../common/modules/oidc/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"traefik_dashboard_oidc":end -->

## Outputs
  
<blockquote><!-- output:"client_id":start -->

#### `client_id`

Traefik Client ID

In file: <a href="./main.tf#L46"><code>main.tf#L46</code></a>
</blockquote><!-- output:"client_id":end -->