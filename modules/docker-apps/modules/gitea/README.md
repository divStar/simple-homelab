# Gitea OIDC

Creates the necessary Zitadel resources (project, OIDC app, roles, user grants)
for Gitea to authenticate via Zitadel SSO.

## Deployment order

  1. `tofu apply` — creates Zitadel project, app, roles, and grants
  2. Copy the `stack_env_guide` output values into `stack.env`
  3. `docker compose up` — starts Gitea; `gitea-init` registers the auth
     source automatically using the values from `stack.env`

## Role mapping (via the `flatRoles` Zitadel Action)

  The existing `flatRoles` Action flattens Zitadel project roles into a
  plain `roles` array in the token, e.g. ["gitea\_admin", "gitea\_user"].
  Gitea reads this via --group-claim-name=roles and maps:
    gitea\_admin  →  Gitea administrator
    gitea\_user   →  regular Gitea user (default for any authenticated user)

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Modules](#modules) _(nested and adjacent)_
  - [gitea_web_ui_oidc](#gitea_web_ui_oidc)
- [Variables](#variables)
- [Outputs](#outputs)
  - [client_id](#client_id)
  - [client_secret](#client_secret)
  - [oidc_discovery_url](#oidc_discovery_url)
  - [stack_env_guide](#stack_env_guide)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![zitadel](https://img.shields.io/badge/zitadel->=2.5.0-ee4398?logo=zitadel)

## Modules
  
<blockquote><!-- module:"gitea_web_ui_oidc":start -->

### `gitea_web_ui_oidc`


  <table>
    <tr>
      <td>Module location</td>
      <td><code>../../../common/modules/oidc</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L45"><code>main.tf#L45</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="../../../common/modules/oidc/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"gitea_web_ui_oidc":end -->

## Outputs
  
<blockquote><!-- output:"client_id":start -->

#### `client_id`

Zitadel client ID for Gitea

In file: <a href="./main.tf#L118"><code>main.tf#L118</code></a>
</blockquote><!-- output:"client_id":end -->
<blockquote><!-- output:"client_secret":start -->

#### `client_secret`

Zitadel client secret for Gitea

In file: <a href="./main.tf#L124"><code>main.tf#L124</code></a>
</blockquote><!-- output:"client_secret":end -->
<blockquote><!-- output:"oidc_discovery_url":start -->

#### `oidc_discovery_url`

Zitadel OpenID Connect auto-discovery URL

In file: <a href="./main.tf#L130"><code>main.tf#L130</code></a>
</blockquote><!-- output:"oidc_discovery_url":end -->
<blockquote><!-- output:"stack_env_guide":start -->

#### `stack_env_guide`

Paste these values into stack.env, then run docker compose up

In file: <a href="./main.tf#L97"><code>main.tf#L97</code></a>
</blockquote><!-- output:"stack_env_guide":end -->