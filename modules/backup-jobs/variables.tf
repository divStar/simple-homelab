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

variable "prune_backups" {
  description = "Default retention policy (keep-weekly/keep-monthly etc.), used by any guest that doesn't set its own prune_backups in var.guests - no keep-daily since the default schedule only runs weekly anyway"
  type        = map(string)
  nullable    = false
  default = {
    "keep-weekly"  = "4"
    "keep-monthly" = "6"
  }
}

# PBS's own datastore verify job - catches silent chunk corruption (bit rot)
# on the underlying storage, which ext4-on-mdraid doesn't self-detect the way
# ZFS would. No native provider resource for this (bpg/proxmox only wraps the
# PVE API - verify jobs are PBS-native, see the ssh_resource in main.tf), so
# these stay plain variables rather than a richer per-job structure like
# var.guests - there's only ever one verify job, on the one datastore.
# Bimonthly (odd months, 1st at 03:00) rather than a namespace-split verify
# setup that would let docker-vm alone verify more often - PBS verify-jobs
# are scoped per-datastore/namespace, not per-guest, and splitting docker-vm
# into its own namespace (own proxmox_storage_pbs registration, own verify-
# job) is real structural complexity for a "nice to have" - deliberately not
# built. Bimonthly instead of quarterly is the cheap middle ground: still one
# shared job covering all 5 guests, just checked twice as often.
variable "verify_schedule" {
  description = "Schedule for the PBS datastore verify job (systemd calendar event format - confirmed accepted by PBS's parser live)"
  type        = string
  default     = "*-01,03,05,07,09,11-01 03:00:00"
  nullable    = false
}

variable "verify_outdated_after_days" {
  description = "Days after which a prior successful verification is considered stale and re-checked, instead of skipped, on the next verify run - kept in step with verify_schedule's cadence"
  type        = number
  default     = 60
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
# (bind mounts - step-ca's keys, pihole's config, samba's shares, not yet
# covered by any job) or is itself reproducible from this repo - so those
# four are fine on the lighter weekly/monthly-only shared default.
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
    "pihole"  = { vmid = "703" }
    "pbs-lxc" = { vmid = "704" }
  }
}

# Host-level folder backups - covers real data these guest-level backups
# never touch: bind-mounted LXC state (pihole/step-ca's actual config/keys,
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
#   short     (00:30 daily)                    - pve-host, document, photo, kyocera-scan, temp, pihole
#   mid       (sun 01:00 weekly)                - backup, step-ca
#   long      (1st 02:30 monthly)               - yuliia, music
#   very long (1st 09:00, odd months/bimonthly) - application, game, picture
# pihole moved short in this session (2026-08-14): its mounted config
# (whitelist/blacklist/custom DNS/gravity.db) genuinely changes at times,
# unlike step-ca's mountpoint (keys/CA state), which stays mid since it
# almost never changes. Cost of the extra frequency is negligible - these
# backups are tiny.
# "very long" uses keep-last instead of keep-monthly deliberately - a job
# that only runs every 2 months doesn't map cleanly onto calendar-month
# buckets, keep-last just keeps the N most recent runs regardless of cadence.
variable "folders" {
  description = "Map of name => { archives, schedule, prune_backups } - one host-type PBS backup+prune per entry, its own namespace (= the map key)"
  type = map(object({
    archives      = list(string) # "<archive-name>.pxar:<source-path>" specs, proxmox-backup-client's own format
    schedule      = string
    prune_backups = map(string)
  }))
  nullable = false
  default = {
    "pve-host" = {
      archives      = ["etc-pve.pxar:/etc/pve", "root.pxar:/root"]
      schedule      = "00:30"
      prune_backups = { "keep-daily" = "7", "keep-weekly" = "4", "keep-monthly" = "6" }
    }
    "document" = {
      archives      = ["document.pxar:/mnt/storage/document"]
      schedule      = "00:30"
      prune_backups = { "keep-daily" = "7", "keep-weekly" = "4", "keep-monthly" = "6" }
    }
    "photo" = {
      archives      = ["photo.pxar:/mnt/storage/photo"]
      schedule      = "00:30"
      prune_backups = { "keep-daily" = "7", "keep-weekly" = "4", "keep-monthly" = "6" }
    }
    "kyocera-scan" = {
      archives      = ["kyocera-scan.pxar:/mnt/storage/kyocera-scan"]
      schedule      = "00:30"
      prune_backups = { "keep-daily" = "7", "keep-weekly" = "4", "keep-monthly" = "6" }
    }
    "temp" = {
      archives      = ["temp.pxar:/mnt/storage/temp"]
      schedule      = "00:30"
      prune_backups = { "keep-daily" = "7", "keep-weekly" = "4", "keep-monthly" = "6" }
    }
    "backup" = {
      archives      = ["backup.pxar:/mnt/storage/backup"]
      schedule      = "sun 01:00"
      prune_backups = { "keep-weekly" = "4", "keep-monthly" = "6" }
    }
    "pihole" = {
      archives      = ["pihole.pxar:/mnt/temp/pihole"]
      schedule      = "00:30"
      prune_backups = { "keep-daily" = "7", "keep-weekly" = "4", "keep-monthly" = "6" }
    }
    "step-ca" = {
      archives      = ["step-ca.pxar:/mnt/temp/step-ca"]
      schedule      = "sun 01:00"
      prune_backups = { "keep-weekly" = "4", "keep-monthly" = "6" }
    }
    "yuliia" = {
      archives      = ["yuliia.pxar:/mnt/storage/yuliia"]
      schedule      = "*-*-01 02:30:00"
      prune_backups = { "keep-monthly" = "6" }
    }
    "music" = {
      archives      = ["music.pxar:/mnt/storage/music"]
      schedule      = "*-*-01 02:30:00"
      prune_backups = { "keep-monthly" = "6" }
    }
    "application" = {
      archives      = ["application.pxar:/mnt/storage/application"]
      schedule      = "*-01,03,05,07,09,11-01 09:00:00"
      prune_backups = { "keep-last" = "3" }
    }
    "game" = {
      archives      = ["game.pxar:/mnt/storage/game"]
      schedule      = "*-01,03,05,07,09,11-01 09:00:00"
      prune_backups = { "keep-last" = "3" }
    }
    "picture" = {
      archives      = ["picture.pxar:/mnt/storage/picture"]
      schedule      = "*-01,03,05,07,09,11-01 09:00:00"
      prune_backups = { "keep-last" = "3" }
    }
  }
}
