/**
 * # PBS LXC Setup
 *
 * This module sets up Proxmox Backup Server in a Debian LXC container, using
 * /mnt/backup/pbs (bind-mounted from the host) as the datastore location.
 * Replaces modules/pbs-vm as the deployed PBS instance -- that module is kept
 * in the repo as a fallback option, but no longer applied.
 *
 * <!-- docs-meta: order=50 icon=pbs -->
 */

locals {
  proxmox_endpoint = "https://${var.proxmox.host}:8006"

  container_ip = "10.0.5.6"

  # Used both for the container's own hostname and (with .my.world appended
  # inline at the one place that needs it) the ACME cert's node domain.
  hostname = "sanctum-pbs"

  # Host-side directory (bind-mounted in via mount_points below) and the
  # container-internal path it's mounted at. No PVE storage registration
  # needed for either -- mount_points bind-mount a raw host path directly,
  # same as modules/samba's shares. "primary" borrows PBS's own removable-
  # datastore naming convention (/mnt/datastore/<name>) purely for future
  # extensibility if a second datastore is ever added -- this one isn't
  # actually removable, just consistently named.
  host_datastore_path  = "/mnt/backup/pbs"
  guest_datastore_path = "/mnt/datastore/primary"

  # Same idea, for PBS's own config/state directory rather than the datastore
  # data - user.cfg, token.shadow, acl.cfg, datastore.cfg, domains.cfg (ACME
  # account), authkey.key, node.cfg all live here. Confirmed via `dpkg -L
  # proxmox-backup-server` that none of it is a package-shipped conffile -
  # it's entirely generated at runtime by the PBS daemon on first start, same
  # category as /etc/pihole and /etc/step-ca already bind-mounting their own
  # state elsewhere in this repo.
  host_config_path  = "/mnt/storage/pbs-lxc"
  guest_config_path = "/etc/proxmox-backup"

  setup_datastore_script     = "setup-datastore.sh"
  setup_acme_script          = "setup-acme.sh"
  daily_update_override_conf = "update-override.conf"
  daily_update_override_dir  = "/etc/systemd/system/proxmox-backup-daily-update.timer.d"

  # Matches common/modules/debian's own default image (debian-13-standard, trixie)
  debian_release = "trixie"
}

# Prepare the host-side datastore directory before the container references it
# as a mount point -- LXC mount_points need the host path to already exist,
# and Proxmox doesn't create it automatically. Chowned to 100000:100000 (this
# host's confirmed unprivileged UID/GID mapping base, from /etc/subuid:
# "root:100000:65536") ONLY on first-ever bootstrap, so container-root can
# initially write into it. Confirmed the hard way (2026-08-09, destroy/rebuild
# test): PBS's own `datastore create` takes ownership of this same directory
# itself, as the "backup" system user (uid 34 -> host 100034), once a real
# datastore is created in it -- unconditionally re-chowning to 100000:100000
# on every apply stomps that back to root and breaks --reuse-datastore on the
# next rebuild ("permissions or owner not correct"). Same "assume data already
# exists" principle files/setup-datastore.sh already follows.
resource "ssh_resource" "prepare_datastore_directory" {
  host        = var.proxmox.host
  user        = var.proxmox.ssh_user
  private_key = file(var.proxmox.ssh_key)

  commands = [
    "mkdir -p ${local.host_datastore_path}",
    "[ -d ${local.host_datastore_path}/.chunks ] || chown 100000:100000 ${local.host_datastore_path}",
  ]

  timeout = "20s"
}

# Unlike prepare_datastore_directory above, this one needs to start OWNED BY
# backup, not root, AND at exactly mode 700 - both confirmed the hard way,
# 2026-08-26:
# - proxmox-backup-proxy runs as User=backup/Group=backup (no
#   ConfigurationDirectory=/StateDirectory= in its unit, so systemd doesn't
#   chown this for it) - a root-owned directory left it unable to create
#   authkey.key/acme/accounts/* at all (panicked: "unable to read
#   authkey.pub - No such file or directory").
# - Fixing ownership alone still wasn't enough: proxmox-backup.service (the
#   *other* PBS daemon, proxmox-backup-api, which runs as root and is the one
#   that actually generates authkey.key on first start) refuses to start at
#   all unless the directory is *exactly* mode 700 - plain `mkdir -p` leaves
#   it at 755, and proxmox-backup-api's own error is explicit about this:
#   "configuration directory '/etc/proxmox-backup' permission problem - wrong
#   permission (755 != 700)". Without proxmox-backup-api ever starting,
#   authkey.key never gets generated, and proxmox-backup-proxy fails on the
#   missing key downstream - both end up crash-looping and hitting systemd's
#   restart rate limit before the real cause is obvious from either one
#   alone.
# 100034 = this host's confirmed subuid base (100000) + backup's
# container-internal uid (34), same mapping already verified via the
# datastore path's real ownership once PBS takes it over.
resource "ssh_resource" "prepare_config_directory" {
  host        = var.proxmox.host
  user        = var.proxmox.ssh_user
  private_key = file(var.proxmox.ssh_key)

  commands = [
    "mkdir -p ${local.host_config_path}",
    "[ -f ${local.host_config_path}/user.cfg ] || chown 100034:100034 ${local.host_config_path}",
    "[ -f ${local.host_config_path}/user.cfg ] || chmod 700 ${local.host_config_path}",
  ]

  timeout = "20s"
}

