# mdadm RAID Array Reimport Guide

## Context

After a catastrophic host failure and OS reinstall (Proxmox VE 9), existing mdadm RAID arrays need to be manually reassembled since Proxmox doesn't include mdadm by default.

## Why Reassembly is Required

- **Array metadata persists on disks**: Each disk stores RAID configuration metadata
- **New OS doesn't auto-discover**: Without mdadm installed, arrays remain dormant
- **Safe operation**: Reassembly is read-only; no data is written or modified

## Reimport Procedure

### 1. Install mdadm

```bash
apt update
apt install mdadm
```

### 2. Verify Array Metadata

Check that disks still have RAID metadata:

```bash
mdadm --examine --scan
```

Expected output: Shows array UUID, level, and member disks.

### 3. Reassemble the Array

Automatically detect and assemble all arrays:

```bash
mdadm --assemble --scan
```

**Note**: This recreates the `/dev/md0` device using existing metadata.

### 4. Verify Array Status

```bash
cat /proc/mdstat
mdadm --detail /dev/md0
```

Check for:
- Active state
- All disks present
- No degraded status

### 5. Make Configuration Persistent

```bash
mdadm --detail --scan >> /etc/mdadm/mdadm.conf
update-initramfs -u
```

### 6. Mount the Filesystem

If you have an existing `/etc/fstab` entry with the filesystem UUID, simply:

```bash
mount -a
```

Or manually mount:

```bash
mount /dev/md0 /mnt/storage
```

## Manual Assembly (If Auto-Scan Fails)

If automatic assembly doesn't work, manually specify devices:

```bash
mdadm --assemble /dev/md0 /dev/disk/by-id/nvme-SAMSUNG_... [all disk IDs]
```

## Reference: Original Array Creation

For future reference, the array was originally created as:

```bash
mdadm --create /dev/md0 \
  --level=10 \
  --raid-devices=4 \
  /dev/disk/by-id/nvme-SAMSUNG_MZQLB3T8HALS-00007_S438NA0N208498 \
  /dev/disk/by-id/nvme-SAMSUNG_MZQLB3T8HALS-00007_S438NA0N208643 \
  /dev/disk/by-id/nvme-SAMSUNG_MZQLB3T8HALS-00007_S438NA0N208735 \
  /dev/disk/by-id/nvme-SAMSUNG_MZQLB3T8HALS-00007_S438NA0N208750

# Save configuration
mdadm --detail --scan >> /etc/mdadm/mdadm.conf
update-initramfs -u

# Filesystem UUID: 8d8eaa4f-5553-4884-8b73-af9f86db0ceb
# Mount point: /mnt/storage
# Filesystem: ext4
```

## Troubleshooting

### Array Shows as Inactive

If `cat /proc/mdstat` shows the array as inactive with (S) flags:

```bash
mdadm --stop /dev/md0
mdadm --assemble --scan -v
```

### Disks Marked as Busy

The array may not have been cleanly shut down. Try forcing assembly:

```bash
mdadm --assemble --force /dev/md0 [disk list]
```

**Warning**: Only use `--force` if you're certain the array is intact.

## Key Points

- ✅ **Safe**: Reassembly doesn't modify data
- ✅ **Metadata preserved**: RAID configuration stored on each disk
- ✅ **Non-destructive**: Array structure remains intact during reinstall
- ⚠️ **Never use `--create`**: This destroys existing arrays; use `--assemble` only

## Additional Resources

- mdadm man page: `man mdadm`
- Linux RAID Wiki: https://raid.wiki.kernel.org/