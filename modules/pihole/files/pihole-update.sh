#!/bin/sh
# pihole-update.sh - Update Pi-hole's own software (Core/FTL/Web)
# Usage: ./pihole-update.sh

set -e

LOGFILE="/var/log/pihole-updates-$(date '+%Y%m%d-%H%M%S').log"

pihole -up >> "$LOGFILE" 2>&1

# No explicit restart here - basic-install.sh's finalize path unconditionally
# runs `restart_service pihole-FTL` whenever Core/FTL actually update, via the
# --repair --unattended pass update.sh triggers internally. A web-only update
# skips that pass, but doesn't need a restart either (static files only).

# Keep only the last 10 log files
ls -t /var/log/pihole-updates-*.log 2>/dev/null | tail -n +11 | xargs -r rm
