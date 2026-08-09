/**
 * # PBS VM Setup
 *
 * This module sets up a Debian VM running Proxmox Backup Server.
 */
locals {
  ssh_public_key       = trimspace(file(pathexpand("~/.ssh/id_rsa.pub")))
  ssh_private_key_path = pathexpand("~/.ssh/id_rsa")

  datastore_mount_path = "/mnt/proxmox-backup"
  vm_fqdn               = "${var.vm_hostname}.${var.vm_domain}"

  setup_datastore_script = "setup-datastore.sh"
  setup_acme_script       = "setup-acme.sh"

  # Matches docker-vm's pinned step client version
  step_ca_client_version = "0.27.4"
}

# Recoverable root password (console access; day-to-day access is via the shared
# operator SSH key, same as docker-vm)
resource "random_password" "root_password" {
  length  = 24
  special = true
}

locals {
  # Whole "root:password" chpasswd line, base64'd as a unit. Piped straight through
  # base64 -d into chpasswd on the remote end without ever being reconstructed via
  # shell string interpolation -- safe regardless of what characters the generated
  # password contains (special=true can produce quotes/backticks/$ etc).
  root_chpasswd_line_b64 = base64encode("root:${random_password.root_password.result}")
}

# Download Debian genericcloud image (proxmox_download_file, not the deprecated
# proxmox_virtual_environment_download_file docker-vm still uses)
resource "proxmox_download_file" "debian_image" {
  node_name           = var.proxmox_node_name
  datastore_id        = var.debian_image_datastore_id
  content_type        = "import"
  file_name           = var.debian_image_file_name
  url                 = "https://cloud.debian.org/images/cloud/${var.debian_image_release}/latest/debian-13-genericcloud-amd64.qcow2"
  overwrite           = true
  overwrite_unmanaged = true
  upload_timeout      = 300
}

# Create the PBS VM
resource "proxmox_virtual_environment_vm" "pbs" {
  depends_on     = [proxmox_download_file.debian_image]
  timeout_create = 120

  name        = var.vm_hostname
  description = "Debian VM running Proxmox Backup Server (TLS via Step CA ACME)"
  tags        = ["debian", "pbs", "pve-resources"]
  node_name   = var.proxmox_node_name
  vm_id       = var.vm_id
  on_boot     = true
  boot_order  = ["virtio0"]

  # Guards the `tofu`-driven path only (accidental `tofu destroy`, or a config
  # change that would force a replace) -- destroying currently-attached disks,
  # including the backup datastore, along with the VM. Does NOT cover a raw
  # `qm destroy` run outside Terraform (see scripts/destroy-vmlxc.sh's own
  # PROTECTED_IDS guard for that path).
  lifecycle {
    prevent_destroy = true
  }

  machine = "q35"
  bios    = "ovmf"

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 4096
  }

  agent {
    enabled = true
  }

  operating_system {
    type = "l26" # Linux kernel 2.6+
  }

  efi_disk {
    datastore_id = var.efi_disk_datastore_id
    file_format  = "raw"
    type         = "4m"
  }

  # OS disk, imported from the Debian cloud image
  disk {
    aio          = "native"
    datastore_id = var.os_disk_datastore_id
    import_from  = proxmox_download_file.debian_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    cache        = "none"
    ssd          = true
    file_format  = "qcow2"
    size         = var.os_disk_size_gb
  }

  # PBS datastore disk -- blank, carved from the new /mnt/backup-backed storage.
  # ssd=false because the underlying media genuinely is spinning HDD (RAID1 mirror),
  # unlike docker-vm's disks which are all on NVMe.
  #
  # backup=false: this VM will itself be a backup-jobs target (OS disk only) --
  # without this, PBS would try to back its own multi-TB datastore up into itself.
  disk {
    aio          = "native"
    datastore_id = var.datastore_disk_datastore_id
    interface    = "virtio1"
    iothread     = true
    discard      = "on"
    cache        = "none"
    ssd          = false
    file_format  = "raw"
    size         = var.datastore_disk_size_gb
    backup       = false
  }

  network_device {
    bridge      = "vmbr0"
    model       = "virtio"
    mac_address = "06:2A:97:E1:5C:83"
  }

  # Native cloud-init support -- no custom snippet needed, unlike docker-vm's
  # Ignition/Butane pipeline (Debian has cloud-init built into the image already)
  initialization {
    datastore_id = var.os_disk_datastore_id

    ip_config {
      ipv4 {
        address = "${var.vm_ip}/24"
        gateway = var.vm_gateway_ip
      }
    }

    dns {
      servers = [var.vm_dns_ip]
    }

    # No password here -- debian's access is key-based only (see ssh_resource.install_pbs
    # below for how root's actual password gets set, which is what root_password means).
    user_account {
      username = "debian"
      keys     = [local.ssh_public_key]
    }
  }
}

