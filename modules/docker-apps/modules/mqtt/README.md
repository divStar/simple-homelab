# MQTT

Mosquitto MQTT broker for the two Tasmota smart plugs, plus `mqtt-exporter` to translate their telemetry into Prometheus metrics. Nothing in this module talks to InfluxDB - Prometheus/Grafana is the whole stack now.

## Architecture

```
Tasmota plug --(MQTT, tele/<topic>/SENSOR)--> Mosquitto --(subscribe)--> mqtt-exporter --(:9000/metrics)--> Prometheus
```

- **Mosquitto** is the actual broker. It only sits on `mqtt-network` (private, shared with `mqtt-exporter`) and `service-network` - Traefik-services proxies to it as a **TCP** router (`mqtt` entrypoint, `:1883`), the same way every other service here gets an HTTP router, just the TCP variant. It never talks to `monitoring-network`.
- **mqtt-exporter** ([kpetremann/mqtt-exporter](https://github.com/kpetremann/mqtt-exporter)) subscribes to `tele/+/SENSOR` on Mosquitto and exposes the parsed values as Prometheus gauges on its own `:9000/metrics` - no config file, everything is env vars. It has no persistent state and no GUI; the Traefik HTTP router on it is purely a convenience so you can browse `https://mqtt-exporter.${BASE_DOMAIN}/metrics` directly. Since it keeps nothing in memory across restarts, expect a metrics gap of up to one `TelePeriod` (default 300s) after any restart, until the plugs publish again.
- Both containers are multi-homed; each carries an explicit `priority` per network (`service-network: 100`, everything internal-only: `10`) so Docker picks one deterministic default route, matching the same pattern already used in `gitea`/`grist`/`outline`.

## Tasmota-side config

Both plugs (`tasmota-plug1` / `tasmota-plug2`) use Tasmota's **default Full Topic** (`%prefix%/%topic%/`), with a unique `Topic` each - giving telemetry topics `tele/tasmota_plug1/SENSOR` and `tele/tasmota_plug2/SENSOR`. That's already enough for `mqtt-exporter` to keep both plugs' metrics apart (it derives its `topic` label from the MQTT topic itself), so there's no need to prefix Full Topic with the device name.

Each plug authenticates with its own Mosquitto credential (`tasmota-plug1-user` / `tasmota-plug2-user`) rather than a shared login - Mosquitto's password file supports as many entries as needed, so this costs nothing extra.

- Host: `mqtt.${BASE_DOMAIN}`
- Port: `1883`

## Mosquitto auth setup

`mosquitto.conf` (in `files/`) sets `allow_anonymous false` and a `password_file` - no ACL file, since every client here is a known, trusted device on an isolated broker; anyone who authenticates gets full read/write.

Generate the password file locally (never type real passwords into a shared/agent-run shell - run this yourself, substituting your actual passwords for the two plugs and picking one for the exporter):

```bash
docker run --rm -v "$(pwd)/files:/mosquitto/config" eclipse-mosquitto:latest \
  mosquitto_passwd -b -c /mosquitto/config/passwd tasmota-plug1-user '<plug1-password>'
docker run --rm -v "$(pwd)/files:/mosquitto/config" eclipse-mosquitto:latest \
  mosquitto_passwd -b /mosquitto/config/passwd tasmota-plug2-user '<plug2-password>'
docker run --rm -v "$(pwd)/files:/mosquitto/config" eclipse-mosquitto:latest \
  mosquitto_passwd -b /mosquitto/config/passwd mqtt-exporter '<mqtt-exporter-password>'
```

(`-c` creates the file - only pass it on the first call, or it'll wipe existing entries.) Put the plug credentials into each plug's MQTT config (`User`/`Password` fields), and the exporter's into this module's `stack.env` as `MQTT_EXPORTER_USERNAME`/`MQTT_EXPORTER_PASSWORD`.

## Deploying

1. **External resources** (`../external-resources`): `mqtt-network` and the `mosquitto-data` volume are added to `project.auto.tfvars` - run `tofu plan`/`tofu apply` there first.
2. **Push config files to docker-vm** (`docker-management.my.world`, SSH as `core` with the usual key). First time only, create the directory yourself:
   ```bash
   ssh core@docker-management.my.world "sudo mkdir -p /mnt/data/mqtt"
   ```
   then push the files with `<simple-homelab root>/scripts/upload-mqtt-configs.sh` - also the script to re-run for any later config change that can't be done via `stack.env`.
3. **Turn on Traefik's MQTT entrypoint**: `../traefik/stack-services.env` now sets `TRAEFIK_ENTRYPOINTS_MQTT_ADDRESS=:1883` (the port was already reserved in `docker-compose-services.yml`, just unused until now) - redeploy/restart `traefik-services` to pick it up. This briefly interrupts every other Services-tier app fronted by it (e.g. Jellyfin) - do it in a low-traffic window.
4. **Deploy this stack** (`docker-compose.yml` + `stack.env`), same as any other `docker-apps` module.
5. **DNS**: not Pi-hole (retired from the DNS path) - add to OPNsense's own Unbound resolver instead. `docker-services.my.world` (`10.0.10.3`) is already a Host Override there, with every other Services-tier hostname (`jellyfin`, `gitea`, `grist`, ...) added as a Host Alias on that same record. Add two more Host Aliases the same way, both pointing at `docker-services.my.world`:
   - `mqtt`
   - `mqtt-exporter`
6. **OPNsense firewall rule** (IoT VLAN is default-deny). Create an alias `tasmota_plugs` containing `10.0.40.2/32` and `10.0.40.3/32`, then one IoT-interface rule: source `tasmota_plugs`, destination `10.0.10.3`, TCP port `1883`. One alias + one rule scales to more plugs later without adding more rules.
