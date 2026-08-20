/**
 * # Backup Jobs
 *
 * Registers Proxmox Backup Server as a PVE storage target, creates one
 * dedicated backup job per guest (VM/LXC primary disks), and one host-level
 * folder backup per entry in var.folders (real data the guest-level jobs
 * never touch - bind-mounted LXC state, the family file shares, PVE's own
 * recovery-relevant config).
 *
 * <!-- docs-meta: order=70 icon=pbs -->
 */
locals {
  proxmox_endpoint = "https://${var.proxmox.host}:8006"

  # SSH connection to the PBS box itself, reusing the same shared operator
  # key every other module already uses to reach the fleet - only needed
  # here to bootstrap this module's own PBS user/token, not for anything
  # ongoing (unlike the LXC service modules' ssh_resource provisioning).
  pbs_ssh = {
    host        = var.pbs.server
    user        = "root"
    private_key = file(var.proxmox.ssh_key)
  }

  # SSH connection to the PVE host itself - unlike pbs_ssh above, this one IS
  # for something ongoing: the folder-backup track's systemd units/timers/
  # script live on sanctum, not on PBS (proxmox-backup-client runs from the
  # box being backed up, pushing to PBS - the same shape vzdump itself uses).
  sanctum_ssh = {
    host        = var.proxmox.host
    user        = var.proxmox.ssh_user
    private_key = file(var.proxmox.ssh_key)
  }

  pbs_token = jsondecode(ssh_resource.create_pbs_token.result)
}

# Dedicated PBS user for this module's own storage credential - see the
# `pbs_token_userid` variable for why this needs prune, not just backup,
# privilege.
resource "ssh_resource" "create_pbs_user" {
  host        = local.pbs_ssh.host
  user        = local.pbs_ssh.user
  private_key = local.pbs_ssh.private_key

  commands = [
    "proxmox-backup-manager user list --output-format json | grep -q '\"userid\":\"${var.pbs_token_userid}\"' || proxmox-backup-manager user create ${var.pbs_token_userid} --comment 'Terraform-managed - modules/backup-jobs storage credential'",
  ]

  timeout = "20s"
}

# Idempotency for create_pbs_token below can't be a simple "skip if exists"
# guard like create_pbs_user's, since a pre-existing token's secret can never
# be retrieved again (PBS shows it exactly once, at creation). So a rerun
# instead deletes any same-named token first, then create_pbs_token always
# (re)creates, guaranteeing a fresh, known secret lands in state. Safe
# because this token has exactly one consumer (proxmox_storage_pbs.this
# below, wired in the same apply) - nothing else holds a copy that a
# rotation could break. Kept as its own resource, separate from
# create_pbs_token, so create_pbs_token's `result` stays a single command's
# output - the only form already confirmed safe to jsondecode() (see
# host/modules/terraform-user's create_api_token for the same pattern).
resource "ssh_resource" "delete_existing_pbs_token" {
  depends_on = [ssh_resource.create_pbs_user]

  host        = local.pbs_ssh.host
  user        = local.pbs_ssh.user
  private_key = local.pbs_ssh.private_key

  commands = [
    "proxmox-backup-manager user list-tokens ${var.pbs_token_userid} --output-format json | grep -q '\"tokenid\":\"${var.pbs_token_userid}!${var.pbs_token_name}\"' && proxmox-backup-manager user delete-token ${var.pbs_token_userid} ${var.pbs_token_name} || true",
  ]

  timeout = "20s"
}

resource "ssh_resource" "create_pbs_token" {
  depends_on = [ssh_resource.delete_existing_pbs_token]

  host        = local.pbs_ssh.host
  user        = local.pbs_ssh.user
  private_key = local.pbs_ssh.private_key

  # Newly generated tokens carry zero permissions until an ACL grant exists
  # (see grant_pbs_token_acl below). Unlike `user list`/`list-tokens`,
  # `generate-token` doesn't support --output-format (confirmed live -
  # "schema does not allow additional properties") - its default output is
  # `Result: {\n  "tokenid": ...,\n  "value": ...\n}`, so the leading
  # "Result: " is stripped to leave valid (if pretty-printed) JSON for
  # jsondecode() below - verified live against a throwaway probe token.
  commands = [
    "proxmox-backup-manager user generate-token ${var.pbs_token_userid} ${var.pbs_token_name} --comment 'modules/backup-jobs' | sed 's/^Result: //'",
  ]

  timeout = "20s"
}

