# Backup Jobs

Registers Proxmox Backup Server as a PVE storage target, creates one
dedicated backup job per guest (VM/LXC primary disks), and one host-level
folder backup per entry in var.folders (real data the guest-level jobs
never touch - bind-mounted LXC state, the family file shares, PVE's own
recovery-relevant config).

## Contents

<blockquote><!-- contents:start -->

- [Providers](#providers)
- [Resources](#resources)
  - _proxmox_backup_job_.[this](#proxmox_backup_jobthis)
  - _proxmox_storage_pbs_.[this](#proxmox_storage_pbsthis)
  - _ssh_resource_.[create_folder_backup_config_dir](#ssh_resourcecreate_folder_backup_config_dir)
  - _ssh_resource_.[create_pbs_token](#ssh_resourcecreate_pbs_token)
  - _ssh_resource_.[create_pbs_user](#ssh_resourcecreate_pbs_user)
  - _ssh_resource_.[delete_existing_pbs_token](#ssh_resourcedelete_existing_pbs_token)
  - _ssh_resource_.[delete_folder_backup](#ssh_resourcedelete_folder_backup)
  - _ssh_resource_.[delete_folder_backup_infra](#ssh_resourcedelete_folder_backup_infra)
  - _ssh_resource_.[delete_pbs_user](#ssh_resourcedelete_pbs_user)
  - _ssh_resource_.[delete_verify_job](#ssh_resourcedelete_verify_job)
  - _ssh_resource_.[folder_backup](#ssh_resourcefolder_backup)
  - _ssh_resource_.[grant_pbs_token_acl](#ssh_resourcegrant_pbs_token_acl)
  - _ssh_resource_.[grant_pbs_user_acl](#ssh_resourcegrant_pbs_user_acl)
  - _ssh_resource_.[push_folder_backup_infra](#ssh_resourcepush_folder_backup_infra)
  - _ssh_resource_.[verify_job](#ssh_resourceverify_job)
- [Variables](#variables)
  - [pbs](#pbs-required) (**Required**)
  - [proxmox](#proxmox-required) (**Required**)
  - [folders](#folders-optional) (*Optional*)
  - [guests](#guests-optional) (*Optional*)
  - [pbs_token_name](#pbs_token_name-optional) (*Optional*)
  - [pbs_token_userid](#pbs_token_userid-optional) (*Optional*)
  - [proxmox_node_name](#proxmox_node_name-optional) (*Optional*)
  - [prune_backups](#prune_backups-optional) (*Optional*)
  - [schedule](#schedule-optional) (*Optional*)
  - [storage_id](#storage_id-optional) (*Optional*)
  - [verify_outdated_after_days](#verify_outdated_after_days-optional) (*Optional*)
  - [verify_schedule](#verify_schedule-optional) (*Optional*)
- [Outputs](#outputs)
  - [job_ids](#job_ids)
  - [storage_id](#storage_id)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![bpg/proxmox](https://img.shields.io/badge/bpg--proxmox->=0.111.1-1e73c8?logo=proxmox)
![loafoe/ssh](https://img.shields.io/badge/loafoe--ssh-~>2.7-4fa4f9?logo=ssh)

## Resources
  
<blockquote><!-- resource:"proxmox_backup_job.this":start -->

### _proxmox_backup_job_.`this`

One job per guest - each guest's primary disk(s) (and EFI disk, where it has one - EFI disks have no per-disk backup toggle in this provider, so they're always included automatically, nothing to configure for that here).
  <table>
    <tr>
      <td>Provider</td>
      <td><code>proxmox (bpg/proxmox)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L178"><code>main.tf#L178</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"proxmox_backup_job.this":end -->
<blockquote><!-- resource:"proxmox_storage_pbs.this":start -->

### _proxmox_storage_pbs_.`this`

Register PBS as a storage target PVE can back guests up to, authenticated with the dedicated token above (username = full tokenid, password = secret - the same user@realm!tokenname / secret pairing PVE's own storage.cfg accepts in place of a plain user password).
  <table>
    <tr>
      <td>Provider</td>
      <td><code>proxmox (bpg/proxmox)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L163"><code>main.tf#L163</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"proxmox_storage_pbs.this":end -->
<blockquote><!-- resource:"ssh_resource.create_folder_backup_config_dir":start -->

### _ssh_resource_.`create_folder_backup_config_dir`

Split from push_folder_backup_infra below on purpose - the file{} blocks there push into /etc/pbs-folder-backup, which doesn't exist on a fresh sanctum, and ssh_resource gives no documented guarantee that its file{} pushes happen after (vs. before/alongside) its own commands. A separate, ordered-by-depends_on resource removes the question entirely.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L243"><code>main.tf#L243</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.create_folder_backup_config_dir":end -->
<blockquote><!-- resource:"ssh_resource.create_pbs_token":start -->

### _ssh_resource_.`create_pbs_token`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L76"><code>main.tf#L76</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.create_pbs_token":end -->
<blockquote><!-- resource:"ssh_resource.create_pbs_user":start -->

### _ssh_resource_.`create_pbs_user`

Dedicated PBS user for this module's own storage credential - see the `pbs_token_userid` variable for why this needs prune, not just backup, privilege.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L39"><code>main.tf#L39</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.create_pbs_user":end -->
<blockquote><!-- resource:"ssh_resource.delete_existing_pbs_token":start -->

### _ssh_resource_.`delete_existing_pbs_token`

Idempotency for create_pbs_token below can't be a simple "skip if exists" guard like create_pbs_user's, since a pre-existing token's secret can never be retrieved again (PBS shows it exactly once, at creation). So a rerun instead deletes any same-named token first, then create_pbs_token always (re)creates, guaranteeing a fresh, known secret lands in state. Safe because this token has exactly one consumer (proxmox_storage_pbs.this below, wired in the same apply) - nothing else holds a copy that a rotation could break. Kept as its own resource, separate from create_pbs_token, so create_pbs_token's `result` stays a single command's output - the only form already confirmed safe to jsondecode() (see host/modules/terraform-user's create_api_token for the same pattern).
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L62"><code>main.tf#L62</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.delete_existing_pbs_token":end -->
<blockquote><!-- resource:"ssh_resource.delete_folder_backup":start -->

### _ssh_resource_.`delete_folder_backup`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L339"><code>main.tf#L339</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.delete_folder_backup":end -->
<blockquote><!-- resource:"ssh_resource.delete_folder_backup_infra":start -->

### _ssh_resource_.`delete_folder_backup_infra`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L285"><code>main.tf#L285</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.delete_folder_backup_infra":end -->
<blockquote><!-- resource:"ssh_resource.delete_pbs_user":start -->

### _ssh_resource_.`delete_pbs_user`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L145"><code>main.tf#L145</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.delete_pbs_user":end -->
<blockquote><!-- resource:"ssh_resource.delete_verify_job":start -->

### _ssh_resource_.`delete_verify_job`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L212"><code>main.tf#L212</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.delete_verify_job":end -->
<blockquote><!-- resource:"ssh_resource.folder_backup":start -->

### _ssh_resource_.`folder_backup`

One concrete timer + one per-folder env file per var.folders entry - namespace is always the map key (each.key), matching main.tf's file-header note and the earlier session decision to keep namespaces per-folder rather than per-tier, for UI legibility.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L305"><code>main.tf#L305</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.folder_backup":end -->
<blockquote><!-- resource:"ssh_resource.grant_pbs_token_acl":start -->

### _ssh_resource_.`grant_pbs_token_acl`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L126"><code>main.tf#L126</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.grant_pbs_token_acl":end -->
<blockquote><!-- resource:"ssh_resource.grant_pbs_user_acl":start -->

### _ssh_resource_.`grant_pbs_user_acl`

PBS intersects a token's effective permissions with its parent user's own permissions ("A user can always configure privileges for their own API tokens, as they will be limited by the users privileges anyway" - PBS user-management docs) - confirmed live: granting a role to only the token left it with zero effective permissions until the plain user got the same grant too. So both principals need the ACL entry, not just the token - acl update is idempotent, safe to always run both.  Role is DatastoreAdmin, not the narrower DatastorePowerUser originally used here (Audit+Backup+Prune+Read) - the folder-backup track below needs Datastore.Modify too, to create its per-folder namespaces (confirmed live: `namespace create` fails with "missing Datastore.Modify" under DatastorePowerUser). DatastoreAdmin is a confirmed superset (adds Modify + Verify, same reachable Backup/Prune/Read/Audit) - one role covers both tracks, no second credential needed.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L112"><code>main.tf#L112</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.grant_pbs_user_acl":end -->
<blockquote><!-- resource:"ssh_resource.push_folder_backup_infra":start -->

### _ssh_resource_.`push_folder_backup_infra`
      
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L253"><code>main.tf#L253</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.push_folder_backup_infra":end -->
<blockquote><!-- resource:"ssh_resource.verify_job":start -->

### _ssh_resource_.`verify_job`

PBS's own datastore verify job - no native provider resource for this (see var.verify_schedule), so it's ssh_resource-driven like the user/token bootstrap above. Unlike create_pbs_token, `verify-job update` is a clean, safe idempotent operation on its own - no secret-rotation gotcha - so this is a plain check-then-create-or-update, no separate delete step needed.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L198"><code>main.tf#L198</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.verify_job":end -->

## Variables
  
<blockquote><!-- variable:"pbs":start -->

### `pbs` (**Required**)

Proxmox Backup Server connection details

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  object({
    server    = string
    datastore = string
  })
  ```
  In file: <a href="./variables.tf#L29"><code>variables.tf#L29</code></a>

</details>
</blockquote><!-- variable:"pbs":end -->
<blockquote><!-- variable:"proxmox":start -->

### `proxmox` (**Required**)

Proxmox host configuration

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  object({
    name     = string
    host     = string
    ssh_user = string
    ssh_key  = string
    insecure = bool
    username = string
    password = string
  })
  ```
  In file: <a href="./variables.tf#L4"><code>variables.tf#L4</code></a>

</details>
</blockquote><!-- variable:"proxmox":end -->
<blockquote><!-- variable:"folders":start -->

### `folders` (*Optional*)

Map of name => { archives, schedule, prune_backups } - one host-type PBS backup+prune per entry, its own namespace (= the map key)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  map(object({
    archives      = list(string) # "<archive-name>.pxar:<source-path>" specs, proxmox-backup-client's own format
    schedule      = string
    prune_backups = map(string)
  }))
  ```
  **Default**:
  ```json
  {
  "application": {
    "archives": [
      "application.pxar:/mnt/storage/application"
    ],
    "prune_backups": {
      "keep-last": "3"
    },
    "schedule": "*-01,03,05,07,09,11-01 09:00:00"
  },
  "backup": {
    "archives": [
      "backup.pxar:/mnt/storage/backup"
    ],
    "prune_backups": {
      "keep-monthly": "6",
      "keep-weekly": "4"
    },
    "schedule": "sun 01:00"
  },
  "document": {
    "archives": [
      "document.pxar:/mnt/storage/document"
    ],
    "prune_backups": {
      "keep-daily": "7",
      "keep-monthly": "6",
      "keep-weekly": "4"
    },
    "schedule": "00:30"
  },
  "game": {
    "archives": [
      "game.pxar:/mnt/storage/game"
    ],
    "prune_backups": {
      "keep-last": "3"
    },
    "schedule": "*-01,03,05,07,09,11-01 09:00:00"
  },
  "kyocera-scan": {
    "archives": [
      "kyocera-scan.pxar:/mnt/storage/kyocera-scan"
    ],
    "prune_backups": {
      "keep-daily": "7",
      "keep-monthly": "6",
      "keep-weekly": "4"
    },
    "schedule": "00:30"
  },
  "music": {
    "archives": [
      "music.pxar:/mnt/storage/music"
    ],
    "prune_backups": {
      "keep-monthly": "6"
    },
    "schedule": "*-*-01 02:30:00"
  },
  "photo": {
    "archives": [
      "photo.pxar:/mnt/storage/photo"
    ],
    "prune_backups": {
      "keep-daily": "7",
      "keep-monthly": "6",
      "keep-weekly": "4"
    },
    "schedule": "00:30"
  },
  "picture": {
    "archives": [
      "picture.pxar:/mnt/storage/picture"
    ],
    "prune_backups": {
      "keep-last": "3"
    },
    "schedule": "*-01,03,05,07,09,11-01 09:00:00"
  },
  "pihole": {
    "archives": [
      "pihole.pxar:/mnt/temp/pihole"
    ],
    "prune_backups": {
      "keep-monthly": "6",
      "keep-weekly": "4"
    },
    "schedule": "sun 01:00"
  },
  "pve-host": {
    "archives": [
      "etc-pve.pxar:/etc/pve",
      "root.pxar:/root"
    ],
    "prune_backups": {
      "keep-daily": "7",
      "keep-monthly": "6",
      "keep-weekly": "4"
    },
    "schedule": "00:30"
  },
  "step-ca": {
    "archives": [
      "step-ca.pxar:/mnt/temp/step-ca"
    ],
    "prune_backups": {
      "keep-monthly": "6",
      "keep-weekly": "4"
    },
    "schedule": "sun 01:00"
  },
  "temp": {
    "archives": [
      "temp.pxar:/mnt/storage/temp"
    ],
    "prune_backups": {
      "keep-daily": "7",
      "keep-monthly": "6",
      "keep-weekly": "4"
    },
    "schedule": "00:30"
  },
  "yuliia": {
    "archives": [
      "yuliia.pxar:/mnt/storage/yuliia"
    ],
    "prune_backups": {
      "keep-monthly": "6"
    },
    "schedule": "*-*-01 02:30:00"
  }
}
  ```
  In file: <a href="./variables.tf#L168"><code>variables.tf#L168</code></a>

</details>
</blockquote><!-- variable:"folders":end -->
<blockquote><!-- variable:"guests":start -->

### `guests` (*Optional*)

Map of guest name => { vmid, optional per-guest schedule/prune_backups overrides } to create a dedicated backup job for

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  map(object({
    vmid          = string
    schedule      = optional(string)
    prune_backups = optional(map(string))
  }))
  ```
  **Default**:
  ```json
  {
  "docker-vm": {
    "prune_backups": {
      "keep-daily": "7",
      "keep-monthly": "6",
      "keep-weekly": "4"
    },
    "schedule": "02:00",
    "vmid": "800"
  },
  "pbs-lxc": {
    "vmid": "704"
  },
  "pihole": {
    "vmid": "703"
  },
  "samba": {
    "vmid": "702"
  },
  "step-ca": {
    "vmid": "701"
  }
}
  ```
  In file: <a href="./variables.tf#L124"><code>variables.tf#L124</code></a>

</details>
</blockquote><!-- variable:"guests":end -->
<blockquote><!-- variable:"pbs_token_name":start -->

### `pbs_token_name` (*Optional*)

Name of the API token generated under pbs_token_userid

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "backup-jobs"
  ```
  In file: <a href="./variables.tf#L54"><code>variables.tf#L54</code></a>

</details>
</blockquote><!-- variable:"pbs_token_name":end -->
<blockquote><!-- variable:"pbs_token_userid":start -->

### `pbs_token_userid` (*Optional*)

PBS userid (user@pbs) to create for this module's own storage credential

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "backup-jobs@pbs"
  ```
  In file: <a href="./variables.tf#L47"><code>variables.tf#L47</code></a>

</details>
</blockquote><!-- variable:"pbs_token_userid":end -->
<blockquote><!-- variable:"proxmox_node_name":start -->

### `proxmox_node_name` (*Optional*)

Proxmox node name

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "sanctum"
  ```
  In file: <a href="./variables.tf#L19"><code>variables.tf#L19</code></a>

</details>
</blockquote><!-- variable:"proxmox_node_name":end -->
<blockquote><!-- variable:"prune_backups":start -->

### `prune_backups` (*Optional*)

Default retention policy (keep-weekly/keep-monthly etc.), used by any guest that doesn't set its own prune_backups in var.guests - no keep-daily since the default schedule only runs weekly anyway

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  map(string)
  ```
  **Default**:
  ```json
  {
  "keep-monthly": "6",
  "keep-weekly": "4"
}
  ```
  In file: <a href="./variables.tf#L75"><code>variables.tf#L75</code></a>

</details>
</blockquote><!-- variable:"prune_backups":end -->
<blockquote><!-- variable:"schedule":start -->

### `schedule` (*Optional*)

Default backup schedule (systemd calendar event format), used by any guest that doesn't set its own schedule in var.guests - weekly by default, since most of these guests are reproducible OS/config shells rather than places real data lives (see docker-vm's own override for the exception)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "sun 01:30"
  ```
  In file: <a href="./variables.tf#L68"><code>variables.tf#L68</code></a>

</details>
</blockquote><!-- variable:"schedule":end -->
<blockquote><!-- variable:"storage_id":start -->

### `storage_id` (*Optional*)

Identifier to register the PBS datastore under in PVE

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "pbs"
  ```
  In file: <a href="./variables.tf#L61"><code>variables.tf#L61</code></a>

</details>
</blockquote><!-- variable:"storage_id":end -->
<blockquote><!-- variable:"verify_outdated_after_days":start -->

### `verify_outdated_after_days` (*Optional*)

Days after which a prior successful verification is considered stale and re-checked, instead of skipped, on the next verify run - kept in step with verify_schedule's cadence

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  number
  ```
  **Default**:
  ```json
  60
  ```
  In file: <a href="./variables.tf#L105"><code>variables.tf#L105</code></a>

</details>
</blockquote><!-- variable:"verify_outdated_after_days":end -->
<blockquote><!-- variable:"verify_schedule":start -->

### `verify_schedule` (*Optional*)

Schedule for the PBS datastore verify job (systemd calendar event format - confirmed accepted by PBS's parser live)

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "*-01,03,05,07,09,11-01 03:00:00"
  ```
  In file: <a href="./variables.tf#L98"><code>variables.tf#L98</code></a>

</details>
</blockquote><!-- variable:"verify_schedule":end -->

## Outputs
  
<blockquote><!-- output:"job_ids":start -->

#### `job_ids`

Map of guest name => the backup job id created for it

In file: <a href="./outputs.tf#L6"><code>outputs.tf#L6</code></a>
</blockquote><!-- output:"job_ids":end -->
<blockquote><!-- output:"storage_id":start -->

#### `storage_id`

The PVE storage id the PBS datastore was registered under

In file: <a href="./outputs.tf#L1"><code>outputs.tf#L1</code></a>
</blockquote><!-- output:"storage_id":end -->