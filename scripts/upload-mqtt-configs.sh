#!/bin/bash
#
# Pushes updated Mosquitto config files to docker-vm. For config changes only - prefer changing
# stack.env (MQTT_EXPORTER_USERNAME/PASSWORD etc.) over these files whenever possible; this is only
# for what env vars can't cover (mosquitto.conf, the Mosquitto passwd file).
#
# Assumes /mnt/data/mqtt already exists on docker-vm (created once during initial deployment - see
# modules/docker-apps/modules/mqtt/README.md). This script does not create it.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

REMOTE_HOST="core@docker-management.my.world"
REMOTE_PATH="/mnt/data/mqtt"
DEFAULT_INPUT_DIR="./files"

# file:owner:mode - kept as plain strings (not an associative array) so this still runs under
# macOS's stock /bin/bash 3.2, not just a newer bash. Mosquitto (uid/gid 1883 in the
# eclipse-mosquitto image) refuses to load the passwd file unless it owns it with no group/other
# access - mosquitto.conf has no such restriction.
REQUIRED_FILES=(
    "mosquitto.conf:core:core:644"
    "passwd:1883:1883:700"
)

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Push Mosquitto config files to docker-vm.

OPTIONS:
    --input <path>     Path to local directory containing config files (default: ./files)
    -h, --help         Show this help message
EOF
    exit 0
}

INPUT_DIR="$DEFAULT_INPUT_DIR"

while [[ $# -gt 0 ]]; do
    case $1 in
        --input)
            INPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            ;;
    esac
done

log_info "Pushing config files to ${REMOTE_HOST}:${REMOTE_PATH}"

for entry in "${REQUIRED_FILES[@]}"; do
    file="${entry%%:*}"
    local_file="${INPUT_DIR}/${file}"
    if [[ ! -f "$local_file" ]]; then
        log_error "Required file not found: ${local_file}"
        exit 1
    fi
done

for entry in "${REQUIRED_FILES[@]}"; do
    IFS=':' read -r file owner group mode <<< "$entry"
    local_file="${INPUT_DIR}/${file}"
    remote_file="${REMOTE_HOST}:/tmp/${file}"

    log_info "Copying ${file}..."
    if ! scp -q "$local_file" "$remote_file" 2>&1; then
        log_error "Failed to copy file: ${file}"
        log_error "Source: ${local_file}"
        log_error "Destination: ${remote_file}"
        exit 1
    fi

    if ! ssh "$REMOTE_HOST" "sudo mv /tmp/${file} ${REMOTE_PATH}/${file} && \
        sudo chown ${owner}:${group} ${REMOTE_PATH}/${file} && \
        sudo chmod ${mode} ${REMOTE_PATH}/${file}" 2>&1; then
        log_error "Failed to move/chown/chmod ${file} into ${REMOTE_PATH} - does that directory exist on ${REMOTE_HOST}?"
        exit 1
    fi

    log_success "Updated: ${file}"
done

log_info "Restart the mosquitto/mqtt-exporter stack to pick up the change."
