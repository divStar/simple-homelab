# Backup Jobs

Registers Proxmox Backup Server as a PVE storage target, creates one
dedicated backup job per guest (VM/LXC primary disks), and one host-level
folder backup per entry in var.folders (real data the guest-level jobs
never touch - bind-mounted LXC state, the family file shares, PVE's own
recovery-relevant config).

<!-- docs-meta: order=70 icon=pbs -->

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
  - _ssh_resource_.[delete_flatcar_data_export](#ssh_resourcedelete_flatcar_data_export)
  - _ssh_resource_.[delete_folder_backup](#ssh_resourcedelete_folder_backup)
  - _ssh_resource_.[delete_folder_backup_infra](#ssh_resourcedelete_folder_backup_infra)
  - _ssh_resource_.[delete_pbs_user](#ssh_resourcedelete_pbs_user)
  - _ssh_resource_.[delete_verify_job](#ssh_resourcedelete_verify_job)
  - _ssh_resource_.[folder_backup](#ssh_resourcefolder_backup)
  - _ssh_resource_.[grant_pbs_token_acl](#ssh_resourcegrant_pbs_token_acl)
  - _ssh_resource_.[grant_pbs_user_acl](#ssh_resourcegrant_pbs_user_acl)
  - _ssh_resource_.[push_flatcar_data_export](#ssh_resourcepush_flatcar_data_export)
  - _ssh_resource_.[push_folder_backup_infra](#ssh_resourcepush_folder_backup_infra)
  - _ssh_resource_.[verify_job](#ssh_resourceverify_job)
- [Variables](#variables)
  - [pbs](#pbs-required) (**Required**)
  - [proxmox](#proxmox-required) (**Required**)
  - [flatcar_data_export_schedule](#flatcar_data_export_schedule-optional) (*Optional*)
  - [folder_secrets](#folder_secrets-optional) (*Optional*)
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
  - [folder_backups](#folder_backups)
  - [job_ids](#job_ids)
  - [storage_id](#storage_id)
  - [verify_job](#verify_job)
</blockquote><!-- contents:end -->

## Providers
![OpenTofu](https://img.shields.io/badge/OpenTofu->=1.10.5-d3287d?logo=opentofu)
![bpg/proxmox](https://img.shields.io/badge/bpg--proxmox->=0.111.1-1e73c8?logo=proxmox)
![loafoe/ssh](https://img.shields.io/badge/loafoe--ssh-~>2.7-4fa4f9?logo=ssh)

## Resources
  
<blockquote><!-- resource:"proxmox_backup_job.this":start -->

### _proxmox_backup_job_.`this`

One job per guest - each guest's primary disk(s). Note: EFI disks have no per-disk backup toggle in this provider, so they're always included automatically, nothing to configure for that here).
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
      <td><a href="./main.tf#L135"><code>main.tf#L135</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"proxmox_storage_pbs.this":end -->
<blockquote><!-- resource:"ssh_resource.create_folder_backup_config_dir":start -->

### _ssh_resource_.`create_folder_backup_config_dir`

Create PBS backup directory if necessary and chmod it.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L196"><code>main.tf#L196</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.create_folder_backup_config_dir":end -->
<blockquote><!-- resource:"ssh_resource.create_pbs_token":start -->

### _ssh_resource_.`create_pbs_token`

Create a new PBS token for the user.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L87"><code>main.tf#L87</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.create_pbs_token":end -->
<blockquote><!-- resource:"ssh_resource.create_pbs_user":start -->

### _ssh_resource_.`create_pbs_user`

Dedicated PBS user for this module's own storage credential.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L44"><code>main.tf#L44</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.create_pbs_user":end -->
<blockquote><!-- resource:"ssh_resource.delete_existing_pbs_token":start -->

### _ssh_resource_.`delete_existing_pbs_token`

Delete existing PBS token for the user.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L72"><code>main.tf#L72</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.delete_existing_pbs_token":end -->
<blockquote><!-- resource:"ssh_resource.delete_flatcar_data_export":start -->

### _ssh_resource_.`delete_flatcar_data_export`

Remove the Flatcar data export job on module destroy.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L370"><code>main.tf#L370</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.delete_flatcar_data_export":end -->
<blockquote><!-- resource:"ssh_resource.delete_folder_backup":start -->

### _ssh_resource_.`delete_folder_backup`

Delete folder backup runs.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L318"><code>main.tf#L318</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.delete_folder_backup":end -->
<blockquote><!-- resource:"ssh_resource.delete_folder_backup_infra":start -->

### _ssh_resource_.`delete_folder_backup_infra`

Delete folder backup infrastructure from host.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L235"><code>main.tf#L235</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.delete_folder_backup_infra":end -->
<blockquote><!-- resource:"ssh_resource.delete_pbs_user":start -->

### _ssh_resource_.`delete_pbs_user`

Delete the dedicated PBS user.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L57"><code>main.tf#L57</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.delete_pbs_user":end -->
<blockquote><!-- resource:"ssh_resource.delete_verify_job":start -->

### _ssh_resource_.`delete_verify_job`

Delete verify jobs.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L181"><code>main.tf#L181</code></a></td>
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
      <td><a href="./main.tf#L255"><code>main.tf#L255</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.folder_backup":end -->
<blockquote><!-- resource:"ssh_resource.grant_pbs_token_acl":start -->

### _ssh_resource_.`grant_pbs_token_acl`

Grant the user token the necessary ACL permissions.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L118"><code>main.tf#L118</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.grant_pbs_token_acl":end -->
<blockquote><!-- resource:"ssh_resource.grant_pbs_user_acl":start -->

### _ssh_resource_.`grant_pbs_user_acl`

Grant the user the necessary ACL permissions.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L103"><code>main.tf#L103</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.grant_pbs_user_acl":end -->
<blockquote><!-- resource:"ssh_resource.push_flatcar_data_export":start -->

### _ssh_resource_.`push_flatcar_data_export`

Daily export of docker-vm's data disks into the Proxmox import directory, so a docker-vm rebuild (destroy + tofu apply) picks up current data automatically - not a PBS backup, standalone from everything else in this module.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L338"><code>main.tf#L338</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.push_flatcar_data_export":end -->
<blockquote><!-- resource:"ssh_resource.push_folder_backup_infra":start -->

### _ssh_resource_.`push_folder_backup_infra`

Push folder backup infrastructure to the host.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L207"><code>main.tf#L207</code></a></td>
    </tr>
  </table>
</blockquote><!-- resource:"ssh_resource.push_folder_backup_infra":end -->
<blockquote><!-- resource:"ssh_resource.verify_job":start -->

### _ssh_resource_.`verify_job`

PBS's own datastore verify job.
  <table>
    <tr>
      <td>Provider</td>
      <td><code>ssh (loafoe/ssh)</code></td>
    </tr>
    <tr>
      <td>In file</td>
      <td><a href="./main.tf#L166"><code>main.tf#L166</code></a></td>
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
<blockquote><!-- variable:"flatcar_data_export_schedule":start -->

### `flatcar_data_export_schedule` (*Optional*)

Systemd calendar schedule for the Flatcar data export job

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  string
  ```
  **Default**:
  ```json
  "07:00"
  ```
  In file: <a href="./variables.tf#L85"><code>variables.tf#L85</code></a>

</details>
</blockquote><!-- variable:"flatcar_data_export_schedule":end -->
<blockquote><!-- variable:"folder_secrets":start -->

### `folder_secrets` (*Optional*)

Map of folder name => extra env vars for that folder's exec_start_pre script

<details style="border-top-color: inherit; border-top-width: 0.1em; border-top-style: solid; padding-top: 0.5em; padding-bottom: 0.5em;">
  <summary>Show more...</summary>

  **Type**:
  ```hcl
  map(map(string))
  ```
  **Default**:
  ```json
  {}
  ```
  In file: <a href="./variables.tf#L63"><code>variables.tf#L63</code></a>

</details>
</blockquote><!-- variable:"folder_secrets":end -->
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
    exec_start_pre = optional(object({ # optional pre-fetch step, run before the backup itself
      script      = string             # filename under files/
      environment = optional(map(string)) # -> EnvironmentFile=; secrets come from var.folder_secrets instead, see main.tf
    }))
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
  "flint2-config": {
    "archives": [
      "flint2-config.pxar:/mnt/temp/flint2"
    ],
    "exec_start_pre": {
      "script": "flint2-config-fetch.sh"
    },
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
  "opnsense-config": {
    "archives": [
      "opnsense-config.pxar:/mnt/temp/opnsense"
    ],
    "exec_start_pre": {
      "script": "opnsense-config-fetch.sh"
    },
    "prune_backups": {
      "keep-daily": "7",
      "keep-monthly": "6",
      "keep-weekly": "4"
    },
    "schedule": "00:30"
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
      "keep-daily": "7",
      "keep-monthly": "6",
      "keep-weekly": "4"
    },
    "schedule": "00:30"
  },
  "pve-host": {
    "archives": [
      "etc-pve.pxar:/etc/pve",
      "etc-network.pxar:/etc/network",
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
      "step-ca.pxar:/mnt/storage/step-ca"
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
  In file: <a href="./variables.tf#L198"><code>variables.tf#L198</code></a>

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
  "opnsense": {
    "prune_backups": {
      "keep-daily": "7",
      "keep-monthly": "6",
      "keep-weekly": "4"
    },
    "schedule": "05:00",
    "vmid": "801"
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
  In file: <a href="./variables.tf#L140"><code>variables.tf#L140</code></a>

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
  In file: <a href="./variables.tf#L92"><code>variables.tf#L92</code></a>

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
  In file: <a href="./variables.tf#L78"><code>variables.tf#L78</code></a>

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
  In file: <a href="./variables.tf#L71"><code>variables.tf#L71</code></a>

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
  In file: <a href="./variables.tf#L122"><code>variables.tf#L122</code></a>

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
  In file: <a href="./variables.tf#L115"><code>variables.tf#L115</code></a>

</details>
</blockquote><!-- variable:"verify_schedule":end -->

## Outputs
  
<blockquote><!-- output:"folder_backups":start -->

#### `folder_backups`

Map of folder name => { namespace, schedule, prune_backups, has_exec_start_pre }

In file: <a href="./outputs.tf#L11"><code>outputs.tf#L11</code></a>
</blockquote><!-- output:"folder_backups":end -->
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
<blockquote><!-- output:"verify_job":start -->

#### `verify_job`

PBS datastore verify job settings - one job, covers every namespace, not per-folder

In file: <a href="./outputs.tf#L23"><code>outputs.tf#L23</code></a>
</blockquote><!-- output:"verify_job":end -->