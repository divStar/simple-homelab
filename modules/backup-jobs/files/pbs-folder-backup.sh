#!/bin/bash
# Runs one folder's PBS backup + prune. Invoked as: pbs-folder-backup.sh <name>
# <name> must match a file at /etc/pbs-folder-backup/<name>.env (ARCHIVES,
# BACKUP_ID, PRUNE_ARGS - namespace is <name> itself). Credentials come from
# the separate shared /etc/pbs-folder-backup/credentials.env.
set -euo pipefail

NAME="${1:?usage: pbs-folder-backup.sh <name>}"
CONF_DIR="/etc/pbs-folder-backup"

# shellcheck source=/dev/null
source "$CONF_DIR/credentials.env"
# shellcheck source=/dev/null
source "$CONF_DIR/$NAME.env"

export PBS_REPOSITORY PBS_PASSWORD

# Namespaces don't auto-create on first backup (unlike backup groups) -
# confirmed idempotent to call every run (exit 0 whether or not it already
# exists), so no existence check needed here.
proxmox-backup-client namespace create "$NAME"

proxmox-backup-client backup $ARCHIVES --ns "$NAME" --backup-id "$BACKUP_ID" --backup-type host

proxmox-backup-client prune "host/$BACKUP_ID" --ns "$NAME" $PRUNE_ARGS
