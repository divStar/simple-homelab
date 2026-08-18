# sanctum disaster recovery

Recovery steps for "router is gone" up to "`sanctum` needs full rebuild from bare metal." Verify
IPs/VLAN assignments below against current reality before acting on them - this repo evolves.

## Facts to know before starting

- Every core service has a static IP (`step-ca`, `sanctum-samba`, `pihole`, `pbs-lxc`,
  `docker-vm`) - no DHCP server needed to reach any of them.
- Proxmox (`pveproxy`/`pvedaemon`) runs LAN-only, no internet/DNS required. Internet is only
  needed for `proxmox_download_file` (LXC templates, VM images, ISOs).
- Pi-hole's local `.my.world` records resolve without internet - only forwarding to public DNS
  (`8.8.8.8`/`8.8.4.4`) needs a real upstream.

## `transcrypt` decryption password

Required to read this repo's secrets. Lives only in local git config
(`git config transcrypt.password`), never pushed to GitHub. Three copies exist: this machine, its
Time Machine backup, a paper copy. GitHub remote: `divStar/simple-homelab`.

## Getting physically connected to `sanctum`

> [!NOTE]
> Use `divStar-AP05` (hidden SSID, VLAN 5) for disaster recovery. Wired alternative: macOS
> `System Settings → Network → Manage Virtual Interfaces` → add VLAN, tag `5`, bind to the
> physical port in use.

- Wired: USB-Ethernet adapter into a free NIC on `sanctum`.
- Fallback, if Flint 2/OPNsense's VLAN layer is itself unavailable: Flint 2 in AP mode, wired into
  a free NIC. Works standalone, no OPNsense dependency. Known unreliable in AP mode (UI becomes
  inaccessible, ethernet/internet passthrough issues) - test this ahead of time, not for the first
  time mid-incident.

## Addressing

`sanctum`, `pihole`, `step-ca`, and Flint 2 itself: `10.0.5.x` (Management, `vmbr1`). `samba` and
`docker-vm`: `10.0.10.x` (Services, `vmbr1`). `10.0.20.x` (Trusted), `10.0.30.x` (Guest),
`10.0.40.x` (IoT) - client-facing only. Full VLAN/rule detail: `opnsense-flint2-vlan-status.md`.

Without OPNsense: VLAN tagging, static IPs within a VLAN, same-VLAN device-to-device all work
(plain L2, no router needed). Needs OPNsense: crossing VLANs, firewall enforcement, internet
access for any VLAN.

Rebuilding OPNsense itself needs `proxmox_download_file` to fetch its ISO, which needs internet -
requires a temporary router/WAN patch, or a pre-staged local ISO.

## If the Flint 2 itself dies

Any VLAN-capable router/AP can replace it - reconfigure the same SSID→VLAN mappings. Full
bridge-vlan table, wireless config, OPNsense rule set to reconfigure from:
`opnsense-flint2-vlan-status.md`.

## Scenario A: `sanctum` survives, only the router is gone

1. Point `sanctum`'s resolver at Pi-hole if not already.
2. Get physically connected (above). `.my.world` resolves via Pi-hole - no DHCP/internet needed.
3. For fresh downloads (`tofu apply` pulling templates/ISOs): temporarily patch the ISP
   modem into a free `sanctum` NIC for real internet. FritzBox only - the Vigor is a bare PPPoE
   modem, this won't grant internet without a configured PPPoE client. Not yet resolved.

## Scenario B: `sanctum` needs full rebuild

### Disk layout

- `/mnt/storage` = `md0`, mdadm RAID10, 4 NVMe drives, ~7TB usable.
- `/mnt/backup` = `md1`, mdadm RAID1, 2 drives, ~20TB. PBS's own datastore lives here.
- Boot drives (`rpool`): ZFS, 2 SSDs, currently a plain stripe (not a mirror) - confirm via
  `zpool status`: both disks must show under one `mirror-0` group, not as independent top-level
  members. `copies=3` is set (protects against partial/bad-sector corruption only, not disk loss).
