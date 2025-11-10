output "networks" {
  description = "Networks in Docker"
  value = {
    for name, network in docker_network.this : name => {
      name    = network.name
      id      = network.id
      scope   = network.scope
      subnet  = one(network.ipam_config).subnet
      gateway = one(network.ipam_config).gateway
      driver  = network.driver
      labels  = { for label in network.labels : label.label => label.value }
    }
  }
}

output "volumes" {
  description = "Volumes in Docker"
  value = {
    for name, volume in docker_volume.this : name => {
      name        = volume.name
      mountpoint  = volume.mountpoint
      driver      = volume.driver
      driver_opts = volume.driver_opts
      labels      = { for label in volume.labels : label.label => label.value }
    }
  }
}