# Debian LXC container setup
module "setup_container" {
  source     = "../common/modules/debian"
  depends_on = [ssh_resource.prepare_datastore_directory, ssh_resource.prepare_config_directory]

  proxmox      = var.proxmox
  vm_id        = 704
  hostname     = local.hostname
  description  = "Debian LXC container running Proxmox Backup Server (TLS via Step CA ACME)"
  tags         = ["debian", "backup", "lxc", "pve-resources"]
  unprivileged = true

  # Base module's default (1024) OOM-killed proxmox-backup-proxy the first
  # time backup-jobs' folder-backup track fired 3 concurrent multi-GB
  # uploads at once (confirmed via `journalctl -k`: "Failed with result
  # 'oom-kill'", right as 3 uploads were mid-transfer) - bumped for real
  # headroom under concurrent load, not just single-guest backups. PBS's own
  # docs put even eval-only minimums at 2 cores / 2GB, recommended production
  # at 4+ cores / 4GB+1GB-per-TB - the base module's defaults (1 core, 1GB)
  # were under the eval floor, not just thin for our workload.
  cpu_cores        = 2
  memory_dedicated = 4096

  network_interfaces = [
    {
      name        = "eth0"
      bridge      = "vmbr1"
      mac_address = "EA:31:0E:A5:D8:51"
      ip          = local.container_ip
      subnet_mask = 24
      vlan_id     = 5
      gateway     = "10.0.5.1"
    }
  ]

  dns_servers       = ["10.0.5.1"]
  dns_search_domain = "my.world"

  imagestore_id = "pve-resources"
  startup_order = 4

  mount_points = [
    { volume = local.host_datastore_path, path = local.guest_datastore_path },
    { volume = local.host_config_path, path = local.guest_config_path },
  ]
}

# Trigger for container replacement - module outputs aren't valid
# replace_triggered_by references on their own (only resources are; confirmed
# via `tofu validate`: "Only resources, count.index, and each.key may be used
# in replace_triggered_by"), hence wrapping it in a terraform_data resource.
# Uses triggers_replace, NOT input -- confirmed via `tofu plan -replace` that
# terraform_data's .id stays stable across a plain input-only update (only
# regenerated when the terraform_data resource itself is destroyed/recreated).
# triggers_replace is the argument specifically documented to force that full
# replacement whenever its value changes, which is what actually makes .id
# change and propagate. modules/samba and modules/pihole both currently use
# `input = ...` for this same pattern, which means their own replace_triggered_by
# chains have this identical latent bug -- worth fixing there too.
resource "terraform_data" "container_trigger" {
  triggers_replace = module.setup_container.container_id
}

# Install PBS itself (deb822 apt source + package). Connects as root directly,
# no sudo -- unlike pbs-vm's cloud-image VM (which blocks root SSH by default,
# hence its debian+sudo pattern), common/modules/debian's LXC template has no
# such restriction; pihole's entire main.tf already connects as root the same
# way. No qemu-guest-agent either -- that's QEMU/KVM-specific (talks over a
# virtio-serial channel the hypervisor provides to a VM); LXC containers share
# the host kernel directly, so there's no such channel and nothing for an
# agent to do.
resource "ssh_resource" "install_pbs" {
  depends_on = [module.setup_container]

  host        = local.container_ip
  user        = "root"
  private_key = module.setup_container.ssh_private_key

  commands = [
    "mkdir -p /usr/share/keyrings",
    "wget -q https://enterprise.proxmox.com/debian/proxmox-archive-keyring-${local.debian_release}.gpg -O /usr/share/keyrings/proxmox-archive-keyring.gpg",
    join("\n", [
      "tee /etc/apt/sources.list.d/proxmox.sources > /dev/null << 'EOF'",
      "Types: deb",
      "URIs: http://download.proxmox.com/debian/pbs",
      "Suites: ${local.debian_release}",
      "Components: pbs-no-subscription",
      "Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg",
      "EOF"
    ]),
    # proxmox-backup-server itself ships /etc/apt/sources.list.d/pbs-
    # enterprise.sources (confirmed via `dpkg -S`) - doesn't exist yet on a
    # truly fresh bootstrap (hence apt-get update succeeding the first time),
    # but reappears on every reinstall/reprovision once the package is
    # already present, and requires a paid subscription to actually reach -
    # 401 Unauthorized without one, which fails apt-get update outright since
    # apt treats a single bad repo as fatal. rm -f is safe either way.
    "rm -f /etc/apt/sources.list.d/pbs-enterprise.sources",
    "apt-get update",
    "env DEBIAN_FRONTEND=noninteractive apt-get install -y proxmox-backup-server",
  ]

  lifecycle {
    replace_triggered_by = [terraform_data.container_trigger.id]
  }

  timeout = "2m"
}

