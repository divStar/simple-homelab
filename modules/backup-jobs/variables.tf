# Proxmox host configuration (same shape as every other root module in this repo,
# even though ssh_user/ssh_key/name go unused here - this module only talks to the
# PVE API, no in-guest provisioning - kept identical so tfvars stay copy-pasteable).
variable "proxmox" {
  description = "Proxmox host configuration"
  sensitive   = true
  nullable    = false
  type = object({
    name     = string
    host     = string
    ssh_user = string
    ssh_key  = string
    insecure = bool
    username = string
    password = string
  })
}

variable "proxmox_node_name" {
  description = "Proxmox node name"
  type        = string
  default     = "sanctum"
}

# Proxmox Backup Server connection target. No username/password here on
# purpose - this module provisions its own dedicated PBS user + write/prune-
# only API token (see main.tf) rather than taking PBS credentials as input,
# so there's nothing reusable/leakable beyond what this module itself grants.
variable "pbs" {
  description = "Proxmox Backup Server connection details"
  nullable    = false
  type = object({
    server    = string
    datastore = string
  })
}

# The dedicated PBS user this module creates and grants DatastoreAdmin on
# /datastore/<pbs.datastore> (backup + prune of its own backups, plus
# Datastore.Modify for the folder-backup track's per-folder namespaces - see
# main.tf's grant_pbs_user_acl for the full reasoning). Prune is a real
# requirement here, not optional: `prune_backups` on `proxmox_backup_job`
# executes against PBS's own API, authenticated with the storage's configured
# credential (this token) - it is NOT a PVE-side-only operation the way the
# job resource's location might suggest. DatastoreBackup alone (write-only,
# no prune, no modify) is not sufficient.
variable "pbs_token_userid" {
  description = "PBS userid (user@pbs) to create for this module's own storage credential"
  type        = string
  default     = "backup-jobs@pbs"
  nullable    = false
}

variable "pbs_token_name" {
  description = "Name of the API token generated under pbs_token_userid"
  type        = string
  default     = "backup-jobs"
  nullable    = false
}

# Secrets for var.folders entries' exec_start_pre.environment, keyed by folder name - can't live in
# var.folders' own default since a variable default can't reference another variable.
variable "folder_secrets" {
  description = "Map of folder name => extra env vars for that folder's exec_start_pre script"
  type        = map(map(string))
  sensitive   = true
  nullable    = false
  default     = {}
}

variable "storage_id" {
  description = "Identifier to register the PBS datastore under in PVE"
  type        = string
  default     = "pbs"
  nullable    = false
}

variable "schedule" {
  description = "Default backup schedule (systemd calendar event format), used by any guest that doesn't set its own schedule in var.guests - weekly by default, since most of these guests are reproducible OS/config shells rather than places real data lives (see docker-vm's own override for the exception)"
  type        = string
  default     = "sun 01:30"
  nullable    = false
}

variable "flatcar_data_export_schedule" {
  description = "Systemd calendar schedule for the Flatcar data export job"
  type        = string
  default     = "07:00"
  nullable    = false
}

variable "prune_backups" {
  description = "Default retention policy (keep-weekly/keep-monthly etc.), used by any guest that doesn't set its own prune_backups in var.guests - no keep-daily since the default schedule only runs weekly anyway"
  type        = map(string)
  nullable    = false
  default = {
    "keep-weekly"  = "4"
    "keep-monthly" = "6"
  }
}

# PBS's own verify jobs - catch silent chunk corruption (bit rot) on the underlying
# storage, which ext4-on-mdraid doesn't self-detect the way ZFS would. No native
# provider resource for this (bpg/proxmox only wraps the PVE API - verify jobs are
# PBS-native, see the ssh_resources in main.tf). PBS verify-jobs are scoped per
# datastore/namespace, not per guest: every folder namespace gets its own job (schedule =
# that folder's verify_schedule in var.folders), and all guest (VM/CT) backups share the
# root namespace, hence their one job below. All jobs verify in full (--ignore-verified
# false) - something verified on the last run can still have gone bad since.
variable "verify_root_schedule" {
  description = "Schedule for the PBS verify job of the root namespace, i.e. all VM/CT backups (systemd calendar event format - confirmed accepted by PBS's parser live)"
  type        = string
  default     = "mon 03:00" # every Monday
  nullable    = false
}

