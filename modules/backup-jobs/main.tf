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

  # SSH connection to the PBS box itself.
  pbs_ssh = {
    host        = var.pbs.server
    user        = "root"
    private_key = file(var.proxmox.ssh_key)
  }

  # SSH connection to the PVE host itself.
  sanctum_ssh = {
    host        = var.proxmox.host
    user        = var.proxmox.ssh_user
    private_key = file(var.proxmox.ssh_key)
  }

  pbs_token = jsondecode(ssh_resource.create_pbs_token.result)

  pbs_repository = "${local.pbs_token.tokenid}@${var.pbs.server}:${var.pbs.datastore}"
}

# Dedicated PBS user for this module's own storage credential.
resource "ssh_resource" "create_pbs_user" {
  host        = local.pbs_ssh.host
  user        = local.pbs_ssh.user
  private_key = local.pbs_ssh.private_key

  commands = [
    "proxmox-backup-manager user list --output-format json | grep -q '\"userid\":\"${var.pbs_token_userid}\"' || proxmox-backup-manager user create ${var.pbs_token_userid} --comment 'Terraform-managed - modules/backup-jobs storage credential'",
  ]

  timeout = "20s"
}

# Delete the dedicated PBS user.
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

# Delete existing PBS token for the user.
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

# Create a new PBS token for the user.
resource "ssh_resource" "create_pbs_token" {
  depends_on = [ssh_resource.delete_existing_pbs_token]

  host        = local.pbs_ssh.host
  user        = local.pbs_ssh.user
  private_key = local.pbs_ssh.private_key

  # Newly generated tokens carry zero permissions until an ACL grant exists (see grant_pbs_token_acl below).
  commands = [
    "proxmox-backup-manager user generate-token ${var.pbs_token_userid} ${var.pbs_token_name} --comment 'modules/backup-jobs' | sed 's/^Result: //'",
  ]

  timeout = "20s"
}

# Grant the user the necessary ACL permissions.
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

# Grant the user token the necessary ACL permissions.
resource "ssh_resource" "grant_pbs_token_acl" {
  depends_on = [ssh_resource.create_pbs_token, ssh_resource.grant_pbs_user_acl]

  host        = local.pbs_ssh.host
  user        = local.pbs_ssh.user
  private_key = local.pbs_ssh.private_key

  commands = [
    "proxmox-backup-manager acl update /datastore/${var.pbs.datastore} DatastoreAdmin --auth-id '${local.pbs_token.tokenid}'",
  ]

  timeout = "20s"
}

# Register PBS as a storage target PVE can back guests up to, authenticated with the dedicated token above
# (username = full tokenid, password = secret - the same user@realm!tokenname / secret pairing PVE's own
# storage.cfg accepts in place of a plain user password).
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

# One job per guest - each guest's primary disk(s).
# Note: EFI disks have no per-disk backup toggle in this provider,
# so they're always included automatically, nothing to configure for that here).
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

# PBS's own datastore verify job.
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

# Delete verify jobs.
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

# Create PBS backup directory if necessary and chmod it.
resource "ssh_resource" "create_folder_backup_config_dir" {
  host        = local.sanctum_ssh.host
  user        = local.sanctum_ssh.user
  private_key = local.sanctum_ssh.private_key

  commands = ["mkdir -p /etc/pbs-folder-backup && chmod 0700 /etc/pbs-folder-backup"]

  timeout = "20s"
}

# Push folder backup infrastructure to the host.
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

# Delete folder backup infrastructure from host.
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

# Delete folder backup runs.
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
