output "storage_id" {
  description = "The PVE storage id the PBS datastore was registered under"
  value       = proxmox_storage_pbs.this.id
}

output "job_ids" {
  description = "Map of guest name => the backup job id created for it"
  value       = { for name, job in proxmox_backup_job.this : name => job.id }
}

output "folder_backups" {
  description = "Map of folder name => { namespace, schedule, prune_backups, has_exec_start_pre }"
  value = {
    for name, folder in var.folders : name => {
      namespace          = name # always the map key
      schedule           = folder.schedule
      prune_backups      = folder.prune_backups
      has_exec_start_pre = folder.exec_start_pre != null
    }
  }
}

output "verify_jobs" {
  description = "PBS verify jobs - one per namespace (key \"root\" = all VM/CT backups, other keys = folder namespaces)"
  value = {
    for key, job in local.verify_jobs : key => {
      id       = job.id
      schedule = job.schedule
    }
  }
}

output "gc_schedule" {
  description = "PBS datastore garbage collection schedule"
  value       = var.gc_schedule
}
