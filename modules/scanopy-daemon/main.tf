/**
 * # Scanopy Daemon (standalone LXC)
 *
 * Runs a standalone `scanopy-daemon` in a Debian LXC container, dual-homed onto
 * every VLAN (`vmbr1.5/10/20/30/40`) so it has genuine ARP-level presence on
 * each subnet - unlike SNMP-relayed discovery (via OPNsense's ARP/routing
 * tables), this catches hosts with no open ports and gets real MACs directly.
 *
 * Replaces the native `scanopy-daemon` process that previously ran directly on
 * the Proxmox host (sanctum) for this same purpose - moving it into an
 * isolated LXC avoids giving the hypervisor itself a routable presence on
 * every VLAN. sanctum's own `snmpd`/`lldpd` (exposing its *physical* NIC's
 * LLDP neighbor data) are unrelated to this daemon and stay in place.
 */

locals {
  proxmox_endpoint = "https://${var.proxmox.host}:8006"

  # net0 (vmbr1.5) is the only interface with a gateway - it's what Terraform's
  # own SSH provisioning connects through, and the only one that needs to route
  # anywhere. The others only need on-link ARP visibility, not a default route.
  network_interfaces = [
    { name = "eth0", bridge = "vmbr1", mac_address = "EA:31:0E:A5:D8:60", ip = "10.0.5.9", subnet_mask = 24, vlan_id = 5, gateway = "10.0.5.1" },
    { name = "eth1", bridge = "vmbr1", mac_address = "EA:31:0E:A5:D8:61", ip = "10.0.10.9", subnet_mask = 24, vlan_id = 10 },
    { name = "eth2", bridge = "vmbr1", mac_address = "EA:31:0E:A5:D8:62", ip = "10.0.20.9", subnet_mask = 24, vlan_id = 20 },
    { name = "eth3", bridge = "vmbr1", mac_address = "EA:31:0E:A5:D8:63", ip = "10.0.30.9", subnet_mask = 24, vlan_id = 30 },
    { name = "eth4", bridge = "vmbr1", mac_address = "EA:31:0E:A5:D8:64", ip = "10.0.40.9", subnet_mask = 24, vlan_id = 40 },
  ]

  container_ip = local.network_interfaces[0].ip

  dns_servers       = ["10.0.5.1"]
  dns_search_domain = "my.world"

  scanopy_server_url = "https://topology.my.world"
}

# Debian LXC container setup
module "setup_container" {
  source = "../common/modules/debian"

  proxmox          = var.proxmox
  vm_id            = 705
  hostname         = "scanopy-daemon"
  description      = "Debian Linux based LXC container running a standalone scanopy-daemon, dual-homed across every VLAN"
  tags             = ["debian", "lxc", "pve-resources"]
  unprivileged     = true
  cpu_cores        = 2
  memory_dedicated = 1024

  network_interfaces = local.network_interfaces
  dns_servers        = local.dns_servers
  dns_search_domain  = local.dns_search_domain

  imagestore_id = "pve-resources"
  startup_order = 5

  # No mount_points - nothing here worth persisting across a rebuild. The
  # daemon just re-registers with the server (a fresh identity) on next boot.
}

# Trigger for container replacement - see modules/pihole/main.tf for why this
# pattern (terraform_data wrapping container_id) is needed on every ssh_resource
# below rather than relying on depends_on alone.
resource "terraform_data" "container_trigger" {
  triggers_replace = module.setup_container.container_id
}

# Set the container timezone
resource "ssh_resource" "configure_timezone" {
  depends_on = [module.setup_container]

  host        = local.container_ip
  user        = "root"
  private_key = module.setup_container.ssh_private_key

  commands = ["timedatectl set-timezone Europe/Berlin"]

  lifecycle {
    replace_triggered_by = [terraform_data.container_trigger.id]
  }

  timeout = "1m"
}

# Install the daemon and register it with the Scanopy server. allow-self-signed-certs
# is needed the same way it was on the native sanctum daemon - the server's cert
# isn't in the daemon's compiled-in (rustls/webpki-roots) trust store; see
# scanopy/scanopy#708 upstream. Left with no --interfaces restriction (default:
# "all interfaces"), so it picks up every one of the five VLAN interfaces above.
#
# Uninstalls any existing registration first (harmless no-op on a fresh
# container) - `scanopy-daemon install` alone only overwrites config.json and
# restarts the same systemd unit, which never tells the *server* the old
# daemon identity is gone. Without this, changing scanopy_daemon_api_key (e.g.
# after an org reset) would silently orphan the previous daemon_id as a
# stale, never-cleaned-up entry in Scanopy's own Daemons list.
resource "ssh_resource" "install_scanopy_daemon" {
  depends_on = [module.setup_container]

  host        = local.container_ip
  user        = "root"
  private_key = module.setup_container.ssh_private_key

  commands = [
    <<-EOT
      set -e
      scanopy-daemon uninstall --all || true
      bash -c "$(curl -fsSL https://raw.githubusercontent.com/scanopy/scanopy/refs/heads/main/install.sh)"
      scanopy-daemon install \
        --server-url ${local.scanopy_server_url} \
        --daemon-api-key ${var.scanopy_daemon_api_key} \
        --name scanopy-daemon-lxc \
        --allow-self-signed-certs true
    EOT
  ]

  lifecycle {
    replace_triggered_by = [terraform_data.container_trigger.id]
  }

  timeout = "5m"
}
