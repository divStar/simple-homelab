/**
 * # share-permissions
 *
 * Runs a daily systemd timer that adds missing group permissions (dirs: `g+rwxs`, files: `g+rw`) on the host paths backing
 * the Samba shares. Anything written by a root process on the host or through `virtiofs` (restores, rsync without `-p`,
 * containers running as root) otherwise lands with root's umask `022` and can't be moved or deleted by share users.
 *
 * Only ever adds bits, never removes them or changes owners. Changed entries are printed to the journal
 * (`journalctl -u share-permissions`). With `textfile_directory` set, per-share counts
 * (`share_permissions_fixed_entries{path, type}`) and `share_permissions_last_run_timestamp_seconds` are exposed via
 * node_exporter's textfile collector.
 */
locals {
  # SSH connection settings for reuse
  ssh = {
    host        = var.ssh.host
    user        = var.ssh.user
    private_key = file(var.ssh.id_file)
  }
}

# `file { source }` content isn't diffed by the ssh provider - this forces a re-push whenever a file or the config changes.
resource "terraform_data" "share_permissions_trigger" {
  triggers_replace = {
    script             = filesha256("${path.module}/files/share-permissions.sh")
    service            = filesha256("${path.module}/files/share-permissions.service.tftpl")
    timer              = filesha256("${path.module}/files/share-permissions.timer.tftpl")
    config             = var.share_permissions
    textfile_directory = var.textfile_directory
  }
}

# Installs the script, its config and the systemd service + timer.
resource "ssh_resource" "install_share_permissions" {
  host        = local.ssh.host
  user        = local.ssh.user
  private_key = local.ssh.private_key

  file {
    source      = "${path.module}/files/share-permissions.sh"
    destination = "/usr/local/bin/share-permissions.sh"
    permissions = "0755"
    owner       = "root"
    group       = "root"
  }

  file {
    content     = join("\n", var.share_permissions.paths)
    destination = "/etc/share-permissions.paths"
    permissions = "0644"
    owner       = "root"
    group       = "root"
  }

  file {
    content     = join("\n", var.share_permissions.exclude_paths)
    destination = "/etc/share-permissions.excludes"
    permissions = "0644"
    owner       = "root"
    group       = "root"
  }

  file {
    content     = templatefile("${path.module}/files/share-permissions.service.tftpl", { textfile_directory = var.textfile_directory })
    destination = "/etc/systemd/system/share-permissions.service"
    permissions = "0644"
    owner       = "root"
    group       = "root"
  }

  file {
    content     = templatefile("${path.module}/files/share-permissions.timer.tftpl", { schedule = var.share_permissions.schedule })
    destination = "/etc/systemd/system/share-permissions.timer"
    permissions = "0644"
    owner       = "root"
    group       = "root"
  }

  commands = [
    "systemctl daemon-reload",
    "systemctl enable --now share-permissions.timer",
    "systemctl list-timers share-permissions.timer --no-pager"
  ]

  lifecycle {
    replace_triggered_by = [terraform_data.share_permissions_trigger]
  }
}

# Uninstalls everything again.
resource "ssh_resource" "uninstall_share_permissions" {
  when = "destroy"

  host        = local.ssh.host
  user        = local.ssh.user
  private_key = local.ssh.private_key

  commands = [
    "systemctl disable --now share-permissions.timer || true",
    "rm -f /etc/systemd/system/share-permissions.timer /etc/systemd/system/share-permissions.service",
    "rm -f /usr/local/bin/share-permissions.sh /etc/share-permissions.paths /etc/share-permissions.excludes",
    "systemctl daemon-reload"
  ]
}
