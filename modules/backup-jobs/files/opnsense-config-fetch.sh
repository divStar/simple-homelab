#!/bin/bash
# ExecStartPre for the "opnsense-config" folder backup - pulls config.xml via
# OPNsense's REST API before pbs-folder-backup.sh pushes it. Credentials come
# from the unit's EnvironmentFile (OPNSENSE_HOST/API_KEY/API_SECRET).
set -euo pipefail

DEST_DIR="/mnt/temp/opnsense"
DEST_FILE="$DEST_DIR/config.xml"

mkdir -p "$DEST_DIR"

# Fetch to a temp file, rename atomically - a failed/partial transfer must
# never leave a stale-but-valid-looking config.xml for the backup to push.
TMP_FILE="$(mktemp "$DEST_DIR/.config.xml.XXXXXX")"
trap 'rm -f "$TMP_FILE"' EXIT

curl -sf --retry 3 --retry-delay 5 -u "${OPNSENSE_API_KEY}:${OPNSENSE_API_SECRET}" \
  "https://${OPNSENSE_HOST}/api/core/backup/download/this" \
  -o "$TMP_FILE"

mv "$TMP_FILE" "$DEST_FILE"
trap - EXIT
