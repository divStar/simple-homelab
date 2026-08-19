terraform {
  required_providers {
    ssh = {
      source  = "loafoe/ssh"
      version = "~> 2.7"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.13.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.3.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.111.1"
    }
  }
}

provider "proxmox" {
  endpoint = local.proxmox_endpoint
  insecure = var.proxmox.insecure
  username = var.proxmox.username
  password = var.proxmox.password

  ssh {
    username    = var.proxmox.ssh_user
    private_key = file(var.proxmox.ssh_key)
  }
}
