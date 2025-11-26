# Grafana Alloy and Prometheus OIDC

This module uses the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary `client_id`
to set up OIDC/OAuth for Grafana Alloy and Prometheus with Zitadel.

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Modules](#modules) _(nested and adjacent)_
  - [grafana_alloy_oidc](#grafana_alloy_oidc)
  - [prometheus_oidc](#prometheus_oidc)
- [Variables](#variables)
- [Outputs](#outputs)
  - [alloy_client_id](#alloy_client_id)
  - [prometheus_client_id](#prometheus_client_id)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![zitadel](https://img.shields.io/badge/zitadel->=2.3.0-ee4398?logo=zitadel)

## Modules
  
<blockquote><!-- module:"grafana_alloy_oidc":start -->

### `grafana_alloy_oidc`

Call to the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary resources in Zitadel.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>../../../common/modules/oidc</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L51"><code>main.tf#L51</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="../../../common/modules/oidc/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"grafana_alloy_oidc":end -->
<blockquote><!-- module:"prometheus_oidc":start -->

### `prometheus_oidc`

Call to the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary resources in Zitadel.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>../../../common/modules/oidc</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L33"><code>main.tf#L33</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="../../../common/modules/oidc/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"prometheus_oidc":end -->

## Outputs
  
<blockquote><!-- output:"alloy_client_id":start -->

#### `alloy_client_id`

Grafana Alloy Client ID

In file: <a href="./main.tf#L76"><code>main.tf#L76</code></a>
</blockquote><!-- output:"alloy_client_id":end -->
<blockquote><!-- output:"prometheus_client_id":start -->

#### `prometheus_client_id`

Prometheus Client ID

In file: <a href="./main.tf#L69"><code>main.tf#L69</code></a>
</blockquote><!-- output:"prometheus_client_id":end -->