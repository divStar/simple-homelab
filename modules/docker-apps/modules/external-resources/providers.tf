terraform {
  required_version = ">= 1.10.5"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.8.0"
    }
  }
}

provider "docker" {
  host      = var.remote_docker_host
  cert_path = pathexpand(var.ssl_client_certificates)
}