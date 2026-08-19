output "nic_link_advertise" {
  description = "Interfaces that had a persistent ethtool advertise drop-in applied, and which modes"
  value       = local.nic_link_advertise
}

output "response_routes" {
  description = "Interfaces that had a persistent source-routing drop-in applied, and via which gateway/table"
  value = {
    for route in var.response_routes : route.interface => {
      source_address = route.source_address
      gateway        = route.gateway
      table_name     = route.table_name
    }
  }
}