# Install PBS itself (deb822 apt source + package)
resource "ssh_resource" "install_pbs" {
  depends_on = [proxmox_virtual_environment_vm.pbs]

  host        = var.vm_ip
  user        = "debian"
  private_key = file(local.ssh_private_key_path)

  commands = [
    "sudo mkdir -p /usr/share/keyrings",
    "sudo wget -q https://enterprise.proxmox.com/debian/proxmox-archive-keyring-${var.debian_image_release}.gpg -O /usr/share/keyrings/proxmox-archive-keyring.gpg",
    # sudo tee, not sudo cat > file: shell redirection is set up by the *unprivileged*
    # shell before sudo escalates, so `sudo cat > /etc/...` would fail with permission
    # denied on the target file -- tee itself needs to be the one doing the writing.
    join("\n", [
      "sudo tee /etc/apt/sources.list.d/proxmox.sources > /dev/null << 'EOF'",
      "Types: deb",
      "URIs: http://download.proxmox.com/debian/pbs",
      "Suites: ${var.debian_image_release}",
      "Components: pbs-no-subscription",
      "Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg",
      "EOF"
    ]),
    "sudo apt-get update",
    # qemu-guest-agent isn't in Debian's genericcloud image despite the name -- confirmed
    # by hand on a live VM. It's a static unit meant to self-activate via the virtio-serial
    # device's udev "add" event, but installing it mid-boot (device already present, no
    # fresh add event) leaves it inactive -- so start it explicitly rather than rely on that.
    "sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y proxmox-backup-server qemu-guest-agent",
    "sudo systemctl start qemu-guest-agent",
    # root@pam is PBS's pre-existing superuser (no extra ACL setup needed), and this is
    # the account the PBS web UI login is meant to use -- SSH access stays debian+sudo
    # only, root gets a Linux password purely for local console / PBS UI auth.
    "echo '${local.root_chpasswd_line_b64}' | base64 -d | sudo chpasswd",
  ]

  # depends_on above is ordering-only and doesn't propagate a VM replacement
  # (e.g. an image/config change forcing `must be replaced`) -- without this,
  # a fresh VM would silently never get PBS installed on it. Reference
  # pattern: modules/samba/main.tf.
  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_vm.pbs.id]
  }

  timeout = "2m"
}

# Format/mount the datastore disk and create the PBS datastore on it
resource "ssh_resource" "setup_datastore" {
  depends_on = [ssh_resource.install_pbs]

  host        = var.vm_ip
  user        = "debian"
  private_key = file(local.ssh_private_key_path)

  file {
    source      = "${path.module}/files/${local.setup_datastore_script}"
    destination = "/tmp/${local.setup_datastore_script}"
    permissions = "0755"
  }

  commands = [
    join(" ", [
      "sudo /tmp/${local.setup_datastore_script}",
      "--device /dev/vdb",
      "--mount-path ${local.datastore_mount_path}",
      "--datastore-name ${var.pbs_datastore_name}",
    ])
  ]

  # See install_pbs above for why this is needed.
  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_vm.pbs.id]
  }

  timeout = "2m"
}

# Get PBS a trusted cert from Step CA via ACME
resource "ssh_resource" "setup_acme" {
  depends_on = [ssh_resource.setup_datastore]

  host        = var.vm_ip
  user        = "debian"
  private_key = file(local.ssh_private_key_path)

  file {
    source      = "${path.module}/files/${local.setup_acme_script}"
    destination = "/tmp/${local.setup_acme_script}"
    permissions = "0755"
  }

  commands = [
    join(" ", [
      "sudo /tmp/${local.setup_acme_script}",
      "--step-ca-domain ${var.step_ca_domain}",
      "--step-client-version ${local.step_ca_client_version}",
      "--acme-account-name ${var.step_ca_acme_account_name}",
      "--acme-contact ${var.step_ca_acme_contact}",
      "--pbs-node-domain ${local.vm_fqdn}",
    ])
  ]

  # See install_pbs above for why this is needed.
  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_vm.pbs.id]
  }

  timeout = "2m"
}

# Retime PBS's own daily-update service (package updates + ACME cert renewal --
# they're the same bundled job, not separable) off its default 1AM+5h-jitter
# schedule, which lands in the 2-3AM window the home router does its own
# reconnect. Fixed 4AM, no jitter. A systemd drop-in, not an edit of the
# vendor-shipped unit, so it survives a proxmox-backup-server package upgrade.
resource "ssh_resource" "retime_daily_update" {
  depends_on = [ssh_resource.install_pbs]

  host        = var.vm_ip
  user        = "debian"
  private_key = file(local.ssh_private_key_path)

  commands = [
    "sudo mkdir -p /etc/systemd/system/proxmox-backup-daily-update.timer.d",
    join("\n", [
      "sudo tee /etc/systemd/system/proxmox-backup-daily-update.timer.d/override.conf > /dev/null << 'EOF'",
      "[Timer]",
      "OnCalendar=",
      "OnCalendar=*-*-* 4:00",
      "RandomizedDelaySec=0",
      "EOF"
    ]),
    "sudo systemctl daemon-reload",
  ]

  # See install_pbs above for why this is needed.
  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_vm.pbs.id]
  }

  timeout = "1m"
}
