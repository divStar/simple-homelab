#!/bin/bash

docker compose --env-file stack.env down jellyfin
docker volume rm jellyfin-cache
docker volume rm jellyfin-config
docker volume create jellyfin-cache
docker volume create jellyfin-config
docker compose --env-file stack.env up -d