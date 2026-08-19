/**
 * # Network Bridges
 *
 * Handles the creation of Linux bridges and VLAN interfaces on the Proxmox host. Uses the
 * `proxmox` provider inherited from the parent `host` module - no provider configuration of its
 * own.
 */
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

# Depends on every bridge, not just the one a given VLAN interface's name implies, since that
# relationship only exists inside a string (e.g. "vmbr1.5") that OpenTofu has no native way to
# parse - without this, a from-scratch apply has no guarantee the parent bridge is created first.
resource "proxmox_network_linux_vlan" "this" {
  for_each   = { for interface in var.vlan_interfaces : interface.name => interface }
  depends_on = [proxmox_network_linux_bridge.this]

  node_name = var.proxmox_node_name
  name      = each.value.name

  address   = each.value.address
  gateway   = each.value.gateway
  comment   = each.value.comment
  autostart = each.value.autostart
}
