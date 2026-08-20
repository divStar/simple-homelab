/**
 * # Alpine LXC container setup
 *
 * This module creates an Alpine LXC container on the Proxmox host,
 * generates a `root_password` and a `ssh_key`, installs `openssh` as well as
 * other Alpine packages (if specified; `bash` is installed by default).
 */
locals {
  upgrade_alpine_script = "upgrade-alpine.sh"
  update_alpine_script  = "update-alpine.sh"
}

# Downloads the `alpine` image.
resource "proxmox_download_file" "template" {
  content_type       = "vztmpl"
  datastore_id       = var.imagestore_id
  node_name          = var.proxmox.name
  url                = var.alpine_image.url
  checksum           = var.alpine_image.checksum
  checksum_algorithm = var.alpine_image.checksum_algorithm
}

# Generate SSH key for the container
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Generate a random password for the container
resource "random_password" "root_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# Create Alpine LXC container
resource "proxmox_virtual_environment_container" "container" {
  # Wait for the template to be downloaded before creating the container
  depends_on = [proxmox_download_file.template]

  vm_id        = var.vm_id
  node_name    = var.proxmox.name
  description  = var.description
  tags         = var.tags
  unprivileged = var.unprivileged

  timeout_create = 180
  timeout_delete = 180
  timeout_clone  = 180
  timeout_update = 180

  # Container initialization settings
  initialization {
    hostname = var.hostname

    # Network configuration - one ip_config per network_interface, same order
    dynamic "ip_config" {
      for_each = var.network_interfaces
      content {
        ipv4 {
          address = "${ip_config.value.ip}/${ip_config.value.subnet_mask}"
          gateway = ip_config.value.gateway
        }
      }
    }

    # User authentication
    user_account {
      keys = [
        trimspace(tls_private_key.ssh_key.public_key_openssh)
      ]
      password = random_password.root_password.result
    }
  }

  # Network interfaces - order must match the ip_config blocks above (net0, net1, ...)
  dynamic "network_interface" {
    for_each = var.network_interfaces
    content {
      name        = network_interface.value.name
      bridge      = network_interface.value.bridge
      mac_address = network_interface.value.mac_address
      vlan_id     = network_interface.value.vlan_id
    }
  }

  # Operating system - using Alpine template
  operating_system {
    template_file_id = proxmox_download_file.template.id
    type             = "alpine"
  }

  # CPU configuration
  cpu {
    cores = var.cpu_cores
    units = var.cpu_units
  }

  # Memory configuration
  memory {
    dedicated = var.memory_dedicated
    swap      = 0
  }

  # Disk configuration (default)
  disk {
    datastore_id = var.imagestore_id
    size         = var.disk_size
  }

  # Dynamic mount points, passed into this script via variable
  dynamic "mount_point" {
    for_each = var.mount_points
    content {
      volume    = mount_point.value.volume
      path      = mount_point.value.path
      acl       = true
      replicate = false
    }
  }

  # Basic startup configuration
  startup {
    order      = var.startup_order
    up_delay   = var.startup_up_delay
    down_delay = var.startup_down_delay
  }

  features {
    nesting = true
  }
}

# Install OpenSSH into the Alpine LXC container
resource "ssh_resource" "install_openssh" {
  depends_on = [proxmox_virtual_environment_container.container]

  # when = "create"

  # Note: we are connecting to the Proxmox host here rather than the LXC container;
  # this is necessary, because we have to install `openssh` via `pct` from the host.
  host        = var.proxmox.host
  user        = var.proxmox.ssh_user
  private_key = file(var.proxmox.ssh_key)

  # Use a script that checks for OpenSSH and installs it only if needed
  commands = [
    <<-EOT
      if ! pct exec ${var.vm_id} -- which sshd > /dev/null 2>&1; then
        echo "Installing OpenSSH on container ${var.vm_id}..."
        pct exec ${var.vm_id} -- sh -c "apk update && apk upgrade"
        pct exec ${var.vm_id} -- apk add openssh
        pct exec ${var.vm_id} -- rc-update add sshd default
        pct exec ${var.vm_id} -- /etc/init.d/sshd start
        echo "OpenSSH installed and started in container ${var.vm_id}"
      fi
      pct exec ${var.vm_id} -- mkdir -p /root/.ssh
      pct exec ${var.vm_id} -- sh -c "echo '${file("${var.proxmox.ssh_key}.pub")}' >> /root/.ssh/authorized_keys"
      pct exec ${var.vm_id} -- chmod 700 /root/.ssh
      pct exec ${var.vm_id} -- chmod 600 /root/.ssh/authorized_keys
      pct exec ${var.vm_id} -- sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
      pct exec ${var.vm_id} -- sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
      pct exec ${var.vm_id} -- rc-service sshd restart
    EOT
  ]

  # depends_on above is ordering-only and doesn't propagate a container
  # replacement (e.g. a template change forcing `must be replaced`) -- without
  # this, a fresh container would silently never get OpenSSH provisioned.
  # Every ssh_resource below needs its own copy of this, not just this first
  # one in the chain -- replace_triggered_by doesn't cascade through
  # depends_on (same reason modules/samba/main.tf's own trigger has to be
  # applied to every one of its ssh_resources individually).
  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_container.container.id]
  }

  timeout = "1m"
}

