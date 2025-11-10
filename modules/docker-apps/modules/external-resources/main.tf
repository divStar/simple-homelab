/**
 * # External (Docker) resources
 *
 * This module creates resources, that are not supposed to be part of a `docker-compose.yml`.
 *
 * It e.g. creates networks and volumes, that should not be removed if a docker compose stack is undeployed.
 */

# Set up Docker networks, which will be used as `external` networks
resource "docker_network" "this" {
  for_each = var.networks

  name   = each.key
  driver = each.value.driver

  ipam_config {
    subnet  = each.value.subnet
    gateway = each.value.gateway
  }

  dynamic "labels" {
    for_each = each.value.labels
    content {
      label = labels.key
      value = labels.value
    }
  }
}

# Set up Docker volumes, which will be used as `external` volumes
resource "docker_volume" "this" {
  for_each = var.volumes

  name        = each.key
  driver      = each.value.driver
  driver_opts = each.value.driver_opts

  dynamic "labels" {
    for_each = each.value.labels
    content {
      label = labels.key
      value = labels.value
    }
  }
}
