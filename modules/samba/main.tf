/**
 * # Samba Setup
 *
 * This module sets up Samba server in an Alpine LXC container using the provided information.
 */

locals {
  proxmox_endpoint = "https://${var.proxmox.host}:8006"

  container_ip = "192.168.178.156"
}

# Alpine LXC container setup
module "setup_container" {
  source = "../common/modules/alpine"

  proxmox      = var.proxmox
  vm_id        = 702
  hostname     = "sanctum-samba"
  description  = "Alpine Linux based LXC container with Samba"
  tags         = ["alpine", "lxc", "pve-resources"]
  unprivileged = false

  ni_mac_address = "EA:31:0E:A5:D8:4D"
  ni_ip          = local.container_ip
  ni_gateway     = "192.168.178.1"
  ni_subnet_mask = 24
  ni_name        = "eth0"
  ni_bridge      = "vmbr0"

  imagestore_id = "pve-resources"
  startup_order = 2
  mount_points = [
    { volume = "/mnt/storage/application", path = "/mnt/application" },
    { volume = "/mnt/storage/backup", path = "/mnt/backup" },
    { volume = "/mnt/storage/document", path = "/mnt/document" },
    { volume = "/mnt/storage/kyocera-scan", path = "/mnt/scan" },
    { volume = "/mnt/storage/music", path = "/mnt/music" },
    { volume = "/mnt/storage/photo", path = "/mnt/photo" },
    { volume = "/mnt/storage/picture", path = "/mnt/picture" },
    { volume = "/mnt/storage/temp", path = "/mnt/temp" },
    { volume = "/mnt/storage/yuliia", path = "/mnt/yuliia" },
    { volume = "/mnt/backup/video", path = "/mnt/video" },
    { volume = "/mnt/backup/backup/macbook-m1-pro", path = "/mnt/macbook-m1-pro" },
  ]
  packages = ["bash", "curl", "ca-certificates", "samba", "samba-common-tools", "iperf3"]
}

# Trigger for user list changes. Uses triggers_replace, NOT input -- input-only
# changes make terraform_data update in-place, which leaves its own .id
# unchanged (only regenerated on a real create/replace of the terraform_data
# resource itself). Since every replace_triggered_by below references .id,
# using plain `input` here meant a samba_users change silently never actually
# triggered reprovisioning -- confirmed via `tofu plan -replace` while fixing
# the identical bug in modules/pbs-lxc's container_trigger, 2026-08-09.
resource "terraform_data" "users_trigger" {
  triggers_replace = jsonencode(var.samba_users)
}

# Trigger for container replacement - module outputs aren't valid
# replace_triggered_by references on their own (only resources are), hence
# wrapping it the same way users_trigger wraps var.samba_users above. Same
# triggers_replace requirement as users_trigger above, for the same reason.
resource "terraform_data" "container_trigger" {
  triggers_replace = module.setup_container.container_id
}

# Deploy Samba configuration
resource "ssh_resource" "configure_samba" {
  depends_on = [module.setup_container]

  host        = local.container_ip
  user        = "root"
  private_key = module.setup_container.ssh_private_key

  file {
    source      = "${path.module}/files/smb.conf"
    destination = "/etc/samba/smb.conf"
    permissions = "0644"
  }

  # Also replace whenever the container itself is replaced (e.g. a template
  # change) - otherwise a fresh container would silently never get smb.conf
  # pushed to it, since `depends_on` alone doesn't propagate replacement and
  # this resource's `file{}` block isn't tracked as a diffable attribute.
  lifecycle {
    replace_triggered_by = [
      terraform_data.users_trigger.id,
      terraform_data.container_trigger.id,
    ]
  }

  timeout = "1m"
}

# Create system users, set Samba passwords, and configure the shared write group
resource "ssh_resource" "configure_users" {
  depends_on = [ssh_resource.configure_samba]

  host        = local.container_ip
  user        = "root"
  private_key = module.setup_container.ssh_private_key

  # Existence-checked before adduser/addgroup -- unlike smbpasswd -a/-e (which
  # are idempotent by nature, safe to re-run against an existing user), Alpine's
  # adduser/addgroup error out if the target already exists. This resource's
  # container isn't necessarily fresh when it re-runs (replace_triggered_by can
  # fire without the container itself being replaced, e.g. a samba_users edit),
  # so every step here needs to tolerate running against an already-provisioned
  # system, not just a blank one.
  commands = flatten([
    [
      for user in var.samba_users : [
        "id -u ${user.username} >/dev/null 2>&1 || adduser -D -H -s /sbin/nologin ${user.username}",
        "(echo '${user.password}'; echo '${user.password}') | smbpasswd -a -s ${user.username}",
        "smbpasswd -e ${user.username}"
      ]
    ],
    # GID 1004 is pinned explicitly (not left to auto-assignment): the host-side
    # share directories (/mnt/storage/*, /mnt/backup/*) are already chown'd to
    # a matching host-side group (`fileshare`, also GID 1004 on `sanctum`
    # itself). If this GID ever changes here, the host-side chgrp must be
    # updated to match, or every share silently loses group write access again.
    # Write access itself is differentiated per-share purely via smb.conf's
    # `valid users`/`write list` - this group is intentionally the same broad
    # membership for everyone, everywhere.
    [
      "getent group smbwrite >/dev/null 2>&1 || addgroup -g 1004 smbwrite"
    ],
    [
      for user in var.samba_users : [
        "id -nG ${user.username} 2>/dev/null | grep -qw smbwrite || addgroup ${user.username} smbwrite"
      ]
    ],
    [
      "rc-service samba start",
      "rc-update add samba default"
    ]
  ])

  # Also replace whenever the container itself is replaced - see the matching
  # comment on ssh_resource.configure_samba above for why.
  lifecycle {
    replace_triggered_by = [
      terraform_data.users_trigger.id,
      terraform_data.container_trigger.id,
    ]
  }

  timeout = "1m"
}