# Prune (client-side, see var.folders / var.prune_backups) only removes snapshots - garbage collection
# is what actually frees their chunks on the datastore.
variable "gc_schedule" {
  description = "Schedule for the PBS datastore garbage collection (systemd calendar event format)"
  type        = string
  default     = "sat 05:30"
  nullable    = false
}

# One backup job is created per entry. Deliberately individual
# proxmox_backup_job resources rather than one job with a vmid list, so a
# single guest's schedule/retention can diverge - which is exactly what
# `schedule`/`prune_backups` here are for: per-guest overrides, falling back
# to the shared var.schedule/var.prune_backups defaults when unset (see
# main.tf's coalesce()/null-check). docker-vm is the one guest that needs
# both overridden - its disks hold real application data (gitea, grist,
# jellyfin, portainer, etc.) that Terraform can't reproduce, unlike the other
# four guests, whose real state either lives outside these backups entirely
# (bind mounts - step-ca's covered by var.folders below, pbs-lxc's isn't)
# or is itself reproducible from this repo.
variable "guests" {
  description = "Map of guest name => { vmid, optional per-guest schedule/prune_backups overrides } to create a dedicated backup job for"
  type = map(object({
    vmid          = string
    schedule      = optional(string)
    prune_backups = optional(map(string))
  }))
  nullable = false
  default = {
    "docker-vm" = {
      vmid     = "800"
      schedule = "02:00"
      prune_backups = {
        "keep-daily"   = "7"
        "keep-weekly"  = "4"
        "keep-monthly" = "6"
      }
    }
    "step-ca" = { vmid = "701" }
    "samba"   = { vmid = "702" }
    "pbs-lxc" = { vmid = "704" }
    "opnsense" = {
      vmid     = "801"
      schedule = "05:00"
      prune_backups = {
        "keep-daily"   = "7"
        "keep-weekly"  = "4"
        "keep-monthly" = "6"
      }
    }
  }
}

