terraform {
  required_version = ">= 1.10.5"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.111"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = ">= 2.7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.7.2"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  insecure = var.proxmox_insecure
  password = var.proxmox_password
  username = "root@pam"

  ssh {
    username    = var.proxmox_ssh_user
    private_key = file(var.proxmox_ssh_key)
  }
}
