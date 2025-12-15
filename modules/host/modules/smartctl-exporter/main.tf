/**
 * # smartctl-exporter
 *
 * Handles exporting `smartctl` information every couple of seconds so that e.g. Prometheus can scrape it.
 */
locals {
  # SSH connection settings for reuse
  ssh = {
    host        = var.ssh.host
    user        = var.ssh.user
    private_key = file(var.ssh.id_file)
  }

  # Use provided version or fetch latest
  use_latest_version = var.smartctl_exporter_version == null

  release_data = local.use_latest_version ? jsondecode(data.http.smartctl_exporter_latest[0].response_body) : null

  # Extract version tag - use provided or from API, then strip "v" prefix
  version = trimprefix(local.use_latest_version ? local.release_data.tag_name : var.smartctl_exporter_version, "v")

  # Find the linux-amd64 tar.gz asset
  download_url = local.use_latest_version ? [
    for asset in local.release_data.assets :
    asset.browser_download_url
    if can(regex("linux-amd64\\.tar\\.gz$", asset.name))
  ][0] : "https://github.com/prometheus-community/smartctl_exporter/releases/download/v${local.version}/smartctl_exporter-${local.version}.linux-amd64.tar.gz"
}

# Determines the latest release of the smartctl-exporter
data "http" "smartctl_exporter_latest" {
  count = local.use_latest_version ? 1 : 0

  url = var.smartctl_exporter_github_repository

  request_headers = {
    Accept = "application/vnd.github.v3+json"
  }
}

# Installs the smartctl-exporter.
resource "ssh_resource" "install_smartctl_exporter" {
  # when = "create"

  host        = local.ssh.host
  user        = local.ssh.user
  private_key = local.ssh.private_key

  file {
    source      = "${path.module}/files/smartctl-exporter.service"
    destination = "/etc/systemd/system/smartctl-exporter.service"
    permissions = "644"
    owner       = "root"
    group       = "root"
  }

  commands = [
    "curl -L ${local.download_url} -o /tmp/smartctl_exporter-${local.version}.tar.gz",
    "tar -xzf /tmp/smartctl_exporter-${local.version}.tar.gz -C /tmp",
    "cp /tmp/smartctl_exporter-${local.version}.linux-amd64/smartctl_exporter /usr/local/bin/",
    "chmod +x /usr/local/bin/smartctl_exporter",
    "systemctl daemon-reload",
    "systemctl enable smartctl-exporter",
    "systemctl start smartctl-exporter",
    "sleep 5",
    "curl -s http://localhost:9633/metrics | grep smartctl"
  ]

  timeout = "60s"
}

# Uninstalls the smartctl-exporter.
resource "ssh_resource" "uninstall_smartctl_exporter" {
  when = "destroy"

  host        = local.ssh.host
  user        = local.ssh.user
  private_key = local.ssh.private_key

  commands = [
    "systemctl stop smartctl-exporter || true",
    "systemctl disable smartctl-exporter || true",
    "rm -f /usr/local/bin/smartctl_exporter",
    "rm -f /etc/systemd/system/smartctl-exporter.service",
    "systemctl daemon-reload",
    "rm -rf /tmp/smartctl_exporter-*"
  ]
}