#!/bin/bash
# pihole-cert.sh - Request/renew Pi-hole's webserver TLS certificate from Step CA
# and combine it into the single PEM file Pi-hole's webserver expects.
# Usage: ./pihole-cert.sh <step-ca-domain> <provisioner> <provisioner-password-file> <hostname> <fqdn> <ip...>
# Every trailing <ip> becomes its own --san - callers pass one per
# network_interfaces entry, so a dual-homed container's cert covers all of them.

set -euo pipefail

STEP_CA_DOMAIN="$1"
PROVISIONER="$2"
PROVISIONER_PASSWORD_FILE="$3"
HOSTNAME_SHORT="$4"
FQDN="$5"
shift 5
IP_ADDRESSES=("$@")

if [ "${#IP_ADDRESSES[@]}" -eq 0 ]; then
  echo "Usage: $0 <step-ca-domain> <provisioner> <provisioner-password-file> <hostname> <fqdn> <ip...>"
  exit 1
fi

export STEPPATH=/root/.step

# "pi.hole" is Pi-hole's own hardcoded webserver.domain default, not a
# per-deployment value - Pi-hole warns if the loaded cert doesn't cover it,
# even though it's not otherwise used to reach this box.
SAN_ARGS=(--san "$HOSTNAME_SHORT" --san "$FQDN" --san "pi.hole")
for ip in "${IP_ADDRESSES[@]}"; do
  SAN_ARGS+=(--san "$ip")
done

step ca certificate "$HOSTNAME_SHORT" /etc/pihole/tls-cert.pem /etc/pihole/tls-key.pem \
  "${SAN_ARGS[@]}" \
  --not-after=24h \
  --provisioner "$PROVISIONER" \
  --provisioner-password-file "$PROVISIONER_PASSWORD_FILE" \
  --force

# Pi-hole's webserver wants a single PEM with both cert and key, unlike Docker's
# separate-files convention.
cat /etc/pihole/tls-cert.pem /etc/pihole/tls-key.pem > /etc/pihole/tls.pem
chmod 0600 /etc/pihole/tls.pem /etc/pihole/tls-key.pem
chmod 0644 /etc/pihole/tls-cert.pem

if systemctl is-active --quiet pihole-FTL.service; then
  systemctl restart pihole-FTL.service
fi
