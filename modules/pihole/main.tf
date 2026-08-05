/**
 * # Pi-hole Setup
 *
 * This module sets up Pi-hole in a Debian LXC container using the provided information.
 */

locals {
  proxmox_endpoint = "https://${var.proxmox.host}:8006"

  container_ip = "192.168.178.157"
}

# Debian LXC container setup
module "setup_container" {
  source = "../common/modules/debian"

  proxmox          = var.proxmox
  vm_id            = 703
  hostname         = "pihole"
  description      = "Debian Linux based LXC container with Pi-hole"
  tags             = ["debian", "lxc", "pve-resources"]
  unprivileged     = true
  cpu_cores        = 2
  memory_dedicated = 4096

  ni_mac_address = "EA:31:0E:A5:D8:4E"
  ni_ip          = local.container_ip
  ni_gateway     = "192.168.178.1"
  ni_subnet_mask = 24
  ni_name        = "eth0"
  ni_bridge      = "vmbr0"

  imagestore_id = "pve-resources"
  startup_order = 3
}

# Trigger for container replacement - module outputs aren't valid
# replace_triggered_by references on their own (only resources are), hence
# wrapping it in a terraform_data resource. Every ssh_resource below needs
# this in its own lifecycle block (not just the ones depending directly on
# module.setup_container) - replace_triggered_by doesn't cascade through
# depends_on chains, and pihole has no mount_points at all, so a container
# replace means every one of these needs to genuinely re-run, not just the
# first resource in the chain.
resource "terraform_data" "container_trigger" {
  input = module.setup_container.container_id
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

# Ensure /etc/pihole exists before the certificate and seed config are pushed into it
resource "ssh_resource" "create_pihole_directory" {
  depends_on = [module.setup_container]

  host        = local.container_ip
  user        = "root"
  private_key = module.setup_container.ssh_private_key

  commands = ["mkdir -p /etc/pihole"]

  lifecycle {
    replace_triggered_by = [terraform_data.container_trigger.id]
  }

  timeout = "1m"
}

# Install the step CLI and bootstrap trust in Step CA, so Pi-hole's own
# webserver can get a real certificate instead of depending on Traefik
resource "ssh_resource" "install_step_cli" {
  depends_on = [module.setup_container]

  host        = local.container_ip
  user        = "root"
  private_key = module.setup_container.ssh_private_key

  file {
    source      = "${path.module}/files/install-step.sh"
    destination = "/usr/local/bin/install-step.sh"
    permissions = "0755"
  }

  commands = ["/usr/local/bin/install-step.sh ${var.step_ca_domain} ${var.step_ca_client_version}"]

  lifecycle {
    replace_triggered_by = [terraform_data.container_trigger.id]
  }

  timeout = "2m"
}

# Store the provisioner password in a file rather than passing it as a raw
# CLI argument (keeps it out of the process list / shell history)
resource "ssh_resource" "configure_provisioner_password" {
  depends_on = [module.setup_container]

  host        = local.container_ip
  user        = "root"
  private_key = module.setup_container.ssh_private_key

  commands = [
    "mkdir -p /root/.step && echo -n '${var.step_ca_provisioner_password}' > /root/.step/provisioner-password && chmod 600 /root/.step/provisioner-password"
  ]

  lifecycle {
    replace_triggered_by = [terraform_data.container_trigger.id]
  }

  timeout = "1m"
}

# Request the certificate for Pi-hole's webserver *before* Pi-hole itself is
# installed, so the seeded pihole.toml below can declare HTTPS-only from the
# start instead of ever falling back to plain HTTP.
resource "ssh_resource" "request_pihole_certificate" {
  depends_on = [ssh_resource.install_step_cli, ssh_resource.configure_provisioner_password, ssh_resource.create_pihole_directory]

  host        = local.container_ip
  user        = "root"
  private_key = module.setup_container.ssh_private_key

  file {
    source      = "${path.module}/files/pihole-cert.sh"
    destination = "/usr/local/bin/pihole-cert.sh"
    permissions = "0755"
  }

  commands = [
    "/usr/local/bin/pihole-cert.sh ${var.step_ca_domain} ${var.step_ca_provisioner} /root/.step/provisioner-password pihole pihole.my.world ${local.container_ip}"
  ]

  lifecycle {
    replace_triggered_by = [terraform_data.container_trigger.id]
  }

  timeout = "1m"
}

# Push the seed pihole.toml. This is a one-time bootstrap so the unattended
# installer below has a config to work with - Pi-hole's own UI/API is the
# source of truth for everything in it afterward.
resource "ssh_resource" "seed_pihole_config" {
  depends_on = [ssh_resource.create_pihole_directory]

  host        = local.container_ip
  user        = "root"
  private_key = module.setup_container.ssh_private_key

  file {
    source      = "${path.module}/files/pihole.toml"
    destination = "/etc/pihole/pihole.toml"
    permissions = "0644"
  }

  lifecycle {
    replace_triggered_by = [terraform_data.container_trigger.id]
  }

  timeout = "1m"
}

# Run the official Pi-hole installer, unattended. The pre-seeded pihole.toml
# above is what makes --unattended actually skip prompts, and since the
# certificate already exists by this point, Pi-hole comes up HTTPS-only from
# the very first start.
resource "ssh_resource" "install_pihole" {
  depends_on = [ssh_resource.request_pihole_certificate, ssh_resource.seed_pihole_config]

  host        = local.container_ip
  user        = "root"
  private_key = module.setup_container.ssh_private_key

  commands = [
    "export PIHOLE_SKIP_OS_CHECK=true && curl -sSL https://install.pi-hole.net | bash -s -- --unattended"
  ]

  lifecycle {
    replace_triggered_by = [terraform_data.container_trigger.id]
  }

  timeout = "5m"
}

# Set the admin password via the CLI so it gets hashed correctly
resource "ssh_resource" "configure_admin_password" {
  depends_on = [ssh_resource.install_pihole]

  host        = local.container_ip
  user        = "root"
  private_key = module.setup_container.ssh_private_key

  commands = ["pihole setpassword '${var.pihole_admin_password}'"]

  lifecycle {
    replace_triggered_by = [terraform_data.container_trigger.id]
  }

  timeout = "1m"
}

# One-time resource: the installer sets up cron and its own weekly gravity
# update job (/etc/cron.d/pihole), but apparently doesn't run gravity itself
# during an unattended install (yet?) - without this, Pi-hole is up and
# resolving but not actually blocking anything until that cron job first
# fires on its own, up to a week later.
resource "ssh_resource" "run_gravity_update" {
  depends_on = [ssh_resource.install_pihole]

  host        = local.container_ip
  user        = "root"
  private_key = module.setup_container.ssh_private_key

  commands = ["pihole -g"]

  lifecycle {
    replace_triggered_by = [terraform_data.container_trigger.id]
  }

  timeout = "2m"
}

# Upstream DNS servers - the one setting Terraform keeps managing after first boot
resource "ssh_resource" "configure_upstream_dns" {
  depends_on = [ssh_resource.install_pihole]

  host        = local.container_ip
  user        = "root"
  private_key = module.setup_container.ssh_private_key

  commands = ["pihole-FTL --config dns.upstreams '${jsonencode(var.upstream_dns)}'"]

  lifecycle {
    replace_triggered_by = [terraform_data.container_trigger.id]
  }

  timeout = "1m"
}

# Renew the certificate every 12 hours - Step CA issues 24h-lived certs, same
# cadence docker-vm already uses for the same reason. Doesn't need to wait for
# Pi-hole to be installed - only for pihole-cert.sh to already be on disk.
resource "ssh_resource" "configure_cert_renewal_timer" {
  depends_on = [ssh_resource.request_pihole_certificate]

  host        = local.container_ip
  user        = "root"
  private_key = module.setup_container.ssh_private_key

  commands = [
    <<-EOT
      cat > /etc/systemd/system/pihole-cert.service <<'SERVICE_UNIT'
      [Unit]
      Description=Renew Pi-hole webserver TLS certificate from Step CA

      [Service]
      Type=oneshot
      ExecStart=/usr/local/bin/pihole-cert.sh ${var.step_ca_domain} ${var.step_ca_provisioner} /root/.step/provisioner-password pihole pihole.my.world ${local.container_ip}
      SERVICE_UNIT
      cat > /etc/systemd/system/pihole-cert.timer <<'TIMER_UNIT'
      [Unit]
      Description=Renew Pi-hole webserver TLS certificate every 12 hours

      [Timer]
      OnBootSec=5s
      OnUnitActiveSec=12h
      Persistent=true

      [Install]
      WantedBy=timers.target
      TIMER_UNIT
      systemctl daemon-reload
      systemctl enable --now pihole-cert.timer
    EOT
  ]

  lifecycle {
    replace_triggered_by = [terraform_data.container_trigger.id]
  }

  timeout = "1m"
}

# Update Pi-hole's own software (Core/FTL/Web) weekly, Sunday 6am - an hour
# after the Debian package update timer so the two don't run at the same time.
resource "ssh_resource" "configure_pihole_update_timer" {
  depends_on = [ssh_resource.install_pihole]

  host        = local.container_ip
  user        = "root"
  private_key = module.setup_container.ssh_private_key

  file {
    source      = "${path.module}/files/pihole-update.sh"
    destination = "/usr/local/bin/pihole-update.sh"
    permissions = "0755"
  }

  commands = [
    <<-EOT
      cat > /etc/systemd/system/pihole-update.service <<'SERVICE_UNIT'
      [Unit]
      Description=Update Pi-hole software (managed by Terraform)

      [Service]
      Type=oneshot
      ExecStart=/usr/local/bin/pihole-update.sh
      SERVICE_UNIT
      cat > /etc/systemd/system/pihole-update.timer <<'TIMER_UNIT'
      [Unit]
      Description=Run pihole-update.service on a schedule (managed by Terraform)

      [Timer]
      OnCalendar=Sun *-*-* 06:00:00
      Persistent=true

      [Install]
      WantedBy=timers.target
      TIMER_UNIT
      systemctl daemon-reload
      systemctl enable --now pihole-update.timer
    EOT
  ]

  lifecycle {
    replace_triggered_by = [terraform_data.container_trigger.id]
  }

  timeout = "1m"
}
