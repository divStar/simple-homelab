#!/bin/bash
# Get PBS a trusted HTTPS cert from the homelab's Step CA, via Step CA's ACME endpoint
# and PBS's own built-in ACME client (proxmox-backup-manager acme ...).
#
# Trust bootstrap follows docker-vm's pattern (fetch step-ca's fingerprint live from
# /roots.pem, trust-on-first-use) rather than step-ca module's own host script (which
# takes a pre-shared fingerprint) -- simpler, and this is the pattern already in use
# elsewhere in this repo for VM guests specifically.

set -euo pipefail

STEP_CA_DOMAIN=""
STEP_CLIENT_VERSION=""
ACME_ACCOUNT_NAME=""
ACME_CONTACT=""
PBS_NODE_DOMAIN=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --step-ca-domain) STEP_CA_DOMAIN="$2"; shift 2 ;;
        --step-client-version) STEP_CLIENT_VERSION="$2"; shift 2 ;;
        --acme-account-name) ACME_ACCOUNT_NAME="$2"; shift 2 ;;
        --acme-contact) ACME_CONTACT="$2"; shift 2 ;;
        --pbs-node-domain) PBS_NODE_DOMAIN="$2"; shift 2 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

for v in STEP_CA_DOMAIN STEP_CLIENT_VERSION ACME_ACCOUNT_NAME ACME_CONTACT PBS_NODE_DOMAIN; do
    if [ -z "${!v}" ]; then
        echo "Missing required --${v,,}" >&2
        exit 1
    fi
done

echo "Installing step CLI ${STEP_CLIENT_VERSION}..."
curl -fsSL -o /tmp/step.tar.gz \
    "https://dl.smallstep.com/gh-release/cli/gh-release-header/v${STEP_CLIENT_VERSION}/step_linux_${STEP_CLIENT_VERSION}_amd64.tar.gz"
tar -xzf /tmp/step.tar.gz -C /tmp
install -m 0755 "/tmp/step_${STEP_CLIENT_VERSION}/bin/step" /usr/local/bin/step
rm -rf "/tmp/step_${STEP_CLIENT_VERSION}" /tmp/step.tar.gz

echo "Fetching Step CA fingerprint from https://${STEP_CA_DOMAIN}/roots.pem (trust-on-first-use)..."
FINGERPRINT=$(step certificate fingerprint <(curl --silent --insecure "https://${STEP_CA_DOMAIN}/roots.pem"))

echo "Bootstrapping trust (fingerprint: ${FINGERPRINT})..."
step ca bootstrap --ca-url "https://${STEP_CA_DOMAIN}" --fingerprint "${FINGERPRINT}" --install --force

echo "Registering ACME account '${ACME_ACCOUNT_NAME}' with PBS..."
if proxmox-backup-manager acme account list --output-format json | grep -q "\"${ACME_ACCOUNT_NAME}\""; then
    echo "ACME account already registered, skipping."
else
    proxmox-backup-manager acme account register "${ACME_ACCOUNT_NAME}" "${ACME_CONTACT}" \
        --directory "https://${STEP_CA_DOMAIN}/acme/${ACME_ACCOUNT_NAME}/directory"
fi

echo "Setting node ACME config (account=${ACME_ACCOUNT_NAME}, domain=${PBS_NODE_DOMAIN})..."
proxmox-backup-manager node update --acme "account=${ACME_ACCOUNT_NAME}" --acmedomain0 "domain=${PBS_NODE_DOMAIN}"

echo "Ordering certificate..."
proxmox-backup-manager acme cert order --force

echo "ACME setup complete."
