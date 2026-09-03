/**
 * # Debian LXC container setup
 *
 * This module creates a Debian LXC container on the Proxmox host,
 * generates a `root_password` and a `ssh_key`, installs `openssh` as well as
 * other Debian packages (if specified; `bash`, `curl`, `ca-certificates` and
 * `cron` are installed by default).
 */
locals {
  upgrade_debian_script = "upgrade-debian.sh"
  update_debian_script  = "update-debian.sh"

  # cidrhost(ip/mask, 0) masks a non-network-aligned host address down to its
  # network address (verified live: cidrhost("10.0.5.4/24", 0) => "10.0.5.0") -
  # the kernel itself rejects a route add with unmasked host bits outright
  # ("Error: Invalid prefix for given prefix length."), so this can't be skipped.
  response_route_subnets = {
    for ni in var.network_interfaces :
    ni.name => "${cidrhost("${ni.ip}/${ni.subnet_mask}", 0)}/${ni.subnet_mask}"
    if ni.response_route != null
  }
}

# Downloads the `debian` image.
resource "proxmox_download_file" "template" {
  content_type       = "vztmpl"
  datastore_id       = var.imagestore_id
  node_name          = var.proxmox.name
  url                = var.debian_image.url
  checksum           = var.debian_image.checksum
  checksum_algorithm = var.debian_image.checksum_algorithm
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

# Create Debian LXC container
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

    # DNS - only set if the caller actually specified something, otherwise
    # let Proxmox's own default stand rather than forcing an opinion on it.
    dynamic "dns" {
      for_each = var.dns_servers != null ? [1] : []
      content {
        servers = var.dns_servers
        domain  = var.dns_search_domain
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

  # Operating system - using Debian template
  operating_system {
    template_file_id = proxmox_download_file.template.id
    type             = "debian"
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

# Install OpenSSH into the Debian LXC container
resource "ssh_resource" "install_openssh" {
  depends_on = [proxmox_virtual_environment_container.container]

  # Note: we are connecting to the Proxmox host here rather than the LXC container;
  # this is necessary, because we have to install `openssh-server` via `pct` from the host.
  host        = var.proxmox.host
  user        = var.proxmox.ssh_user
  private_key = file(var.proxmox.ssh_key)

  # Use a script that checks for OpenSSH and installs it only if needed
  commands = [
    <<-EOT
      if ! pct exec ${var.vm_id} -- which sshd > /dev/null 2>&1; then
        echo "Installing OpenSSH on container ${var.vm_id}..."
        pct exec ${var.vm_id} -- sh -c "DEBIAN_FRONTEND=noninteractive apt-get update"
        pct exec ${var.vm_id} -- sh -c "DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server"
        pct exec ${var.vm_id} -- systemctl enable ssh
        pct exec ${var.vm_id} -- systemctl start ssh
        echo "OpenSSH installed and started in container ${var.vm_id}"
      fi
      pct exec ${var.vm_id} -- mkdir -p /root/.ssh
      pct exec ${var.vm_id} -- sh -c "echo '${file("${var.proxmox.ssh_key}.pub")}' >> /root/.ssh/authorized_keys"
      pct exec ${var.vm_id} -- chmod 700 /root/.ssh
      pct exec ${var.vm_id} -- chmod 600 /root/.ssh/authorized_keys
      pct exec ${var.vm_id} -- sed -i -E 's/^#?\s*PasswordAuthentication\s+.*/PasswordAuthentication no/' /etc/ssh/sshd_config
      pct exec ${var.vm_id} -- sed -i -E 's/^#?\s*PubkeyAuthentication\s+.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
      pct exec ${var.vm_id} -- systemctl restart ssh
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

# Install necessary Debian packages (includes cron, needed for the update schedule below)
resource "ssh_resource" "install_packages" {
  depends_on = [ssh_resource.install_openssh]

  host        = var.network_interfaces[var.provisioning_interface_index].ip
  user        = "root"
  private_key = tls_private_key.ssh_key.private_key_pem

  commands = [
    <<-EOT
      set -e
      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y ${join(" ", var.packages)}
    EOT
  ]

  # See install_openssh above for why this is needed.
  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_container.container.id]
  }

  timeout = "1m"
}

resource "ssh_resource" "install_update_upgrade_scripts" {
  depends_on = [ssh_resource.install_openssh]

  host        = var.network_interfaces[var.provisioning_interface_index].ip
  user        = "root"
  private_key = tls_private_key.ssh_key.private_key_pem

  # Update script (will run in set intervals)
  file {
    source      = "${path.module}/files/${local.update_debian_script}"
    destination = "/usr/local/bin/${local.update_debian_script}"
    permissions = "0755"
  }

  # Upgrade script (should be run manually in case a Debian major-version upgrade is needed)
  file {
    source      = "${path.module}/files/${local.upgrade_debian_script}"
    destination = "/usr/local/bin/${local.upgrade_debian_script}"
    permissions = "0755"
  }

  # Install and enable a systemd timer only if update_interval is not "never"
  commands = var.update_interval != "never" ? [
    <<-EOT
      cat > /etc/systemd/system/debian-update.service <<'SERVICE_UNIT'
      [Unit]
      Description=Debian package update (managed by Terraform)

      [Service]
      Type=oneshot
      ExecStart=/usr/local/bin/${local.update_debian_script}
      SERVICE_UNIT
      cat > /etc/systemd/system/debian-update.timer <<'TIMER_UNIT'
      [Unit]
      Description=Run debian-update.service on a schedule (managed by Terraform)

      [Timer]
      OnCalendar=${var.update_interval}
      Persistent=true

      [Install]
      WantedBy=timers.target
      TIMER_UNIT
      systemctl daemon-reload
      systemctl enable --now debian-update.timer
    EOT
  ] : []

  # See install_openssh above for why this is needed.
  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_container.container.id]
  }

  timeout = "1m"
}

# Disable Debian's own default apt-daily.timer/apt-daily-upgrade.timer. Confirmed
# via live inspection (2026-08-09, pbs-lxc) that on this image, with no
# /etc/apt/apt.conf.d/20auto-upgrades or 10periodic present (the stock state),
# apt.systemd.daily's own stamp-check logic already makes both timers pure
# no-ops -- every APT::Periodic::* interval it checks defaults to 0 when unset,
# so nothing they'd otherwise do (index refresh, unattended-upgrade) ever
# actually runs. Disabling them costs nothing functionally; it just removes two
# enabled-but-inert timers cluttering `systemctl list-timers` and the confusion
# of two update-shaped timers next to debian-update.timer above, which is the
# one that actually performs upgrades.
resource "ssh_resource" "disable_default_apt_timers" {
  depends_on = [ssh_resource.install_openssh]

  host        = var.network_interfaces[var.provisioning_interface_index].ip
  user        = "root"
  private_key = tls_private_key.ssh_key.private_key_pem

  commands = [
    "systemctl disable --now apt-daily.timer apt-daily-upgrade.timer",
  ]

  # See install_openssh above for why this is needed.
  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_container.container.id]
  }

  timeout = "1m"
}

