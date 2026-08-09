terraform {
  required_version = ">= 1.10.5"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.111.1"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = ">= 2.7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.9.0"
    }
  }
}

provider "proxmox" {
  endpoint = local.proxmox_endpoint
  insecure = var.proxmox.insecure
  # use root@pam because of bind-mounts (mount_points), same reason pihole's provider does
  username = var.proxmox.username
  password = var.proxmox.password

  ssh {
    username    = var.proxmox.ssh_user
    private_key = file(var.proxmox.ssh_key)
  }
}
