output "node_exporter_version" {
  description = "Version of `node_exporter`, that was installed"
  value       = local.version
}

output "textfile_directory" {
  description = "Directory the textfile collector reads `*.prom` files from"
  value       = var.textfile_directory
}
