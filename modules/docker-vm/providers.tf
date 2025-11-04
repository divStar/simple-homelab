terraform {
  required_version = ">= 1.10.5"

  required_providers {
    ct = {
      source  = "poseidon/ct"
      version = "0.13.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.86.0"
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