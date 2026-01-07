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
  ]
  packages = ["bash", "curl", "ca-certificates", "samba", "samba-common-tools"]
}

# Trigger for user list changes
resource "terraform_data" "users_trigger" {
  input = jsonencode(var.samba_users)
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

  lifecycle {
    replace_triggered_by = [terraform_data.users_trigger.id]
  }

  timeout = "1m"
}

# Create system users and set Samba passwords
resource "ssh_resource" "configure_users" {
  depends_on = [ssh_resource.configure_samba]

  host        = local.container_ip
  user        = "root"
  private_key = module.setup_container.ssh_private_key

  commands = flatten([
    [
      for user in var.samba_users : [
        "adduser -D -H -s /sbin/nologin ${user.username}",
        "(echo '${user.password}'; echo '${user.password}') | smbpasswd -a -s ${user.username}",
        "smbpasswd -e ${user.username}"
      ]
    ],
    [
      "rc-service samba start",
      "rc-update add samba default"
    ]
  ])

  lifecycle {
    replace_triggered_by = [terraform_data.users_trigger.id]
  }

  timeout = "1m"
}