#!/bin/bash
# Pulls a sysupgrade config archive from Flint 2 over SSH, using a dedicated
# key restricted via authorized_keys command= to only run sysupgrade+stream+
# cleanup - even if this key leaked, it can't do anything else on the device.
set -euo pipefail

DEST_DIR="/mnt/temp/flint2"
DEST_FILE="$DEST_DIR/config.tar.gz"

mkdir -p "$DEST_DIR"

KEY_FILE="$(mktemp)"
TMP_FILE="$(mktemp "$DEST_DIR/.config.tar.gz.XXXXXX")"
trap 'rm -f "$KEY_FILE" "$TMP_FILE"' EXIT

printf '%s' "$FLINT2_SSH_KEY_B64" | base64 -d > "$KEY_FILE"
chmod 0600 "$KEY_FILE"

ssh -i "$KEY_FILE" -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new -o BatchMode=yes -o ConnectTimeout=10 \
  "root@${FLINT2_HOST}" > "$TMP_FILE"

mv "$TMP_FILE" "$DEST_FILE"
