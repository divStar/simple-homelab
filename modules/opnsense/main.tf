/**
 * # OPNsense VM
 *
 * Creates the OPNsense router/firewall VM. WAN attaches untagged to `var.wan_bridge` (gets its
 * address from upstream, e.g. via DHCP during the test phase). LAN attaches untagged/trunk to
 * `var.lan_bridge` - OPNsense itself defines VLAN sub-interfaces on top of that one interface.
 *
 * OPNsense has no unattended-install path, so the initial OS install is a one-time manual step
 * through the Proxmox console. Set `boot_from_installer = true` (the default) for that first
 * boot, then flip it to `false` and re-apply afterwards to boot from disk and eject the ISO.
 *
 * OPNsense's own configuration lives entirely in one file (`/conf/config.xml`) on the guest -
 * this module deliberately does not wire up a full-VM PBS backup job, since the config is backed
 * up separately (see project notes) and a full-disk backup of an otherwise-reproducible install
 * isn't needed.
 */
locals {
  proxmox_endpoint = "https://${var.proxmox.host}:8006"

  iso_file_name = "OPNsense-${var.opnsense_version}-dvd-amd64.iso"
  iso_url       = "https://pkg.opnsense.org/releases/mirror/OPNsense-${var.opnsense_version}-dvd-amd64.iso.bz2"
}

# Download and decompress the OPNsense install ISO.
resource "proxmox_download_file" "opnsense_iso" {
  content_type = "iso"
  datastore_id = var.iso_datastore_id
  node_name    = var.proxmox_node_name

  url                     = local.iso_url
  file_name               = local.iso_file_name
  decompression_algorithm = "bz2"
  overwrite               = false
}

resource "proxmox_virtual_environment_vm" "opnsense" {
  depends_on = [proxmox_download_file.opnsense_iso]

  name          = var.vm_name
  description   = "OPNsense router/firewall - WAN on ${var.wan_bridge}, LAN (trunk) on ${var.lan_bridge}."
  tags          = ["opnsense", "router", "disk-images"]
  node_name     = var.proxmox_node_name
  vm_id         = var.vm_id
  on_boot       = true
  boot_order    = var.boot_from_installer ? ["ide3", "scsi0"] : ["scsi0"]
  scsi_hardware = "virtio-scsi-single" # required for per-disk `iothread` on scsi0 below to actually take effect

  machine = "q35"
  bios    = "ovmf"

  cpu {
    cores = var.cpu_cores
    type  = "host"
  }

  memory {
    dedicated = var.memory
  }

  agent {
    enabled = false # OPNsense/FreeBSD doesn't ship the QEMU guest agent by default
  }

  operating_system {
    type = "other" # FreeBSD-based, not Linux
  }

  efi_disk {
    datastore_id = var.efi_disk_datastore_id
    file_format  = "raw"
    type         = "4m"
  }

  disk {
    datastore_id = var.disk_datastore_id
    interface    = "scsi0"
    iothread     = true
    discard      = "on"
    cache        = "none"
    ssd          = true
    file_format  = "qcow2"
    size         = var.disk_size
  }

  cdrom {
    file_id = var.boot_from_installer ? proxmox_download_file.opnsense_iso.id : "none"
  }

  # WAN - untagged, gets its address from upstream (e.g. DHCP from the FritzBox during the test phase)
  network_device {
    bridge = var.wan_bridge
    model  = "virtio"
  }

  # LAN - untagged/trunk, OPNsense defines VLAN sub-interfaces on top of this one interface
  network_device {
    bridge = var.lan_bridge
    model  = "virtio"
  }
}
