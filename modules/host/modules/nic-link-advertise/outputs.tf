output "nic_link_advertise" {
  description = "Interfaces that had a persistent ethtool advertise drop-in applied, and which modes"
  value       = local.nic_link_advertise
}