- Reimport via `mdadm --assemble --scan` (not `zpool import` - `storage`/`backup` are not ZFS,
  despite a stale `zfs_storage`/`storage-pool` reference in `host`'s Terraform config). Use
  `--scan`, not specific device paths - device names aren't stable across reboots/reinstalls.
- No offsite/off-host copy of `/mnt/backup` exists. Total machine loss (fire, theft) = PBS
  datastore gone too. This plan only covers "OS/boot problem, arrays survive."

### Reinstalling Proxmox

Fresh Proxmox has no VLAN awareness - this bootstrap currently runs on `vmbr0`/`192.168.178.x`
(FritzBox-era addressing) until `network-bridges` and per-LXC VLAN interfaces are reapplied.

> [!WARNING]
> Once the DrayTek Vigor replaces the FritzBox, `vmbr0` becomes a pure WAN/PPPoE uplink with no
> LAN-style addressing - `192.168.178.x` below stops applying, and `sanctum` has no internet until
> OPNsense is running and handling PPPoE. Plan: fetch the OPNsense ISO on another
> internet-connected device (e.g. phone hotspot on the Mac), transfer it to `sanctum`, install/
> restore OPNsense from it first - real internet, and everything downstream, flows through
> OPNsense normally from that point on. **Open question**: whether `sanctum` is reachable via
> `divStar-AP05` at all on a *freshly reinstalled* box, since `vmbr1`/Management doesn't exist
> until `network-bridges` has already been applied once - see note under Rebuild order.

- Default install onto the 2 boot SSDs.
- Hostname must be `sanctum`.
- ZFS boot pool: choose RAID1 (mirror) explicitly in the installer, set `copies=3`. Verify with
  `zpool status` immediately after install that both disks show under `mirror-0` - don't trust
  the installer selection alone.
- Match `sanctum`'s static IP to current reality (today: `192.168.178.25` on `vmbr0` - check
  current state, this may have changed).
- Match `vmbr0`'s existing static IP - `sanctum.my.world` must resolve to the same address.
- Installer only sets root password, no SSH key - add the existing public key to
  `/root/.ssh/authorized_keys` before any `ssh_resource` provisioning can run.
- `vmbr1` (VLAN-aware, 3 ports) is not part of any default install - reapply
  `modules/network-bridges` afterward.

### Rebuild order

1. Reinstall Proxmox, reimport mdadm arrays.
2. Get physically connected. On a freshly reinstalled box, `divStar-AP05` reachability is an open
   question (see warning above) - `vmbr1`/Management doesn't exist until `network-bridges` has
   already been applied once, so the very first connection may need to be wired directly into a
   free `sanctum` NIC instead, bypassing both `vmbr0` and the not-yet-existing `vmbr1`.
3. Temporary static IP on your own machine matching whatever bootstrap link is actually in use (no
   DHCP server exists yet).
4. Temporary `/etc/hosts` entry pointing `sanctum.my.world` at `sanctum`'s bootstrap IP - lets
   `tofu apply` reach the Proxmox API with no working DNS.
5. FritzBox era: temporary WAN patch (modem into a free NIC) unblocks template/ISO downloads
   directly. Vigor era: no direct internet on `sanctum` - fetch the OPNsense ISO on another
   internet-connected device (e.g. phone hotspot on the Mac), transfer it to `sanctum`, install
   OPNsense and restore its config first, before anything else needing internet.
6. Wipe Terraform state, reapply fresh (don't try to reconcile old state against a wiped host).
   Host directories are bind-mounted into containers, not stored in-container - once arrays are
   reimported to their expected paths, fresh containers see existing data through the same bind
   mounts, no separate restore step.
   - Secrets regenerate (PBS token, Samba users, etc.) - update anything external holding old
     values.
   - Arrays must be reimported before `tofu apply` for anything that bind-mounts them - some
     modules seed-once on creation (Pi-hole), seeding against an empty path first then restoring
     data after causes a conflict.
7. Rebuild `host`, then `pihole`.
8. Once Pi-hole is serving `.my.world` again: switch `sanctum`'s resolver back to Pi-hole, remove
   the temporary `/etc/hosts` override.
9. Rebuild the rest (`step-ca`, `samba`, `docker-vm`, ...) normally. FritzBox era only:
   `opnsense` is part of this step too, not done earlier.

## Trusting `step-ca` from a fresh OPNsense (or anything new)

Fetch `step-ca`'s root cert via its static IP (`192.168.178.155`), never its hostname - works
regardless of DNS state. Don't use ACME for this - deferred, OPNsense+step-ca ACME has known
reliability issues.
