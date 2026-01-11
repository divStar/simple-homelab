/**
 * # Docker VM Setup
 *
 * This module sets up a [Flatcar Linux VM](https://www.flatcar.org/) with Docker.
 *
 * Docker is exposed via TLS port (2376). Look at the [`./files` folder](./files) for more configuration details.
 */
locals {
  ssh_public_key     = trimspace(file(pathexpand("~/.ssh/id_rsa.pub")))
  config_directory   = "${path.module}/files"
  config_file_suffix = ".config.yaml.tftpl"
}

# Butane config for Flatcar
data "ct_config" "flatcar" {
  content      = file("${path.module}/files/config.yaml")
  strict       = true
  pretty_print = true

  snippets = [
    file("${local.config_directory}/general-fixes${local.config_file_suffix}"),
    file("${local.config_directory}/fstrim${local.config_file_suffix}"),
    file("${local.config_directory}/locale${local.config_file_suffix}"),
    templatefile("${local.config_directory}/network${local.config_file_suffix}", {
      vm_hostname               = var.vm_hostname
      vm_network_interface_name = var.vm_network_interface_name
      vm_ip                     = var.vm_ip
      vm_gateway_ip             = var.vm_gateway_ip
      vm_dns_ip                 = var.vm_dns_ip
    }),
    templatefile("${local.config_directory}/ssh-key${local.config_file_suffix}", {
      ssh_public_key = local.ssh_public_key
    }),
    templatefile("${local.config_directory}/disks${local.config_file_suffix}", {
      disks = var.disks
    }),
    templatefile("${local.config_directory}/virtiofs-resources${local.config_file_suffix}", {
      virtiofs_resources = var.viritofs_resources
    }),
    file("${local.config_directory}/aliases${local.config_file_suffix}"),
    templatefile("${local.config_directory}/step-ca${local.config_file_suffix}", {
      step_ca_client_version       = var.step_ca_client_version
      step_ca_domain               = var.step_ca_domain
      step_ca_provisioner_password = var.step_ca_provisioner_password
    }),
    templatefile("${local.config_directory}/docker-cert${local.config_file_suffix}", {
      step_ca_provisioner = var.step_ca_provisioner
      vm_hostname         = var.vm_hostname
      vm_domain           = var.vm_domain
      vm_ip               = var.vm_ip
    }),
    templatefile("${local.config_directory}/docker-service${local.config_file_suffix}", {
      docker_daemon_configuration = var.docker_daemon_configuration
      virtiofs_resources          = var.viritofs_resources
    })
  ]
}

# Upload the transpiled Ignition config as a snippet
resource "proxmox_virtual_environment_file" "ignition_config" {
  node_name    = var.proxmox_node_name
  datastore_id = var.ignition_config_datastore_id
  content_type = "snippets"

  source_raw {
    data      = data.ct_config.flatcar.rendered
    file_name = replace(var.ignition_config_file_name, "VM_ID", var.vm_id)
  }
}

# Download Flatcar stable image
resource "proxmox_virtual_environment_download_file" "flatcar_image" {
  node_name           = var.proxmox_node_name
  datastore_id        = var.flatcar_image_datastore_id
  content_type        = "import"
  file_name           = var.flatcar_image_file_name
  url                 = "https://${var.flatcar_image_channel}.release.flatcar-linux.net/amd64-usr/current/flatcar_production_proxmoxve_image.img"
  overwrite           = true
  overwrite_unmanaged = true
  upload_timeout      = 300
}

# Create the Flatcar VM
resource "proxmox_virtual_environment_vm" "flatcar" {
  depends_on     = [proxmox_virtual_environment_download_file.flatcar_image, proxmox_virtual_environment_file.ignition_config]
  timeout_create = 300

  name        = var.vm_hostname
  description = "Flatcar Container Linux with Docker (with TLS from the Step CA LXC container) and *virtiofs* mounts for media."
  tags        = ["flatcar", "docker", "pve-resources", "disk-images"]
  node_name   = var.proxmox_node_name
  vm_id       = var.vm_id
  on_boot     = true
  boot_order  = [var.disks[0].interface]

  machine = "q35"
  bios    = "ovmf"

  cpu {
    cores = 8
    type  = "host"
  }

  memory {
    dedicated = 65536 // 64GB RAM
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

  dynamic "disk" {
    for_each = var.disks
    content {
      aio          = "native"
      datastore_id = disk.value.datastore_id
      import_from  = disk.value.import_from == "FLATCAR_IMAGE" ? proxmox_virtual_environment_download_file.flatcar_image.id : disk.value.import_from
      interface    = disk.value.interface
      iothread     = true
      discard      = "on"
      cache        = "none"
      ssd          = true
      file_format  = disk.value.file_format
      size         = disk.value.size
      serial       = disk.value.serial
    }
  }

  # VirtioFS shared directories
  dynamic "virtiofs" {
    for_each = var.viritofs_resources
    content {
      mapping   = virtiofs.key
      cache     = "never"
      direct_io = true
    }
  }

  # Network configuration
  network_device {
    bridge      = "vmbr0"
    model       = "virtio"
    mac_address = "06:07:38:2A:54:9F"
  }

  # Pass Ignition configuration via cloud-init user-data
  initialization {
    datastore_id      = var.ignition_config_datastore_id
    user_data_file_id = proxmox_virtual_environment_file.ignition_config.id
  }
}
