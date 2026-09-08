# Scanopy

Automated network topology mapping ([scanopy/scanopy](https://github.com/scanopy/scanopy), AGPL-3.0). **Experimental** - an unfamiliar third-party tool given deliberately broad network access; evaluate on its merits and remove if it doesn't earn its keep or raises any concern.

## Architecture

```
scanopy-daemon --(scan traffic)--> Management VLAN, routed to every other VLAN
scanopy-daemon <--(control plane, scanopy-network)--> scanopy-server <--> scanopy-db
scanopy-server --(Traefik, management-network)--> https://topology.my.world
```

- **`scanopy-daemon`** does the actual scanning (ARP, SNMP/LLDP, service fingerprinting, Docker API). It's `privileged: true` and multi-homed onto **`scanopy-management-ipvlan-network`** (a real, VLAN-routable address - `10.0.5.8` on Management, parent `eth0`) rather than the upstream reference's `network_mode: host`. Host networking would give the *entire* `docker-vm` host broad cross-VLAN reach (since it removes Docker's own container-level network isolation) - ipvlan keeps that reach scoped to just this one container's own distinct IP. See `opnsense-flint2-vlan-status.md` for the VLAN-side detail and the firewall rule this needed.
- The daemon also mounts `/var/run/docker.sock` read-only, for the "workloads" layer (containers on `docker-vm` itself) - this is a separate mechanism from network reachability (a local socket, not an IP path), so it works regardless of the ipvlan/host-networking question and gives richer data (real container/image names) than network-based fingerprinting would for `docker-vm` specifically.
- **`scanopy-server`** is the web UI/API, Traefik-fronted like everything else (`management-network`, not `service-network` - it's tracked as Management-tier infrastructure here, hence `topology.my.world` resolving to `10.0.5.7`/`docker-management`, not `docker-services`).
- **`scanopy-db`** (`postgres:18-alpine`) is internal-only, reachable from `scanopy-server` alone.
- The daemon and server talk to each other via `scanopy-network` (an internal bridge) using their Compose service names (`scanopy-server:60072`, `scanopy-daemon:60073`) - the upstream reference config instead uses `127.0.0.1`/`host.docker.internal`, which only works under `network_mode: host`. Since we deliberately don't use that, these two env vars are overridden from upstream defaults.
- No SSO/OIDC integration - not currently supported by Scanopy itself. Deferred: whether its own login can be disabled in favor of Traefik forward-auth instead.

## Firewall

The daemon's `10.0.5.8` needs to reach every other VLAN for L2/L3 discovery to mean anything - deliberately the most permissive option for now (one floating rule, source `10.0.5.8/32` → any, positioned above "Only Internet access"), to compare what's actually gained in visibility before narrowing it. Likely narrowing path later: restrict to SNMP against just OPNsense (`10.0.5.1`) and Flint 2 (`10.0.5.2`) once those actually run an SNMP agent (neither does yet - `os-net-snmp` on OPNsense, LuCI's SNMP package on Flint 2, both deferred). Real L2 physical-port topology (not just VLAN-membership-derived) would additionally need a managed switch and/or Flint 2 running LLDP - also deferred, and note ARP itself can never cross a VLAN boundary regardless of firewall rules, so this cross-VLAN visibility fundamentally comes from SNMP-polling the router, not raw scanning into each VLAN.

## Deploying

1. **External resources** (`../external-resources`): `scanopy-network`, `scanopy-management-ipvlan-network`, and the three volumes are added to `project.auto.tfvars` - `tofu apply` there first.
2. **Deploy this stack** (`docker-compose.yml` + `stack.env`), same as any other `docker-apps` module.
3. **DNS**: `topology` is a Host Alias on the `docker-management` Unbound override (`10.0.5.7`), added the same way every other Management-tier hostname is.
4. **Firewall**: see above - already applied directly via the OPNsense API for this initial setup, not yet expressed as Terraform (no such provider is in use here, see `opnsense-flint2-vlan-status.md`'s TODOs).
