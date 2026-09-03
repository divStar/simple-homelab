/**
 * # Step-CA Setup
 *
 * This module sets up Step-CA in an Alpine LXC container using the provided information.
 *
 * <!-- docs-meta: order=30 icon=step-ca -->
 */
locals {
  proxmox_endpoint = "https://${var.proxmox.host}:8006"

  network_interfaces = [
    {
      name        = "eth0"
      bridge      = "vmbr1"
      mac_address = "EA:31:0E:A5:D8:4F"
      ip          = "10.0.5.4"
      subnet_mask = 24
      vlan_id     = 5
      gateway     = "10.0.5.1"
    }
  ]

  container_ip = local.network_interfaces[0].ip

  dns_servers       = ["10.0.5.1"]
  dns_search_domain = "my.world"

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

  network_interfaces = local.network_interfaces
  dns_servers        = local.dns_servers
  dns_search_domain  = local.dns_search_domain

  imagestore_id = "pve-resources"
  startup_order = 1
  mount_points = [
    { volume = "/mnt/storage/step-ca", path = "/etc/step-ca" }
  ]
  packages = ["bash", "curl", "ca-certificates", "step-cli", "step-certificates"]
}

# Wraps container_id into a valid replace_triggered_by target (module outputs
# alone aren't). Only configure_container needs it - configure_host/revert_host
# hit the Proxmox host, not the container.
resource "terraform_data" "container_trigger" {
  triggers_replace = module.setup_container.container_id
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
      # 127.0.0.1, not local.container_ip - this runs inside the ssh session
      # already on the container itself, so it doesn't need an externally
      # reachable address (and 127.0.0.1 is always in the server cert's SANs).
      "step ca bootstrap --ca-url https://127.0.0.1 --fingerprint $(echo \"${file(var.fingerprint_file)}\") --install --force"
    ]
  ])

  lifecycle {
    replace_triggered_by = [terraform_data.container_trigger.id]
  }

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