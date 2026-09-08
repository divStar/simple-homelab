# Homarr OIDC

This module uses the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary `client_id` and `client_secret` to set up OIDC/OAuth in Homarr with Zitadel.

Homarr is fully env-var driven; no post-boot API setup is required (unlike Portainer/Jellyfin). All OIDC config produced here flows into the module's `stack.env` via the `homarr_oidc_env_vars` output.

Only the initial admin user (`igor.voronin@my.world`) is granted a role here. Any other user's group membership (`homarr_admin` / `homarr_user`) is managed by hand in the Zitadel console, not in Terraform.

## Notes

- Storage is SQLite, not Postgres - no sidecar DB needed.
- Docker socket mounted `:ro` (read-only stats widget); not a real isolation boundary, fine since nothing here is internet-facing.
- `AUTH_PROVIDERS=oidc,credentials` keeps local login as a fallback.
- `AUTH_OIDC_TOKEN_ENDPOINT_AUTH_METHOD=client_secret_basic` matches `OIDC_AUTH_METHOD_TYPE_BASIC` below - switch both to POST if login fails.
- Board access is per-board, not per-tile. Admin/family/anonymous split needs 3 boards created by hand, each group's default board set in Homarr's UI.
- `AUTH_OIDC_GROUPS_ATTRIBUTE=roles`, not `groups` - Zitadel's shared `flatRoles` Action (also used by Prometheus/Alloy's Traefik middleware, don't change it) writes to a `roles` claim. Its own doc comment claims `"{projectId}:{roleName}"` format, but verified by testing: the actual value is the bare role key (e.g. `homarr_admin`) - Homarr's group name must match that, not the prefixed form.
- `zitadel` provider resolved to v3.4.0 here (others are on `2.12.7`) - has a real diff on `zitadel_application_oidc` (`org_id` forces replacement) on subsequent plans; don't `apply` untargeted or it'll rotate the OIDC client secret.
- Homarr trusts integration certs via its own `/appdata/trusted-certificates` store, separate from `NODE_EXTRA_CA_CERTS`. Only the Root CA is needed (Traefik sends the Intermediate itself). Fetched via `data.http.sanctum_root_ca`, pushed to the Docker VM with `scripts/upload-configs.sh --dest /mnt/data/step-ca --input modules/docker-apps/modules/homarr/files`.
- Proxmox integration uses its own read-only `homarr@pve` / `PVEAuditor` API user+token via `bpg/proxmox`, modeled on `modules/host/modules/terraform-user`. Paste `homarr_proxmox_integration` output into Homarr's integration form.