# PBS intersects a token's effective permissions with its parent user's own
# permissions ("A user can always configure privileges for their own API
# tokens, as they will be limited by the users privileges anyway" - PBS
# user-management docs) - confirmed live: granting a role to only the token
# left it with zero effective permissions until the plain user got the same
# grant too. So both principals need the ACL entry, not just the token - acl
# update is idempotent, safe to always run both.
#
# Role is DatastoreAdmin, not the narrower DatastorePowerUser originally used
# here (Audit+Backup+Prune+Read) - the folder-backup track below needs
# Datastore.Modify too, to create its per-folder namespaces (confirmed live:
# `namespace create` fails with "missing Datastore.Modify" under
# DatastorePowerUser). DatastoreAdmin is a confirmed superset (adds Modify +
# Verify, same reachable Backup/Prune/Read/Audit) - one role covers both
# tracks, no second credential needed.
resource "ssh_resource" "grant_pbs_user_acl" {
  depends_on = [ssh_resource.create_pbs_user]

  host        = local.pbs_ssh.host
  user        = local.pbs_ssh.user
  private_key = local.pbs_ssh.private_key

  commands = [
    "proxmox-backup-manager acl update /datastore/${var.pbs.datastore} DatastoreAdmin --auth-id ${var.pbs_token_userid}",
  ]

  timeout = "20s"
}

resource "ssh_resource" "grant_pbs_token_acl" {
  # Also depends on grant_pbs_user_acl, not just create_pbs_token - without
  # this, Terraform has no ordering guarantee between the two ACL grants,
  # and proxmox_storage_pbs.this (which only depends on this resource) could
  # race ahead of grant_pbs_user_acl landing, reproducing the exact
  # "Cannot find datastore" failure the user-level grant exists to fix.
  depends_on = [ssh_resource.create_pbs_token, ssh_resource.grant_pbs_user_acl]

  host        = local.pbs_ssh.host
  user        = local.pbs_ssh.user
  private_key = local.pbs_ssh.private_key

  commands = [
    "proxmox-backup-manager acl update /datastore/${var.pbs.datastore} DatastoreAdmin --auth-id '${local.pbs_token.tokenid}'",
  ]

  timeout = "20s"
}

resource "ssh_resource" "delete_pbs_user" {
  when = "destroy"

  host        = local.pbs_ssh.host
  user        = local.pbs_ssh.user
  private_key = local.pbs_ssh.private_key

  commands = [
    "proxmox-backup-manager user remove ${var.pbs_token_userid}",
  ]

  timeout = "20s"
}

# Register PBS as a storage target PVE can back guests up to, authenticated
# with the dedicated token above (username = full tokenid, password = secret
# - the same user@realm!tokenname / secret pairing PVE's own storage.cfg
# accepts in place of a plain user password).
resource "proxmox_storage_pbs" "this" {
  id        = var.storage_id
  server    = var.pbs.server
  datastore = var.pbs.datastore
  username  = local.pbs_token.tokenid
  password  = local.pbs_token.value
  nodes     = [var.proxmox_node_name]
  content   = ["backup"]

  depends_on = [ssh_resource.grant_pbs_token_acl]
}

# One job per guest - each guest's primary disk(s) (and EFI disk, where it
# has one - EFI disks have no per-disk backup toggle in this provider, so
# they're always included automatically, nothing to configure for that here).
resource "proxmox_backup_job" "this" {
  for_each = var.guests

  id             = "backup-${each.key}"
  node           = var.proxmox_node_name
  storage        = proxmox_storage_pbs.this.id
  vmid           = [each.value.vmid]
  schedule       = coalesce(each.value.schedule, var.schedule)
  enabled        = true
  prune_backups  = coalesce(each.value.prune_backups, var.prune_backups)
  notes_template = "Regular scheduled backup of {{guestname}}"

  depends_on = [proxmox_storage_pbs.this]
}

# PBS's own datastore verify job - no native provider resource for this (see
# var.verify_schedule), so it's ssh_resource-driven like the user/token
# bootstrap above. Unlike create_pbs_token, `verify-job update` is a clean,
# safe idempotent operation on its own - no secret-rotation gotcha - so this
# is a plain check-then-create-or-update, no separate delete step needed.
resource "ssh_resource" "verify_job" {
  depends_on = [proxmox_storage_pbs.this]

  host        = local.pbs_ssh.host
  user        = local.pbs_ssh.user
  private_key = local.pbs_ssh.private_key

  commands = [
    "proxmox-backup-manager verify-job list --output-format json | grep -q '\"id\":\"${var.storage_id}-verify\"' && proxmox-backup-manager verify-job update ${var.storage_id}-verify --schedule '${var.verify_schedule}' --outdated-after ${var.verify_outdated_after_days} || proxmox-backup-manager verify-job create ${var.storage_id}-verify --store ${var.pbs.datastore} --schedule '${var.verify_schedule}' --outdated-after ${var.verify_outdated_after_days}",
  ]

  timeout = "20s"
}

