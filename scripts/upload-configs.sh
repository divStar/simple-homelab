#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REMOTE_HOST="core@docker-vm"
REMOTE_PATH="/mnt/data/monitoring"
DEFAULT_INPUT_DIR="./files"

# Required files
REQUIRED_FILES=(
    "alloy-config.alloy"
    "loki-config.yml"
    "prometheus-config.yml"
)

# Function to print colored log messages
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Function to show usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Deploy configuration files to Docker VM.

OPTIONS:
    --input <path>     Path to local directory containing config files (default: ./files)
    -h, --help         Show this help message

REQUIRED FILES:
    - alloy-config.alloy
    - loki-config.yml
    - prometheus-config.yml

EXAMPLE:
    $0 --input ./configs
    $0
EOF
    exit 0
}

# Parse arguments
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

# Main script
log_info "Starting config deployment to ${REMOTE_HOST}:${REMOTE_PATH}"
log_info "Local input directory: ${INPUT_DIR}"

# Check if input directory exists
if [[ ! -d "$INPUT_DIR" ]]; then
    log_error "Input directory does not exist: ${INPUT_DIR}"
    exit 1
fi

# Verify all required files exist locally
log_info "Verifying required files exist locally..."
for file in "${REQUIRED_FILES[@]}"; do
    local_file="${INPUT_DIR}/${file}"
    if [[ ! -f "$local_file" ]]; then
        log_error "Required file not found: ${local_file}"
        exit 1
    fi
    log_success "Found: ${file}"
done

# Create remote directory if it doesn't exist and set ownership
log_info "Creating remote directory if necessary..."
if ! ssh "$REMOTE_HOST" "sudo mkdir -p ${REMOTE_PATH} && sudo chown core:core ${REMOTE_PATH}" 2>&1; then
    log_error "Failed to create remote directory: ${REMOTE_PATH}"
    exit 1
fi
log_success "Remote directory ready: ${REMOTE_PATH}"

# Copy each file
log_info "Copying configuration files..."
for file in "${REQUIRED_FILES[@]}"; do
    local_file="${INPUT_DIR}/${file}"
    remote_file="${REMOTE_HOST}:${REMOTE_PATH}/${file}"
    
    log_info "Copying ${file}..."
    if ! scp -q "$local_file" "$remote_file" 2>&1; then
        log_error "Failed to copy file: ${file}"
        log_error "Source: ${local_file}"
        log_error "Destination: ${remote_file}"
        exit 1
    fi
    log_success "Copied: ${file}"
done

# Set ownership and permissions on remote files
log_info "Setting file ownership to 65534:65534 and permissions to 644 (read-only)..."
if ! ssh "$REMOTE_HOST" "sudo chmod 644 ${REMOTE_PATH}/*.yml ${REMOTE_PATH}/*.alloy" 2>&1; then
    log_error "Failed to set ownership and permissions on remote files"
    exit 1
fi
log_success "Ownership and permissions set successfully"

log_success "All configuration files deployed successfully!"
log_info "Files are now available at ${REMOTE_HOST}:${REMOTE_PATH}"