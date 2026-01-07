/**
 * # Step-CA Setup
 *
 * This module sets up Step-CA in an Alpine LXC container using the provided information.
 */
locals {
  proxmox_endpoint = "https://${var.proxmox.host}:8006"

  container_ip = "192.168.178.155"

  timestamp            = "+%Y-%m-%d-%H-%M-%S"
  setup_host_script    = "setup-host.sh"
  teardown_host_script = "teardown-host.sh"
}

# Alpine LXC container setup
module "setup_container" {
  source = "../common/modules/alpine"

  proxmox      = var.proxmox
  vm_id        = 701
  hostname     = "step-ca"
  description  = "Alpine Linux based LXC container with Step-CA"
  tags         = ["alpine", "lxc", "pve-resources"]
  unprivileged = true

  ni_mac_address = "EA:31:0E:A5:D8:4C"
  ni_ip          = local.container_ip
  ni_gateway     = "192.168.178.1"
  ni_subnet_mask = 24
  ni_name        = "eth0"
  ni_bridge      = "vmbr0"

  imagestore_id = "pve-resources"
  startup_order = 1
  mount_points = [
    { volume = "/mnt/temp/step-ca", path = "/etc/step-ca" }
  ]
  packages = ["bash", "curl", "ca-certificates", "step-cli", "step-certificates"]
}

# Configure Step-CA
resource "ssh_resource" "configure_container" {
  # when = "create"

  depends_on = [module.setup_container]

  host        = local.container_ip
  user        = "root"
  private_key = module.setup_container.ssh_private_key

  commands = flatten([
    [
      "rc-service step-ca start",
      "rc-update add step-ca default",
      "sleep 10"
    ],
    [
      "step ca bootstrap --ca-url https://${local.container_ip} --fingerprint $(echo \"${file(var.fingerprint_file)}\") --install --force"
    ]
  ])

  timeout = "1m"
}

# Configure ACME domain and order certificates
resource "ssh_resource" "configure_host" {
  # when = "create"
  depends_on = [ssh_resource.configure_container]

  # Note: connecting to Proxmox host here
  host        = var.proxmox.host
  user        = var.proxmox.ssh_user
  private_key = file(var.proxmox.ssh_key)

  file {
    source      = "${path.module}/files/${local.setup_host_script}"
    destination = "/tmp/${local.setup_host_script}"
    permissions = "0755"
  }

  file {
    source      = "${path.module}/files/${local.teardown_host_script}"
    destination = "/tmp/${local.teardown_host_script}"
    permissions = "0755"
  }

  commands = flatten([
    [
      join(" ", [
        "/tmp/${local.setup_host_script}",
        "--step-server ${local.container_ip}",
        "--proxmox-node-name ${var.proxmox.name}",
        "--fingerprint ${file(var.fingerprint_file)}",
        "--acme-name ${var.acme.name}",
        "--acme-contact ${var.acme.contact}",
        "--acme-domains \"${join(";", var.acme.proxmox_domains)}\"",
        "--log-file /tmp/${local.setup_host_script}.$(date ${local.timestamp}).log"
      ])
    ]
  ])

  timeout = "2m"
}

# ACME Cleanup on destroy
resource "ssh_resource" "revert_host" {
  when = "destroy"

  depends_on = [
    ssh_resource.configure_host,
    ssh_resource.configure_container
  ]

  # Note: connecting to Proxmox host here
  host        = var.proxmox.host
  user        = var.proxmox.ssh_user
  private_key = file(var.proxmox.ssh_key)

  commands = flatten([
    [
      join(" ", [
        "/tmp/${local.teardown_host_script}",
        "--proxmox-node-name ${var.proxmox.name}",
        "--acme-name ${var.acme.name}",
        "--log-file /tmp/${local.teardown_host_script}.$(date ${local.timestamp}).log"
      ])
    ],
    [
      "rm -f /tmp/${local.setup_host_script} /tmp/${local.teardown_host_script}"
    ]
  ])

  timeout = "1m"
}