# OIDC (Zitadel) module

This module creates a project and application and grants a specified admin user (if set) permissions to it.

This module is as rigid as I need it, but of course it does not (yet?) allow for e.g. roles assignments etc. since I do not use them currently.

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Resources](#resources)
  - _zitadel_action_.[this](#zitadel_actionthis)
  - _zitadel_application_oidc_.[this](#zitadel_application_oidcthis)
  - _zitadel_project_.[this](#zitadel_projectthis)
  - _zitadel_project_role_.[this](#zitadel_project_rolethis)
  - _zitadel_trigger_actions_.[this](#zitadel_trigger_actionsthis)
  - _zitadel_user_grant_.[this](#zitadel_user_grantthis)
- [Variables](#variables)
  - [app_type](#app_type-required) (**Required**)
  - [application_name](#application_name-required) (**Required**)
  - [auth_method_type](#auth_method_type-required) (**Required**)
  - [grant_types](#grant_types-required) (**Required**)
  - [org_name](#org_name-required) (**Required**)
  - [post_logout_redirect_uris](#post_logout_redirect_uris-required) (**Required**)
  - [project_name](#project_name-required) (**Required**)
  - [redirect_uris](#redirect_uris-required) (**Required**)
  - [response_types](#response_types-required) (**Required**)
  - [access_token_role_assertion](#access_token_role_assertion-optional) (*Optional*)
  - [access_token_type](#access_token_type-optional) (*Optional*)
  - [actions](#actions-optional) (*Optional*)
  - [admin_user](#admin_user-optional) (*Optional*)
  - [id_token_role_assertion](#id_token_role_assertion-optional) (*Optional*)
  - [id_token_userinfo_assertion](#id_token_userinfo_assertion-optional) (*Optional*)
  - [project_roles](#project_roles-optional) (*Optional*)
- [Outputs](#outputs)
  - [client_id](#client_id)
  - [client_secret](#client_secret)
  - [project_id](#project_id)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)

## Resources
  
<blockquote><!-- resource:"zitadel_action.this":start -->

### _zitadel_action_.`this`

Create all actions
  <table>
    <tr>
      <td>Provider</td>
      <td><code>zitadel (zitadel/zitadel)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L108"><code>main.tf#L108</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"zitadel_action.this":end -->
<blockquote><!-- resource:"zitadel_application_oidc.this":start -->

### _zitadel_application_oidc_.`this`

Application to create in the newly created project.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>zitadel (zitadel/zitadel)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L57"><code>main.tf#L57</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"zitadel_application_oidc.this":end -->
<blockquote><!-- resource:"zitadel_project.this":start -->

### _zitadel_project_.`this`

Project to create in the organization found via the data source `zitadel_orgs`.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>zitadel (zitadel/zitadel)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L49"><code>main.tf#L49</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"zitadel_project.this":end -->
<blockquote><!-- resource:"zitadel_project_role.this":start -->

### _zitadel_project_role_.`this`

Project roles to create
  <table>
    <tr>
      <td>Provider</td>
      <td><code>zitadel (zitadel/zitadel)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L75"><code>main.tf#L75</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"zitadel_project_role.this":end -->
<blockquote><!-- resource:"zitadel_trigger_actions.this":start -->

### _zitadel_trigger_actions_.`this`

Assign actions to triggers
  <table>
    <tr>
      <td>Provider</td>
      <td><code>zitadel (zitadel/zitadel)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L119"><code>main.tf#L119</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"zitadel_trigger_actions.this":end -->
<blockquote><!-- resource:"zitadel_user_grant.this":start -->

### _zitadel_user_grant_.`this`

Grant project to user (if set)
  <table>
    <tr>
      <td>Provider</td>
      <td><code>zitadel (zitadel/zitadel)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L97"><code>main.tf#L97</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"zitadel_user_grant.this":end -->

## Variables
  
<blockquote><!-- variable:"app_type":start -->

### `app_type` (**Required**)

Application type

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L16"><code>variables.tf#L16</code></a>

</details>
</blockquote><!-- variable:"app_type":end -->
<blockquote><!-- variable:"application_name":start -->

### `application_name` (**Required**)

Name of the application to create in the project

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L11"><code>variables.tf#L11</code></a>

</details>
</blockquote><!-- variable:"application_name":end -->
<blockquote><!-- variable:"auth_method_type":start -->

### `auth_method_type` (**Required**)

Auth-method type

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L21"><code>variables.tf#L21</code></a>

</details>
</blockquote><!-- variable:"auth_method_type":end -->
<blockquote><!-- variable:"grant_types":start -->

### `grant_types` (**Required**)

Grant types

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(string)
  ```
  In file: <a href="./variables.tf#L36"><code>variables.tf#L36</code></a>

</details>
</blockquote><!-- variable:"grant_types":end -->
<blockquote><!-- variable:"org_name":start -->

### `org_name` (**Required**)

Name of the organization to create the project in (must be `active`)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L1"><code>variables.tf#L1</code></a>

</details>
</blockquote><!-- variable:"org_name":end -->
<blockquote><!-- variable:"post_logout_redirect_uris":start -->

### `post_logout_redirect_uris` (**Required**)

Post-logout redirectURIs

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(string)
  ```
  In file: <a href="./variables.tf#L66"><code>variables.tf#L66</code></a>

</details>
</blockquote><!-- variable:"post_logout_redirect_uris":end -->
<blockquote><!-- variable:"project_name":start -->

### `project_name` (**Required**)

Name of the project to create in the organization

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  In file: <a href="./variables.tf#L6"><code>variables.tf#L6</code></a>

</details>
</blockquote><!-- variable:"project_name":end -->
<blockquote><!-- variable:"redirect_uris":start -->

### `redirect_uris` (**Required**)

RedirectURIs

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(string)
  ```
  In file: <a href="./variables.tf#L26"><code>variables.tf#L26</code></a>

</details>
</blockquote><!-- variable:"redirect_uris":end -->
<blockquote><!-- variable:"response_types":start -->

### `response_types` (**Required**)

Response types

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(string)
  ```
  In file: <a href="./variables.tf#L31"><code>variables.tf#L31</code></a>

</details>
</blockquote><!-- variable:"response_types":end -->
<blockquote><!-- variable:"access_token_role_assertion":start -->

### `access_token_role_assertion` (*Optional*)

Whether the roles in the access token are to be asserted or not

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  bool
  ```
  **Default**:
  ```json
  false
  ```
  In file: <a href="./variables.tf#L48"><code>variables.tf#L48</code></a>

</details>
</blockquote><!-- variable:"access_token_role_assertion":end -->
<blockquote><!-- variable:"access_token_type":start -->

### `access_token_type` (*Optional*)

Access token type (Bearer Token or JWT)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "OIDC_TOKEN_TYPE_BEARER"
  ```
  In file: <a href="./variables.tf#L41"><code>variables.tf#L41</code></a>

</details>
</blockquote><!-- variable:"access_token_type":end -->
<blockquote><!-- variable:"actions":start -->

### `actions` (*Optional*)

List of Zitadel actions to create and assign to flows

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  list(object({
    name            = string
    script          = string
    timeout         = optional(string, "10s")
    allowed_to_fail = optional(bool, false)
    triggers = list(object({
      flow_type    = string # e.g., "FLOW_TYPE_CUSTOMISE_TOKEN"
      trigger_type = string # e.g., "TRIGGER_TYPE_PRE_USERINFO_CREATION"
    }))
  }))
  ```
  **Default**:
  ```json
  []
  ```
  In file: <a href="./variables.tf#L88"><code>variables.tf#L88</code></a>

</details>
</blockquote><!-- variable:"actions":end -->
<blockquote><!-- variable:"admin_user":start -->

### `admin_user` (*Optional*)

Administrator of the project; user `user_name` or leave empty if unknown or set manually at a later point

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  null
  ```
  In file: <a href="./variables.tf#L71"><code>variables.tf#L71</code></a>

</details>
</blockquote><!-- variable:"admin_user":end -->
<blockquote><!-- variable:"id_token_role_assertion":start -->

### `id_token_role_assertion` (*Optional*)

Whether to add the roles directly to the ID token

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  bool
  ```
  **Default**:
  ```json
  false
  ```
  In file: <a href="./variables.tf#L54"><code>variables.tf#L54</code></a>

</details>
</blockquote><!-- variable:"id_token_role_assertion":end -->
<blockquote><!-- variable:"id_token_userinfo_assertion":start -->

### `id_token_userinfo_assertion` (*Optional*)

Whether to include information such as email in the ID token

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  bool
  ```
  **Default**:
  ```json
  false
  ```
  In file: <a href="./variables.tf#L60"><code>variables.tf#L60</code></a>

</details>
</blockquote><!-- variable:"id_token_userinfo_assertion":end -->
<blockquote><!-- variable:"project_roles":start -->

### `project_roles` (*Optional*)

Roles to create for the project in Zitadel (the key is the `role_key` name)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  map(object({
    display_name = string
    group        = string
  }))
  ```
  **Default**:
  ```json
  {}
  ```
  In file: <a href="./variables.tf#L78"><code>variables.tf#L78</code></a>

</details>
</blockquote><!-- variable:"project_roles":end -->

## Outputs
  
<blockquote><!-- output:"client_id":start -->

#### `client_id`

Client ID

In file: <a href="./outputs.tf#L1"><code>outputs.tf#L1</code></a>
</blockquote><!-- output:"client_id":end -->
<blockquote><!-- output:"client_secret":start -->

#### `client_secret`

Client secret

In file: <a href="./outputs.tf#L7"><code>outputs.tf#L7</code></a>
</blockquote><!-- output:"client_secret":end -->
<blockquote><!-- output:"project_id":start -->

#### `project_id`

Zitadel project ID

In file: <a href="./outputs.tf#L13"><code>outputs.tf#L13</code></a>
</blockquote><!-- output:"project_id":end -->