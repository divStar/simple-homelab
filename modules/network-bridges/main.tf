/**
 * # Network Bridges
 *
 * Handles the creation of Linux bridges on the Proxmox host.
 */
locals {
  proxmox_endpoint = "https://${var.proxmox.host}:8006"
}

resource "proxmox_network_linux_bridge" "this" {
  for_each = { for bridge in var.bridges : bridge.name => bridge }

  node_name = var.proxmox_node_name
  name      = each.value.name

  ports      = each.value.ports
  vlan_aware = each.value.vlan_aware
  vids       = each.value.vlan_aware ? each.value.vids : null

  comment   = each.value.comment
  address   = each.value.address
  autostart = each.value.autostart
}