# Register (or re-register) the PBS datastore at the mount_point path -- see
# files/setup-datastore.sh for why this assumes existing data by default
# rather than assuming an empty directory. Needs proxmox-backup-manager, hence
# depends on install_pbs directly.
resource "ssh_resource" "setup_datastore" {
  depends_on = [ssh_resource.install_pbs]

  host        = local.container_ip
  user        = "root"
  private_key = module.setup_container.ssh_private_key

  file {
    source      = "${path.module}/files/${local.setup_datastore_script}"
    destination = "/tmp/${local.setup_datastore_script}"
    permissions = "0755"
  }

  commands = [
    join(" ", [
      "/tmp/${local.setup_datastore_script}",
      "--mount-path ${local.guest_datastore_path}",
      "--datastore-name ${var.pbs_datastore_name}",
    ])
  ]

  lifecycle {
    replace_triggered_by = [terraform_data.container_trigger.id]
  }

  timeout = "2m"
}

# Get PBS a trusted cert from Step CA via ACME -- identical to modules/pbs-vm,
# the mechanism (PBS's own built-in ACME client) doesn't care whether PBS is
# running in a VM or an LXC. Depends on install_pbs directly (also needs
# proxmox-backup-manager), not on setup_datastore -- the two don't actually
# depend on each other, only on PBS being installed, so there's no reason to
# serialize one after the other.
resource "ssh_resource" "setup_acme" {
  depends_on = [ssh_resource.install_pbs]

  host        = local.container_ip
  user        = "root"
  private_key = module.setup_container.ssh_private_key

  file {
    source      = "${path.module}/files/${local.setup_acme_script}"
    destination = "/tmp/${local.setup_acme_script}"
    permissions = "0755"
  }

  commands = [
    join(" ", [
      "/tmp/${local.setup_acme_script}",
      "--step-ca-domain ${var.step_ca_domain}",
      "--step-client-version ${var.step_ca_client_version}",
      "--acme-account-name ${var.step_ca_acme_account_name}",
      "--acme-contact ${var.step_ca_acme_contact}",
      "--pbs-node-domain ${local.hostname}.my.world",
    ])
  ]

  lifecycle {
    replace_triggered_by = [terraform_data.container_trigger.id]
  }

  timeout = "2m"
}

# systemd drop-in directories are never auto-created (a convention admins/
# tooling create themselves, not something the base unit's package provides)
# and loafoe/ssh's file{} block doesn't create missing parent directories
# either -- confirmed by pihole's own create_pihole_directory precedent for
# the exact same reason. Needs its own preceding step, not combined with the
# file push below.
resource "ssh_resource" "create_daily_update_override_directory" {
  depends_on = [ssh_resource.install_pbs]

  host        = local.container_ip
  user        = "root"
  private_key = module.setup_container.ssh_private_key

  commands = ["mkdir -p ${local.daily_update_override_dir}"]

  lifecycle {
    replace_triggered_by = [terraform_data.container_trigger.id]
  }

  timeout = "20s"
}

# Retime PBS's own daily-update service (package updates + ACME cert renewal --
# they're the same bundled job, not separable, confirmed on modules/pbs-vm) off
# its default 1AM+5h-jitter schedule, which lands in the 2-3AM window the home
# router does its own reconnect. Fixed 4AM, no jitter -- same fix pbs-vm
# needed, for the same underlying reason (this is PBS's own timer, not
# anything VM/LXC-specific). A systemd drop-in, not an edit of the
# vendor-shipped unit, so it survives a proxmox-backup-server package upgrade.
resource "ssh_resource" "retime_daily_update" {
  depends_on = [ssh_resource.create_daily_update_override_directory]

  host        = local.container_ip
  user        = "root"
  private_key = module.setup_container.ssh_private_key

  file {
    source      = "${path.module}/files/${local.daily_update_override_conf}"
    destination = "${local.daily_update_override_dir}/override.conf"
    permissions = "0644"
  }

  commands = ["systemctl daemon-reload"]

  lifecycle {
    replace_triggered_by = [terraform_data.container_trigger.id]
  }

  timeout = "1m"
}
