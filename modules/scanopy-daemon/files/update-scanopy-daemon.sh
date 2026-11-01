#!/bin/sh
# Replaces scanopy-daemon with the latest GitHub release and restarts it - only if the binary actually changed.
set -e

BIN=/usr/local/bin/scanopy-daemon
URL="https://github.com/scanopy/scanopy/releases/latest/download/scanopy-daemon-linux-$(dpkg --print-architecture)"
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

curl -fsSL --retry 3 "$URL" -o "$TMP"
chmod 0755 "$TMP"
NEW=$("$TMP" --version)

if cmp -s "$TMP" "$BIN"; then
  echo "Already up to date: $NEW"
  exit 0
fi

OLD=$("$BIN" --version || echo "none")
install -m 0755 "$TMP" "$BIN"
systemctl restart scanopy-daemon
echo "Updated: $OLD -> $NEW"
