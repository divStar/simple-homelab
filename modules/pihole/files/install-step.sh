#!/bin/bash
# install-step.sh - Install the step CLI and bootstrap trust in a Step CA
# Usage: ./install-step.sh <step-ca-domain> <step-cli-version>

set -euo pipefail

STEP_CA_DOMAIN="$1"
STEP_VERSION="$2"

if [ -z "$STEP_CA_DOMAIN" ] || [ -z "$STEP_VERSION" ]; then
  echo "Usage: $0 <step-ca-domain> <step-cli-version>"
  exit 1
fi

if ! command -v step > /dev/null 2>&1; then
  curl -fsSL -o /tmp/step.tar.gz "https://dl.smallstep.com/gh-release/cli/gh-release-header/v${STEP_VERSION}/step_linux_${STEP_VERSION}_amd64.tar.gz"
  tar -xzf /tmp/step.tar.gz -C /tmp
  install -m 0755 "/tmp/step_${STEP_VERSION}/bin/step" /usr/local/bin/step
  rm -rf "/tmp/step_${STEP_VERSION}" /tmp/step.tar.gz
fi

# Get the CA fingerprint from an insecurely downloaded roots.pem, same as docker-vm does
FINGERPRINT=$(step certificate fingerprint <(curl --silent --insecure "https://${STEP_CA_DOMAIN}/roots.pem"))

step ca bootstrap --ca-url "https://${STEP_CA_DOMAIN}" --fingerprint "$FINGERPRINT" --install --force

# Install the root cert into the system truststore too, not just step's own store
cp /root/.step/certs/root_ca.crt /etc/ssl/certs/step-ca-root.pem
update-ca-certificates
