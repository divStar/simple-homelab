# Jellyfin Web UI OIDC

This module uses the [OIDC module](../../../common/modules/oidc/README.md) to create the necessary `client_id`
to set up OIDC/OAuth for Jellyfin (dashboard) with Zitadel.

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Modules](#modules) _(nested and adjacent)_
  - [jellyfin_web_ui_oidc](#jellyfin_web_ui_oidc)
- [Variables](#variables)
  - [admin_password](#admin_password-required) (**Required**)
  - [admin_username](#admin_username-optional) (*Optional*)
  - [libraries](#libraries-optional) (*Optional*)
  - [roles](#roles-optional) (*Optional*)
- [Outputs](#outputs)
  - [client_id](#client_id)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![restapi](https://img.shields.io/badge/restapi->=2.0.1-f94ea3?logo=restapi)
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
      <td><a href="./main.tf#L80"><code>main.tf#L80</code></a></td>
    </tr>
    <tr>
      <td colspan="2"><a href="../../../common/modules/oidc/README.md">README.md</a> <em>(experimental)</em></td>
    </tr>
  </table>
</blockquote><!-- module:"jellyfin_web_ui_oidc":end -->

## Variables
  
<blockquote><!-- variable:"admin_password":start -->

### `admin_password` (**Required**)

Admin password for Jellyfin initial setup

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./main.tf#L37"><code>main.tf#L37</code></a>

</details>
</blockquote><!-- variable:"admin_password":end -->
<blockquote><!-- variable:"admin_username":start -->

### `admin_username` (*Optional*)

Admin username for Jellyfin initial setup

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "admin"
  ```
  In file: <a href="./main.tf#L31"><code>main.tf#L31</code></a>

</details>
</blockquote><!-- variable:"admin_username":end -->
<blockquote><!-- variable:"libraries":start -->

### `libraries` (*Optional*)

Libraries

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  map(object({
    group        = string
    display_name = string
  }))
  ```
  **Default**:
  ```json
  {
  "animated": {
    "display_name": "Animated",
    "group": "video"
  },
  "anime": {
    "display_name": "Anime",
    "group": "video"
  },
  "concerts": {
    "display_name": "Concerts",
    "group": "video"
  },
  "e-movies": {
    "display_name": "E-movies",
    "group": "video"
  },
  "igor": {
    "display_name": "Igor's photos",
    "group": "photo"
  },
  "mariia": {
    "display_name": "Mariia's photos",
    "group": "photo"
  },
  "movies": {
    "display_name": "Movies",
    "group": "video"
  },
  "music": {
    "display_name": "Music",
    "group": "music"
  },
  "r-movies": {
    "display_name": "Russian movies",
    "group": "video"
  },
  "series": {
    "display_name": "TV series",
    "group": "video"
  },
  "vacation": {
    "display_name": "Vacation photos",
    "group": "photo"
  },
  "yuliia": {
    "display_name": "Yuliia's photos",
    "group": "photo"
  },
  "yuliia-похудение": {
    "display_name": "Yuliia похудение",
    "group": "yuliia"
  },
  "yuliia-разное": {
    "display_name": "Yuliia разное",
    "group": "yuliia"
  }
}
  ```
  In file: <a href="./variables.tf#L7"><code>variables.tf#L7</code></a>

</details>
</blockquote><!-- variable:"libraries":end -->
<blockquote><!-- variable:"roles":start -->

### `roles` (*Optional*)

Roles

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  set(string)
  ```
  **Default**:
  ```json
  [
  "jellyfin-admin",
  "jellyfin-user"
]
  ```
  In file: <a href="./variables.tf#L1"><code>variables.tf#L1</code></a>

</details>
</blockquote><!-- variable:"roles":end -->

## Outputs
  
<blockquote><!-- output:"client_id":start -->

#### `client_id`

Jellyfin Client ID

In file: <a href="./main.tf#L197"><code>main.tf#L197</code></a>
</blockquote><!-- output:"client_id":end -->