/**
 * # NIC Link Advertise
 *
 * Persists explicit `ethtool` advertised link modes per NIC via an `/etc/network/interfaces.d/`
 * drop-in, so drivers that don't advertise their full hardware-supported mode set by default
 * (e.g. `ixgbe`/X550 skipping NBASE-T 2.5G/5G) don't silently cap negotiated speed below what
 * both the NIC and its link partner actually support. Runtime-only `ethtool -s` changes don't
 * survive a reboot; this makes the setting reapply every time the interface comes up via
 * `ifupdown2`'s own `post-up` hook, boot included.
 */
locals {
  # SSH connection settings for reuse
  ssh = {
    host        = var.ssh.host
    user        = var.ssh.user
    private_key = file(var.ssh.id_file)
  }

  nic_link_advertise = { for nic in var.nic_link_advertise : nic.interface => nic.modes }
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
