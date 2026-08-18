/**
 * # node-exporter
 *
 * Handles exporting host-level metrics (CPU, memory, network interfaces, etc.) every couple of seconds so that e.g. Prometheus can scrape it.
 */
locals {
  # SSH connection settings for reuse
  ssh = {
    host        = var.ssh.host
    user        = var.ssh.user
    private_key = file(var.ssh.id_file)
  }

  # Use provided version or fetch latest
  use_latest_version = var.node_exporter_version == null

  release_data = local.use_latest_version ? jsondecode(data.http.node_exporter_latest[0].response_body) : null

  # Extract version tag - use provided or from API, then strip "v" prefix
  version = trimprefix(local.use_latest_version ? local.release_data.tag_name : var.node_exporter_version, "v")

  # Find the linux-amd64 tar.gz asset
  download_url = local.use_latest_version ? [
    for asset in local.release_data.assets :
    asset.browser_download_url
    if can(regex("linux-amd64\\.tar\\.gz$", asset.name))
  ][0] : "https://github.com/prometheus/node_exporter/releases/download/v${local.version}/node_exporter-${local.version}.linux-amd64.tar.gz"
}

# Determines the latest release of node_exporter
data "http" "node_exporter_latest" {
  count = local.use_latest_version ? 1 : 0

  url = var.node_exporter_github_repository

  request_headers = {
    Accept = "application/vnd.github.v3+json"
  }
}

# Installs node_exporter.
resource "ssh_resource" "install_node_exporter" {
  # when = "create"

  host        = local.ssh.host
  user        = local.ssh.user
  private_key = local.ssh.private_key

  file {
    source      = "${path.module}/files/node-exporter.service"
    destination = "/etc/systemd/system/node-exporter.service"
    permissions = "644"
    owner       = "root"
    group       = "root"
  }

  commands = [
    "curl -L ${local.download_url} -o /tmp/node_exporter-${local.version}.tar.gz",
    "tar -xzf /tmp/node_exporter-${local.version}.tar.gz -C /tmp",
    "cp /tmp/node_exporter-${local.version}.linux-amd64/node_exporter /usr/local/bin/",
    "chmod +x /usr/local/bin/node_exporter",
    "systemctl daemon-reload",
    "systemctl enable node-exporter",
    "systemctl start node-exporter",
    "sleep 5",
    "curl -s http://localhost:9100/metrics | grep node_network_speed_bytes"
  ]

  timeout = "60s"
}

# Uninstalls node_exporter.
resource "ssh_resource" "uninstall_node_exporter" {
  when = "destroy"

  host        = local.ssh.host
  user        = local.ssh.user
  private_key = local.ssh.private_key

  commands = [
    "systemctl stop node-exporter || true",
    "systemctl disable node-exporter || true",
    "rm -f /usr/local/bin/node_exporter",
    "rm -f /etc/systemd/system/node-exporter.service",
    "systemctl daemon-reload",
    "rm -rf /tmp/node_exporter-*"
  ]
}
