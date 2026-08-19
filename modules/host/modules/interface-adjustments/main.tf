/**
 * # Interface Adjustments
 *
 * Persists per-interface OS-level tweaks on the Proxmox host that don't survive a reboot on
 * their own, via `/etc/network/interfaces.d/` drop-ins tied to each interface's own `post-up`
 * hook (`ifupdown2` reapplies these every time the interface comes up, boot included):
 *
 * - `ethtool` advertised link modes, for NIC drivers (e.g. `ixgbe`/X550) that don't advertise
 *   their full hardware-supported mode set by default, silently capping negotiated speed even
 *   with a good cable and a capable link partner.
 * - Source-based routing, for dual-homed interfaces (e.g. a VLAN interface created by
 *   `network-bridges`) that deliberately have no gateway of their own, so replies to traffic
 *   addressed to them don't fall back to the system's main default route out the wrong interface.
 */
locals {
  # SSH connection settings for reuse
  ssh = {
    host        = var.ssh.host
    user        = var.ssh.user
    private_key = file(var.ssh.id_file)
  }

  nic_link_advertise = { for nic in var.nic_link_advertise : nic.interface => nic.modes }
  response_routes    = { for route in var.response_routes : route.interface => route }
}

resource "ssh_resource" "push_nic_advertise_dropin" {
  for_each = local.nic_link_advertise

  host        = local.ssh.host
  user        = local.ssh.user
  private_key = local.ssh.private_key

  file {
    content = templatefile("${path.module}/files/interfaces.d-nbaset-advertise.tftpl", {
      interface = each.key
      modes     = each.value
    })
    destination = "/etc/network/interfaces.d/nbaset-advertise-${each.key}"
    permissions = "0644"
  }

  commands = ["ifreload -a"]

  timeout = "1m"
}

resource "ssh_resource" "remove_nic_advertise_dropins" {
  when = "destroy"

  count = length(local.nic_link_advertise) > 0 ? 1 : 0

  host        = local.ssh.host
  user        = local.ssh.user
  private_key = local.ssh.private_key

  commands = concat(
    [for interface in keys(local.nic_link_advertise) : "rm -f /etc/network/interfaces.d/nbaset-advertise-${interface}"],
    ["ifreload -a"]
  )

  timeout = "1m"
}

resource "ssh_resource" "push_response_route_dropin" {
  for_each = local.response_routes

  host        = local.ssh.host
  user        = local.ssh.user
  private_key = local.ssh.private_key

  file {
    content = templatefile("${path.module}/files/response-route.tftpl", {
      interface      = each.value.interface
      gateway        = each.value.gateway
      source_address = each.value.source_address
      table_name     = each.value.table_name
      priority       = each.value.priority
    })
    destination = "/etc/network/interfaces.d/response-route-${each.key}"
    permissions = "0644"
  }

  commands = [
    "grep -q '^${each.value.table_id} ${each.value.table_name}$' /etc/iproute2/rt_tables || echo '${each.value.table_id} ${each.value.table_name}' >> /etc/iproute2/rt_tables",
    "ifreload -a",
  ]

  timeout = "1m"
}

resource "ssh_resource" "remove_response_route_dropins" {
  when = "destroy"

  count = length(local.response_routes) > 0 ? 1 : 0

  host        = local.ssh.host
  user        = local.ssh.user
  private_key = local.ssh.private_key

  commands = concat(
    [for interface in keys(local.response_routes) : "rm -f /etc/network/interfaces.d/response-route-${interface}"],
    ["ifreload -a"]
  )

  timeout = "1m"
}