# ifupdown2's own package ships /etc/network/interfaces.d/ (confirmed via
# `dpkg -L ifupdown2`) - the same convention Proxmox's own host network config
# already relies on - but a container's auto-generated interfaces file doesn't
# source it by default (unlike the PVE host's, which gets `source
# /etc/network/interfaces.d/*` appended automatically by Proxmox's own host
# network generator - a host-specific behavior, not a general ifupdown2
# default), so it needs enabling once before any drop-in gets pushed into it.
resource "ssh_resource" "enable_interfaces_d_sourcing" {
  count = length([for ni in var.network_interfaces : ni if ni.response_route != null]) > 0 ? 1 : 0

  depends_on = [ssh_resource.install_openssh]

  host        = var.network_interfaces[var.provisioning_interface_index].ip
  user        = "root"
  private_key = tls_private_key.ssh_key.private_key_pem

  commands = [
    "mkdir -p /etc/network/interfaces.d",
    "grep -qx 'source /etc/network/interfaces.d/*' /etc/network/interfaces || echo 'source /etc/network/interfaces.d/*' >> /etc/network/interfaces"
  ]

  # See install_openssh above for why this is needed.
  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_container.container.id]
  }

  timeout = "1m"
}

# Source-based routing for secondary interfaces, via an /etc/network/interfaces.d/
# drop-in - the same mechanism modules/host's response-route already uses
# successfully (ifupdown2 merges a sourced same-name `iface` stanza with the
# interface's main declaration elsewhere in /etc/network/interfaces). `ifreload
# -a` reapplies it immediately, since the interface already came up once before
# this drop-in existed to catch that first ifup.
resource "ssh_resource" "configure_response_routes" {
  for_each = { for ni in var.network_interfaces : ni.name => ni if ni.response_route != null }

  depends_on = [ssh_resource.enable_interfaces_d_sourcing]

  host        = var.network_interfaces[var.provisioning_interface_index].ip
  user        = "root"
  private_key = tls_private_key.ssh_key.private_key_pem

  file {
    content = templatefile("${path.module}/files/response-route.tftpl", {
      interface      = each.value.name
      source_address = each.value.ip
      local_subnet   = local.response_route_subnets[each.key]
      gateway        = each.value.response_route.gateway
      table_id       = each.value.response_route.table_id
      priority       = each.value.response_route.priority
    })
    destination = "/etc/network/interfaces.d/response-route-${each.value.name}"
    permissions = "0644"
  }

  commands = [
    # /etc/iproute2/ doesn't exist by default on this image either (confirmed
    # live: writing to rt_tables fails outright without it, despite iproute2
    # being installed as an ifupdown2 dependency) - create it defensively.
    "mkdir -p /etc/iproute2",
    "grep -q '^${each.value.response_route.table_id} ${each.value.response_route.table_name}$' /etc/iproute2/rt_tables || echo '${each.value.response_route.table_id} ${each.value.response_route.table_name}' >> /etc/iproute2/rt_tables",
    "ifreload -a"
  ]

  # See install_openssh above for why this is needed.
  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_container.container.id]
  }

  timeout = "1m"
}

# Cleanup counterpart to configure_response_routes - without this, removing
# a response_route entry later would orphan its drop-in and ip rule/table.
resource "ssh_resource" "remove_response_routes" {
  for_each = { for ni in var.network_interfaces : ni.name => ni if ni.response_route != null }

  when = "destroy"

  depends_on = [ssh_resource.configure_response_routes]

  host        = var.network_interfaces[var.provisioning_interface_index].ip
  user        = "root"
  private_key = tls_private_key.ssh_key.private_key_pem

  commands = [
    "rm -f /etc/network/interfaces.d/response-route-${each.value.name}",
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
