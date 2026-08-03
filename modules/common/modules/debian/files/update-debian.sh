#!/bin/sh
# update-debian.sh - Update Debian Linux (within the current version)
# Usage: ./update-debian.sh

set -e

LOGFILE="/var/log/apt-updates-$(date '+%Y%m%d-%H%M%S').log"
export DEBIAN_FRONTEND=noninteractive

apt-get update >> "$LOGFILE" 2>&1
apt-get upgrade -y >> "$LOGFILE" 2>&1
apt-get autoremove -y >> "$LOGFILE" 2>&1

# Keep only the last 10 log files
ls -t /var/log/apt-updates-*.log 2>/dev/null | tail -n +11 | xargs -r rm
