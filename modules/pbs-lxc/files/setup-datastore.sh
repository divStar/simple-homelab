#!/bin/bash
# Registers the PBS datastore at the given (already-mounted) path. Deliberately
# NOT a copy of modules/pbs-vm's setup-datastore.sh: there's no block device to
# format/mount here (the LXC's mount_point already bind-mounts the host
# directory in before this ever runs), and unlike the VM's disk, this
# directory's contents outlive a container destroy/recreate -- so the default
# assumption is inverted. A directory with an existing chunk store is the
# normal case; a genuinely empty one only happens on the very first-ever
# bootstrap.
#
# `proxmox-backup-manager datastore create` is NOT idempotent against a path
# that already has a `.chunks` structure -- it fails with EEXIST. The
# `--reuse-datastore true` flag (confirmed present in this PBS version's own
# --help output) is the sanctioned way to adopt an existing one instead.

set -euo pipefail

MOUNT_PATH=""
DATASTORE_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
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

if proxmox-backup-manager datastore list --output-format json | grep -q "\"${DATASTORE_NAME}\""; then
    echo "PBS datastore '${DATASTORE_NAME}' already registered, skipping."
elif [ -d "${MOUNT_PATH}/.chunks" ]; then
    echo "Existing chunk store found at ${MOUNT_PATH} -- re-registering as '${DATASTORE_NAME}' (--reuse-datastore)..."
    proxmox-backup-manager datastore create "${DATASTORE_NAME}" "${MOUNT_PATH}" --reuse-datastore true
else
    echo "No existing chunk store found -- first-ever bootstrap, creating fresh datastore '${DATASTORE_NAME}' at ${MOUNT_PATH}..."
    proxmox-backup-manager datastore create "${DATASTORE_NAME}" "${MOUNT_PATH}"
fi

echo "Datastore setup complete."
