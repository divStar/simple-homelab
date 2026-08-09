output "storage_id" {
  description = "The PVE storage id the PBS datastore was registered under"
  value       = proxmox_storage_pbs.this.id
}

output "job_ids" {
  description = "Map of guest name => the backup job id created for it"
  value       = { for name, job in proxmox_backup_job.this : name => job.id }
}
