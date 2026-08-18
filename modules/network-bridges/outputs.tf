output "bridges" {
  description = "Linux bridges created on the Proxmox host, keyed by name"
  value = {
    for name, bridge in proxmox_network_linux_bridge.this : name => {
      id   = bridge.id
      name = bridge.name
    }
  }
}
