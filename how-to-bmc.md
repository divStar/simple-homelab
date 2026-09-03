# How to access the BMC (MegaRAC)

Gigabyte MegaRAC SP-X, ASpeed AST2600, on the ME03-CE1 motherboard. Only reachable via the
true dedicated management port (rear I/O, labeled `M LAN` on the backplate) — the two onboard
1GbE ports and the shared/piggyback NC-SI path are not used for this.

## BMC config

- **Bond Mode**: `Dedicate Mode` (BMC firmware's Network Settings page)
- **IP Address Source**: Static
- **IP Address**: `192.168.1.53`
- **Subnet Mask**: `255.255.255.0`
- **Default Gateway**: `192.168.1.1` — required, the firmware rejects `0.0.0.0` outright
  ("First number must not be 0"). Nothing needs to actually exist at this address, it just has
  to be set to *something* non-zero.
- **VLAN**: disabled

## Connecting from a laptop

Direct point-to-point connection (USB-C-to-Ethernet adapter, no switch needed):

- Static IP in the same subnet, e.g. `192.168.1.244`
- Subnet mask `255.255.255.0`
- **Router/Gateway field: must be set** (e.g. `192.168.1.1`) — leaving it blank leaves the OS's
  manually-configured network service in a half-active state: it'll still answer ARP, but won't
  pass real IP traffic (ping, HTTPS) at all. This is OS-side behavior (confirmed on macOS, likely
  the same on Windows/Linux), not anything BMC-specific.
- **That subnet must not overlap with any other currently-active interface** (Wi-Fi, etc.) — an
  overlapping subnet leaves the OS's routing table unable to tell which interface owns that
  address range, which can break unrelated connectivity. This is what happened setting
  `192.168.178.1` (matching the primary Wi-Fi subnet) as the adapter's router — switching to the
  disjoint `192.168.1.0/24` fixed it.
- Browse to `https://192.168.1.53` — self-signed cert, click through the warning.

## If it's unreachable

`ipmitool` run locally on `sanctum` talks to the BMC over KCS, bypassing the network entirely —
works even when the BMC's own network stack is fully unreachable:

```bash
ipmitool lan print 1              # current state
ipmitool lan set 1 ipsrc static
ipmitool lan set 1 ipaddr 192.168.1.53
ipmitool lan set 1 netmask 255.255.255.0
ipmitool lan set 1 defgw ipaddr 192.168.1.1
ipmitool mc reset cold            # if the BMC's network stack needs a kick
```

## Shared-port piggyback / H2B (not pursued)

The BCM5720 NICs support NC-SI (letting the BMC piggyback its traffic over an onboard host LAN
port) and, separately, a "Host-to-BMC" (H2B) passthrough capability that would let the host's own
network stack see BMC traffic directly. Both were investigated and set aside:

- **NC-SI piggyback** works at the physical layer (BMC traffic genuinely goes out over a shared
  onboard port), but only reaches wherever that port's cable physically terminates — a NIC's Linux
  bridge membership has no effect on it, since NC-SI operates below the host network stack
  entirely. Only useful if that cable lands on a device already part of the target VLAN (e.g.
  Flint 2), not a dead-end room.
- **H2B** (`GRC_MODE_HTX2B_ENABLE`/`B2HRX_ENABLE`, confirmed real via the Linux `tg3` driver
  source) would, if enabled, let the host's own NIC driver see BMC traffic directly — but it's
  firmware-gated at boot, off by default on this board, and there's no verified, safe way to
  enable it (no public register-level Broadcom reference for the actual filter/routing registers
  involved, and the driver itself only ever preserves this state, never originates it). Not worth
  pursuing — the dedicated-port setup above fully covers actual needs.
