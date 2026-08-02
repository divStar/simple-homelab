#!/bin/sh
# upgrade-debian.sh - Upgrade Debian Linux to a new major (codename) release
# Usage: ./upgrade-debian.sh trixie

set -e

if [ -z "$1" ]; then
  echo "Error: Target Debian codename required"
  echo "Usage: $0 <codename>"
  echo "Example: $0 trixie"
  exit 1
fi

NEW_CODENAME="$1"
CURRENT_CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
export DEBIAN_FRONTEND=noninteractive

echo "Current Debian release: $CURRENT_CODENAME"
echo "Target Debian release: $NEW_CODENAME"

# Backup and update classic sources.list, if present
if [ -f /etc/apt/sources.list ]; then
  cp /etc/apt/sources.list /etc/apt/sources.list.bak.$(date +%Y%m%d)
  sed -i "s/$CURRENT_CODENAME/$NEW_CODENAME/g" /etc/apt/sources.list
fi

# Backup and update deb822-style .sources files, if present (default on newer Debian releases)
for f in /etc/apt/sources.list.d/*.sources; do
  [ -e "$f" ] || continue
  cp "$f" "$f.bak.$(date +%Y%m%d)"
  sed -i "s/$CURRENT_CODENAME/$NEW_CODENAME/g" "$f"
done

echo "Updating package index..."
apt-get update

echo "Upgrading system packages..."
apt-get upgrade -y

echo "Performing full release upgrade..."
apt-get full-upgrade -y

apt-get autoremove -y

echo "Debian Linux upgraded from $CURRENT_CODENAME to $NEW_CODENAME"
echo "A reboot is recommended."
