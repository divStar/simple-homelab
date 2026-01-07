#!/bin/sh
# update-alpine.sh - Update Alpine Linux (within the current version)
# Usage: ./update-alpine.sh

set -e

LOGFILE="/var/log/apk-updates-$(date '+%Y%m%d-%H%M%S').log"

apk update >> "$LOGFILE" 2>&1
apk upgrade -U -a >> "$LOGFILE" 2>&1

# Keep only the last 10 log files
ls -t /var/log/apk-updates-*.log 2>/dev/null | tail -n +11 | xargs -r rm