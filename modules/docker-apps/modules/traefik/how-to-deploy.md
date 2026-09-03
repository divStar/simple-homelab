# How to deploy

This stack defines **two** Traefik instances in one `docker-compose.yml` - `traefik-management` (Management VLAN,
`10.0.5.7`) and `traefik-services` (Services VLAN, `10.0.10.3`). Each only picks up containers carrying its own
`traefik-tier` label (`management`/`services`), via `TRAEFIK_PROVIDERS_DOCKER_CONSTRAINTS`.

Deploy (or redeploy after a config change) with two **separate** commands, one per service:

```bash
docker compose -f docker-compose.yml --env-file stack.env --env-file stack-management.env up -d traefik-management
docker compose -f docker-compose.yml --env-file stack.env --env-file stack-services.env up -d traefik-services
```

## Why two commands, not one

`stack.env` holds the values shared by both instances (domain, entrypoints, ACME email/CA server, plugin config).
`stack-management.env`/`stack-services.env` hold the handful of values that must differ between them
(`TRAEFIK_PROVIDERS_DOCKER_NETWORK`, `TRAEFIK_PROVIDERS_DOCKER_CONSTRAINTS`,
`TRAEFIK_CERTIFICATESRESOLVERS_STEPCA_ACME_STORAGE`).

`docker compose`'s `--env-file` is **project-global, not per-service** - passing both per-instance env files in one
`up` invocation makes the last file's values win for *both* services, silently overriding one instance's network/
constraint/ACME-storage with the other's (confirmed live: doing this handed `traefik-management` the Services
network and constraint). Running two separate commands, each naming only its own target service and only its own
env files, keeps the two instances' values from leaking into each other.

Never run a bare `up -d` (no service name) with both per-instance env files passed together.