resource "ssh_resource" "install_update_upgrade_scripts" {
  depends_on = [ssh_resource.install_openssh]

  # when = "create"

  host        = var.network_interfaces[var.provisioning_interface_index].ip
  user        = "root"
  private_key = tls_private_key.ssh_key.private_key_pem

  # Update script (will run in set intervals)
  file {
    source      = "${path.module}/files/${local.upgrade_alpine_script}"
    destination = "/usr/local/bin/${local.update_alpine_script}"
    permissions = "0755"
  }

  # Upgrade script (should be run manually in case an Alpine upgrade is needed)
  file {
    source      = "${path.module}/files/${local.upgrade_alpine_script}"
    destination = "/usr/local/bin/${local.upgrade_alpine_script}"
    permissions = "0755"
  }

  # Install crontab only if update_interval is not "never"
  commands = var.update_interval != "never" ? ["echo '${var.update_interval} /usr/local/bin/${local.update_alpine_script}' | crontab -"] : []

  # See install_openssh above for why this is needed.
  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_container.container.id]
  }

  timeout = "1m"
}

# Install necessary Alpine packages
resource "ssh_resource" "install_packages" {
  depends_on = [ssh_resource.install_openssh]

  # when = "create"

  host        = var.network_interfaces[var.provisioning_interface_index].ip
  user        = "root"
  private_key = tls_private_key.ssh_key.private_key_pem

  commands = [
    <<-EOT
      set -e
      apk add --no-cache ${join(" ", var.packages)}
      apk update
    EOT
  ]

  # See install_openssh above for why this is needed.
  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_container.container.id]
  }

  timeout = "1m"
}

# Source-based routing for secondary interfaces, via ifupdown-ng's if-up.d/
# if-down.d hooks (confirmed live on this Alpine image; no interfaces.d
# include exists here, so a Debian-style drop-in wouldn't be picked up).
# Also applied immediately, since the interface already came up once before
# these hooks existed to catch that first ifup.
resource "ssh_resource" "configure_response_routes" {
  for_each = { for ni in var.network_interfaces : ni.name => ni if ni.response_route != null }

  depends_on = [ssh_resource.install_openssh]

  host        = var.network_interfaces[var.provisioning_interface_index].ip
  user        = "root"
  private_key = tls_private_key.ssh_key.private_key_pem

  file {
    content = templatefile("${path.module}/files/response-route-up.sh.tftpl", {
      interface      = each.value.name
      source_address = each.value.ip
      gateway        = each.value.response_route.gateway
      table_id       = each.value.response_route.table_id
      priority       = each.value.response_route.priority
    })
    destination = "/etc/network/if-up.d/50-response-route-${each.value.name}"
    permissions = "0755"
  }

  file {
    content = templatefile("${path.module}/files/response-route-down.sh.tftpl", {
      interface      = each.value.name
      source_address = each.value.ip
      table_id       = each.value.response_route.table_id
      priority       = each.value.response_route.priority
    })
    destination = "/etc/network/if-down.d/50-response-route-${each.value.name}"
    permissions = "0755"
  }

  commands = [
    "ip route replace default via ${each.value.response_route.gateway} dev ${each.value.name} table ${each.value.response_route.table_id}",
    "ip rule show | grep -q \"from ${each.value.ip} lookup ${each.value.response_route.table_id}\" || ip rule add from ${each.value.ip} table ${each.value.response_route.table_id} priority ${each.value.response_route.priority}"
  ]

  # See install_openssh above for why this is needed.
  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_container.container.id]
  }

  timeout = "1m"
}

# Cleanup counterpart to configure_response_routes - without this, removing
# a response_route entry later would orphan its hook scripts and ip rule/table.
resource "ssh_resource" "remove_response_routes" {
  for_each = { for ni in var.network_interfaces : ni.name => ni if ni.response_route != null }

  when = "destroy"

  depends_on = [ssh_resource.configure_response_routes]

  host        = var.network_interfaces[var.provisioning_interface_index].ip
  user        = "root"
  private_key = tls_private_key.ssh_key.private_key_pem

  commands = [
    "rm -f /etc/network/if-up.d/50-response-route-${each.value.name} /etc/network/if-down.d/50-response-route-${each.value.name}",
    "ip rule del from ${each.value.ip} table ${each.value.response_route.table_id} priority ${each.value.response_route.priority} 2>/dev/null || true",
    "ip route flush table ${each.value.response_route.table_id} 2>/dev/null || true"
  ]

  timeout = "1m"
}

# Install default aliases
resource "ssh_resource" "install_default_aliases" {
  depends_on = [ssh_resource.install_openssh]

  host        = var.network_interfaces[var.provisioning_interface_index].ip
  user        = "root"
  private_key = tls_private_key.ssh_key.private_key_pem

  file {
    source      = "${path.module}/files/default-aliases.sh"
    destination = "/etc/profile.d/default-aliases.sh"
    permissions = "0644"
  }

  # See install_openssh above for why this is needed.
  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_container.container.id]
  }

  timeout = "1m"
}