<!-- docs-meta: order=230 icon=homarr -->

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Modules](#modules) _(nested and adjacent)_
  - [homarr_web_ui_oidc](#homarr_web_ui_oidc)
- [Resources](#resources)
  - _local_file_.[sanctum_root_ca](#local_filesanctum_root_ca)
  - _proxmox_acl_.[homarr_api_group](#proxmox_aclhomarr_api_group)
  - _proxmox_acl_.[homarr_api_token](#proxmox_aclhomarr_api_token)
  - _proxmox_user_token_.[homarr](#proxmox_user_tokenhomarr)
  - _proxmox_virtual_environment_group_.[homarr_api](#proxmox_virtual_environment_grouphomarr_api)
  - _proxmox_virtual_environment_user_.[homarr_api](#proxmox_virtual_environment_userhomarr_api)
  - _random_password_.[homarr_proxmox_user](#random_passwordhomarr_proxmox_user)
- [Variables](#variables)
  - [proxmox](#proxmox-required) (**Required**)
- [Outputs](#outputs)
  - [client_id](#client_id)
  - [client_secret](#client_secret)
  - [homarr_oidc_env_vars](#homarr_oidc_env_vars)
  - [homarr_proxmox_integration](#homarr_proxmox_integration)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![hashicorp/http](https://img.shields.io/badge/hashicorp--http->=3.4.0-c1166b?logo=http)
![hashicorp/local](https://img.shields.io/badge/hashicorp--local->=2.5.0-0c61b6?logo=local)
![bpg/proxmox](https://img.shields.io/badge/bpg--proxmox->=0.111.1-1e73c8?logo=proxmox)
![hashicorp/random](https://img.shields.io/badge/hashicorp--random->=3.9.0-82d72c?logo=random)
![zitadel](https://img.shields.io/badge/zitadel->=2.5.0-ee4398?logo=zitadel)

## Modules
  
<blockquote><!-- module:"homarr_web_ui_oidc":start -->

### `homarr_web_ui_oidc`

Call to the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary resources in Zitadel.
  <table>
    <tr>
      <td>Module location</td>
      <td><code>../../../common/modules/oidc</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L75"><code>main.tf#L75</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="../../../common/modules/oidc/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"homarr_web_ui_oidc":end -->

## Resources
  
<blockquote><!-- resource:"local_file.sanctum_root_ca":start -->

### _local_file_.`sanctum_root_ca`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>local (hashicorp/local)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L165"><code>main.tf#L165</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"local_file.sanctum_root_ca":end -->
<blockquote><!-- resource:"proxmox_acl.homarr_api_group":start -->

### _proxmox_acl_.`homarr_api_group`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>proxmox (bpg/proxmox)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L136"><code>main.tf#L136</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"proxmox_acl.homarr_api_group":end -->
<blockquote><!-- resource:"proxmox_acl.homarr_api_token":start -->

### _proxmox_acl_.`homarr_api_token`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>proxmox (bpg/proxmox)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L150"><code>main.tf#L150</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"proxmox_acl.homarr_api_token":end -->
<blockquote><!-- resource:"proxmox_user_token.homarr":start -->

### _proxmox_user_token_.`homarr`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>proxmox (bpg/proxmox)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L143"><code>main.tf#L143</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"proxmox_user_token.homarr":end -->
<blockquote><!-- resource:"proxmox_virtual_environment_group.homarr_api":start -->

### _proxmox_virtual_environment_group_.`homarr_api`

Read-only Proxmox API user for Homarr's Proxmox integration widget. Modeled on `modules/host/modules/terraform-user`'s shape, via `bpg/proxmox` resources instead of `pveum` over SSH. `PVEAuditor` is a built-in role - no custom role resource needed.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>proxmox (bpg/proxmox)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L118"><code>main.tf#L118</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"proxmox_virtual_environment_group.homarr_api":end -->
<blockquote><!-- resource:"proxmox_virtual_environment_user.homarr_api":start -->

### _proxmox_virtual_environment_user_.`homarr_api`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>proxmox (bpg/proxmox)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L129"><code>main.tf#L129</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"proxmox_virtual_environment_user.homarr_api":end -->
<blockquote><!-- resource:"random_password.homarr_proxmox_user":start -->

### _random_password_.`homarr_proxmox_user`

Required by the `pve` realm even though only the token below is actually used for auth.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>random (hashicorp/random)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L124"><code>main.tf#L124</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"random_password.homarr_proxmox_user":end -->

## Variables
  
<blockquote><!-- variable:"proxmox":start -->

### `proxmox` (**Required**)

Proxmox API connection details, used to create Homarr's own read-only PVEAuditor API user/token. Reduced from the shared shape used elsewhere in this repo (no ssh_user/ssh_key) since only bpg/proxmox API calls happen here, no SSH-based provisioning.

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  object({
    host     = string
    insecure = bool
    username = string
    password = string
  })
  ```
  In file: <a href="./variables.tf#L1"><code>variables.tf#L1</code></a>

</details>
</blockquote><!-- variable:"proxmox":end -->

## Outputs
  
<blockquote><!-- output:"client_id":start -->

#### `client_id`

Homarr Client ID

In file: <a href="./main.tf#L185"><code>main.tf#L185</code></a>
</blockquote><!-- output:"client_id":end -->
<blockquote><!-- output:"client_secret":start -->

#### `client_secret`

Homarr Client Secret

In file: <a href="./main.tf#L192"><code>main.tf#L192</code></a>
</blockquote><!-- output:"client_secret":end -->
<blockquote><!-- output:"homarr_oidc_env_vars":start -->

#### `homarr_oidc_env_vars`

Copy and paste these into the `stack.env` file

In file: <a href="./main.tf#L171"><code>main.tf#L171</code></a>
</blockquote><!-- output:"homarr_oidc_env_vars":end -->
<blockquote><!-- output:"homarr_proxmox_integration":start -->

#### `homarr_proxmox_integration`

Proxmox integration credentials for Homarr's UI (Username / Realm / Token ID / API Key)

In file: <a href="./main.tf#L199"><code>main.tf#L199</code></a>
</blockquote><!-- output:"homarr_proxmox_integration":end -->