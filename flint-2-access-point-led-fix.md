# Flint 2 (GL-MT6000) Access Point mode — DNS/NTP/LED fix (2026-08-25)

Flint 2 runs in **Access Point mode** (bridges VLANs into the trunk to `sanctum`, no routing/NAT/DHCP role of its own). Four related issues, same underlying pattern: config left over from before this device's role changed, never revisited.

## 1. No DNS on the Management interface

Static interfaces don't get DNS via DHCP the way dynamic ones do — `vlan05_mngmt` (`10.0.5.2`) had never had explicit DNS servers set, so `/etc/resolv.conf` was empty. Broke `nslookup`, `traceroute`, and the LuCI/GL.iNet plugin store (all need real DNS; `ping` doesn't).

```sh
uci set network.vlan05_mngmt.dns="10.0.5.5 10.0.5.1"   # Pi-hole + OPNsense's own Unbound
uci commit network
/etc/init.d/network reload
```

## 2. Clock 5 days behind → TLS cert errors

`chronyd` (this firmware's NTP client, not stock `sysntpd`) had a correctly configured pool (`2.openwrt.pool.ntp.org`) but could never resolve it — same missing-DNS cause as above — so it never synced. Manifested as `SSL verify error: certificate is not yet valid` on package fetches. Fixing DNS didn't retroactively fix the clock; `chronyd` needed a kick to retry:

```sh
/etc/init.d/chronyd restart
```

Confirmed `pool` directives retry on their own going forward — this was a one-time catch-up, not something needing repeating after future reboots, now that DNS resolves.

## 3. Leftover VLAN 1 (`10.0.99.x`)

Already-tracked TODO in `opnsense-flint2-vlan-status.md`, just never executed. Removed via GUI, not CLI: the `eth1:u*` untagged row on Flint 2's Bridge VLAN filtering page, and on OPNsense the `opt5` interface + its DHCP range (`10.0.99.100`–`199`) + its listen-interface reference on Unbound. Verified clean afterward via a fresh `config.xml` pull (`/api/core/backup/download/this`) — zero `opt5`/`10.0.99.` references left.

## 4. Blinking blue LED + "No Internet Connection" banner

**Dead end, ruled out:** `kmwan` (GL.iNet's multi-WAN failover manager) looked like the obvious culprit — it actively pings `1.1.1.1`/`8.8.8.8`/etc. against `wan`/`wwan`/`tethering`/`secondwan`, none of which are real in this deployment. Disabled it as a legitimate cleanup (AP mode has no WAN role, so it's dead weight regardless), but it turned out to be irrelevant here — confirmed by a comment in `/usr/bin/gl_led` itself: `#kmwan will not be used in the AP/WDS mode`.

```sh
uci set kmwan.global.enable="0"
uci commit kmwan
/etc/init.d/kmwan restart
```

**Actual cause:** `gl_led`'s AP-mode branch hard-gates on `network.interface.lan` being up *before* it even attempts a ping check:

```sh
lan_status=`ubus call network.interface.lan status | jsonfilter -q -e @.up`
if [ "$lan_status" = "true" ]; then
    for track_ip in `uci get glconfig.general.track_ip`; do
        ping "$track_ip" -c1 -W1 | grep "1 packets rec" && status="1" && break
    done
fi
```

`network.lan` was still bound to the just-retired VLAN 1 (`device='br-lan.1'`, `proto='dhcp'`) — perpetually `up: false, pending: true` since nothing answers DHCP there anymore. The check never even ran.

**Fix:** rename the already-correct `vlan05_mngmt` interface to `lan`, reusing its existing static `10.0.5.2` rather than creating a second IP on VLAN 5. Two other places referenced the old name and needed updating in the same pass — the `flint` firewall zone and both `mgmnt-wifi` radio SSIDs (`wifinet8`/`wifinet9`):

```sh
uci delete network.lan
uci rename network.vlan05_mngmt=lan
uci set firewall.@zone[0].network="lan"
uci set wireless.wifinet8.network="lan"
uci set wireless.wifinet9.network="lan"
uci commit network
uci commit firewall
uci commit wireless
/etc/init.d/network reload
```

Confirmed after reload: `network.interface.lan` reports `up: true`, LED brightness flips (`blue:run`→0, `white:system`→1, matching the exact `mt6000` case in `online_led_display()` in `/lib/functions/gl_util.sh`), and the GL.iNet UI's Ethernet/WAN card and "No Internet" banner both cleared — confirming the UI reads from the same `lan` interface, not a separate check.

**Safety net taken before touching any of this:** full config export via LuCI (System → Backup / Flash Firmware → Generate archive), downloaded and verified locally before making changes — restores config onto a factory-reset device if something goes wrong; doesn't substitute for the hardware reset button as the actual last-resort recovery path.

## How this was diagnosed

Live SSH investigation throughout (`uci show`, `ubus call`, reading the actual init/hotplug scripts rather than guessing) rather than trusting a copy-pasted fix found online — an AI-suggested fix (`glmultiwan.*`/`system.led_sys.*` UCI paths) turned out to target a different, older GL.iNet firmware generation entirely; this build uses `kmwan` and has no `led_sys` section at all. Reading `/usr/bin/gl_led` directly (it's a plain shell script, not compiled) was what actually revealed the real logic.

Research referenced along the way:
- [GL.iNet Network Mode docs](https://docs.gl-inet.com/router/en/4/interface_guide/network_mode/) — confirms AP mode disables NAT/DHCP, operates as a switch not a gateway
- [GL.iNet Multi-WAN docs](https://docs.gl-inet.com/router/en/4/interface_guide/multi-wan/)
- [Beryl AX "Cannot use Lan when in Access Point mode" — GL.iNet forum](https://forum.gl-inet.com/t/beryl-ax-cannot-use-lan-when-in-access-point-mode/28105) — independent confirmation that DHCP-on-`lan`-in-AP-mode is unreliable generally; community fix (static IP on the real subnet) matches the direction taken here
- [GL-MT6000/Flint 2 "connected, but no internet" — GL.iNet forum](https://forum.gl-inet.com/t/gl-mt6000-flint-2-interface-connected-to-modem-but-no-internet-available/51200)