resource "ssh_resource" "delete_verify_job" {
  when = "destroy"

  host        = local.pbs_ssh.host
  user        = local.pbs_ssh.user
  private_key = local.pbs_ssh.private_key

  commands = [
    "proxmox-backup-manager verify-job remove ${var.storage_id}-verify",
  ]

  timeout = "20s"
}

# --- Folder backups -----------------------------------------------------
# Host-level backups, pushed from sanctum itself via proxmox-backup-client -
# see the file header for why this can't be a proxmox_backup_job. Shared
# pieces (the script, the generic %i-templated service, and the credentials
# every instance needs) are pushed once here; each var.folders entry gets
# its own concrete (non-templated) timer unit in the next resource, so a
# folder's schedule/retention change never touches any other folder's unit.

locals {
  pbs_repository = "${local.pbs_token.tokenid}@${var.pbs.server}:${var.pbs.datastore}"
}

# Split from push_folder_backup_infra below on purpose - the file{} blocks
# there push into /etc/pbs-folder-backup, which doesn't exist on a fresh
# sanctum, and ssh_resource gives no documented guarantee that its file{}
# pushes happen after (vs. before/alongside) its own commands. A separate,
# ordered-by-depends_on resource removes the question entirely.
resource "ssh_resource" "create_folder_backup_config_dir" {
  host        = local.sanctum_ssh.host
  user        = local.sanctum_ssh.user
  private_key = local.sanctum_ssh.private_key

  commands = ["mkdir -p /etc/pbs-folder-backup && chmod 0700 /etc/pbs-folder-backup"]

  timeout = "20s"
}

resource "ssh_resource" "push_folder_backup_infra" {
  depends_on = [ssh_resource.grant_pbs_token_acl, ssh_resource.create_folder_backup_config_dir]

  host        = local.sanctum_ssh.host
  user        = local.sanctum_ssh.user
  private_key = local.sanctum_ssh.private_key

  file {
    source      = "${path.module}/files/pbs-folder-backup.sh"
    destination = "/usr/local/bin/pbs-folder-backup.sh"
    permissions = "0755"
  }

  file {
    source      = "${path.module}/files/pbs-folder-backup.service"
    destination = "/etc/systemd/system/pbs-folder-backup@.service"
  }

  file {
    content = templatefile("${path.module}/files/credentials.env.tftpl", {
      pbs_repository = local.pbs_repository
      pbs_password   = local.pbs_token.value
    })
    destination = "/etc/pbs-folder-backup/credentials.env"
    permissions = "0600"
  }

  commands = ["systemctl daemon-reload"]

  timeout = "1m"
}

resource "ssh_resource" "delete_folder_backup_infra" {
  when = "destroy"

  host        = local.sanctum_ssh.host
  user        = local.sanctum_ssh.user
  private_key = local.sanctum_ssh.private_key

  commands = [
    "rm -rf /etc/pbs-folder-backup",
    "rm -f /etc/systemd/system/pbs-folder-backup@.service /usr/local/bin/pbs-folder-backup.sh",
    "systemctl daemon-reload",
  ]

  timeout = "1m"
}

# One concrete timer + one per-folder env file per var.folders entry -
# namespace is always the map key (each.key), matching main.tf's file-header
# note and the earlier session decision to keep namespaces per-folder rather
# than per-tier, for UI legibility.
resource "ssh_resource" "folder_backup" {
  for_each = var.folders

  depends_on = [ssh_resource.push_folder_backup_infra]

  host        = local.sanctum_ssh.host
  user        = local.sanctum_ssh.user
  private_key = local.sanctum_ssh.private_key

  file {
    content = templatefile("${path.module}/files/folder.env.tftpl", {
      name       = each.key
      archives   = join(" ", each.value.archives)
      prune_args = join(" ", [for k, v in each.value.prune_backups : "--${k} ${v}"])
    })
    destination = "/etc/pbs-folder-backup/${each.key}.env"
  }

  file {
    content = templatefile("${path.module}/files/pbs-folder-backup.timer.tftpl", {
      name     = each.key
      schedule = each.value.schedule
    })
    destination = "/etc/systemd/system/pbs-folder-backup-${each.key}.timer"
  }

  commands = [
    "systemctl daemon-reload",
    "systemctl enable --now pbs-folder-backup-${each.key}.timer",
  ]

  timeout = "1m"
}

resource "ssh_resource" "delete_folder_backup" {
  for_each = var.folders
  when     = "destroy"

  host        = local.sanctum_ssh.host
  user        = local.sanctum_ssh.user
  private_key = local.sanctum_ssh.private_key

  commands = [
    "systemctl disable --now pbs-folder-backup-${each.key}.timer || true",
    "rm -f /etc/systemd/system/pbs-folder-backup-${each.key}.timer /etc/pbs-folder-backup/${each.key}.env",
    "systemctl daemon-reload",
  ]

  timeout = "1m"
}