# Host-level folder backups - covers real data these guest-level backups
# never touch: bind-mounted LXC state (step-ca's actual config/keys,
# excluded from vzdump same as any bind mount), the family file shares on
# /mnt/storage, and PVE's own recovery-relevant state (pve-host). Pushed via
# proxmox-backup-client directly from the PVE host itself (see main.tf) -
# there's no proxmox_backup_job equivalent for arbitrary host paths, PVE
# guests only. Namespace is always the map key (one namespace per folder, for
# UI legibility - deliberately not per-tier, see main.tf/session notes).
#
# Grouped into 4 "tiers" of shared schedule+retention (values are repeated
# per entry rather than centrally defined, matching var.guests' style - no
# cross-referencing abstraction for 13 entries):
#   short     (00:30 daily)                    - pve-host, document, photo, kyocera-scan, temp
#   mid       (sun 01:00 weekly)                - backup, step-ca
#   long      (1st 02:30 monthly)               - yuliia, music
#   very long (1st 09:00, odd months/bimonthly) - application, game, picture
# "very long" uses keep-last instead of keep-monthly deliberately - a job
# that only runs every 2 months doesn't map cleanly onto calendar-month
# buckets, keep-last just keeps the N most recent runs regardless of cadence.
variable "folders" {
  description = "Map of name => { archives, schedule, prune_backups, verify_schedule } - one host-type PBS backup+prune+verify per entry, its own namespace (= the map key)"
  type = map(object({
    archives      = list(string) # "<archive-name>.pxar:<source-path>" specs, proxmox-backup-client's own format
    schedule      = string
    prune_backups = map(string)
    exec_start_pre = optional(object({ # optional pre-fetch step, run before the backup itself
      script      = string             # filename under files/
      environment = optional(map(string)) # -> EnvironmentFile=; secrets come from var.folder_secrets instead, see main.tf
    }))
    verify_schedule = string # schedule of the PBS verify job for this folder's namespace
  }))
  nullable = false
  default = {
    "pve-host" = {
      archives      = ["etc-pve.pxar:/etc/pve", "etc-network.pxar:/etc/network", "root.pxar:/root"]
      schedule      = "00:30"
      prune_backups = { "keep-daily" = "7", "keep-weekly" = "4", "keep-monthly" = "6" }

      verify_schedule = "tue 03:00" # every Tuesday
    }
    "document" = {
      archives      = ["document.pxar:/mnt/storage/document"]
      schedule      = "00:30"
      prune_backups = { "keep-daily" = "7", "keep-weekly" = "4", "keep-monthly" = "6" }

      verify_schedule = "*-*-10 03:00:00" # the 10th of every month
    }
    "photo" = {
      archives      = ["photo.pxar:/mnt/storage/photo"]
      schedule      = "00:30"
      prune_backups = { "keep-daily" = "7", "keep-weekly" = "4", "keep-monthly" = "6" }

      verify_schedule = "*-*-10 03:00:00" # the 10th of every month
    }
    "kyocera-scan" = {
      archives      = ["kyocera-scan.pxar:/mnt/storage/kyocera-scan"]
      schedule      = "00:30"
      prune_backups = { "keep-daily" = "7", "keep-weekly" = "4", "keep-monthly" = "6" }

      verify_schedule = "*-*-10 03:00:00" # the 10th of every month
    }
    "temp" = {
      archives      = ["temp.pxar:/mnt/storage/temp"]
      schedule      = "00:30"
      prune_backups = { "keep-daily" = "7", "keep-weekly" = "4", "keep-monthly" = "6" }

      verify_schedule = "*-01,04,07,10-18 03:00:00" # the 18th of every third month
    }
    "backup" = {
      archives      = ["backup.pxar:/mnt/storage/backup"]
      schedule      = "sun 01:00"
      prune_backups = { "keep-weekly" = "4", "keep-monthly" = "6" }

      verify_schedule = "*-*-14 03:00:00" # the 14th of every month
    }
    "step-ca" = {
      archives      = ["step-ca.pxar:/mnt/storage/step-ca"]
      schedule      = "sun 01:00"
      prune_backups = { "keep-weekly" = "4", "keep-monthly" = "6" }

      verify_schedule = "tue 03:00" # every Tuesday
    }
    "yuliia" = {
      archives      = ["yuliia.pxar:/mnt/storage/yuliia"]
      schedule      = "*-*-01 02:30:00"
      prune_backups = { "keep-monthly" = "6" }

      verify_schedule = "*-*-12 03:00:00" # the 12th of every month
    }
    "music" = {
      archives      = ["music.pxar:/mnt/storage/music"]
      schedule      = "*-*-01 02:30:00"
      prune_backups = { "keep-monthly" = "6" }

      verify_schedule = "*-01,03,05,07,09,11-16 03:00:00" # the 16th of every other month
    }
    "application" = {
      archives      = ["application.pxar:/mnt/storage/application"]
      schedule      = "*-01,03,05,07,09,11-01 09:00:00"
      prune_backups = { "keep-last" = "3" }

      verify_schedule = "*-01,04,07,10-18 03:00:00" # the 18th of every third month
    }
    "game" = {
      archives      = ["game.pxar:/mnt/storage/game"]
      schedule      = "*-01,03,05,07,09,11-01 09:00:00"
      prune_backups = { "keep-last" = "3" }

      verify_schedule = "*-01,04,07,10-18 03:00:00" # the 18th of every third month
    }
    "picture" = {
      archives      = ["picture.pxar:/mnt/storage/picture"]
      schedule      = "*-01,03,05,07,09,11-01 09:00:00"
      prune_backups = { "keep-last" = "3" }

      verify_schedule = "*-01,04,07,10-18 03:00:00" # the 18th of every third month
    }
    "opnsense-config" = {
      archives       = ["opnsense-config.pxar:/mnt/temp/opnsense"]
      schedule       = "00:30"
      prune_backups  = { "keep-daily" = "7", "keep-weekly" = "4", "keep-monthly" = "6" }
      exec_start_pre = { script = "opnsense-config-fetch.sh" }

      verify_schedule = "tue 03:00" # every Tuesday
    }
    "flint2-config" = {
      archives       = ["flint2-config.pxar:/mnt/temp/flint2"]
      schedule       = "00:30"
      prune_backups  = { "keep-daily" = "7", "keep-weekly" = "4", "keep-monthly" = "6" }
      exec_start_pre = { script = "flint2-config-fetch.sh" }

      verify_schedule = "tue 03:00" # every Tuesday
    }
  }
}
