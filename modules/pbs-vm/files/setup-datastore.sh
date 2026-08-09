#!/bin/bash
# Formats and mounts the second virtio disk (the /mnt/backup-backed one) and creates
# the PBS datastore on it. Idempotent: safe to re-run on a later `tofu apply`.

set -euo pipefail

DEVICE="/dev/vdb"
MOUNT_PATH=""
DATASTORE_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --device) DEVICE="$2"; shift 2 ;;
        --mount-path) MOUNT_PATH="$2"; shift 2 ;;
        --datastore-name) DATASTORE_NAME="$2"; shift 2 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

for v in MOUNT_PATH DATASTORE_NAME; do
    if [ -z "${!v}" ]; then
        echo "Missing required --${v,,}" >&2
        exit 1
    fi
done

if ! blkid "$DEVICE" > /dev/null 2>&1; then
    echo "Formatting ${DEVICE} as ext4..."
    mkfs.ext4 -F -L pbs-datastore "$DEVICE"
else
    echo "${DEVICE} already has a filesystem, skipping mkfs."
fi

mkdir -p "$MOUNT_PATH"

if ! mountpoint -q "$MOUNT_PATH"; then
    echo "Mounting ${DEVICE} at ${MOUNT_PATH}..."
    mount "$DEVICE" "$MOUNT_PATH"
else
    echo "${MOUNT_PATH} already mounted, skipping."
fi

if ! grep -q "$MOUNT_PATH" /etc/fstab; then
    echo "Adding fstab entry..."
    UUID=$(blkid -s UUID -o value "$DEVICE")
    echo "UUID=${UUID}  ${MOUNT_PATH}  ext4  defaults,noatime  0  2" >> /etc/fstab
else
    echo "fstab entry already present, skipping."
fi

if proxmox-backup-manager datastore list --output-format json | grep -q "\"${DATASTORE_NAME}\""; then
    echo "PBS datastore '${DATASTORE_NAME}' already exists, skipping."
else
    echo "Creating PBS datastore '${DATASTORE_NAME}' at ${MOUNT_PATH}..."
    proxmox-backup-manager datastore create "${DATASTORE_NAME}" "${MOUNT_PATH}"
fi

echo "Datastore setup complete."
