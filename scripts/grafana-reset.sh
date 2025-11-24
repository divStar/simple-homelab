#!/bin/bash

docker compose --env-file stack.env down
docker volume rm grafana-data
docker volume create grafana-data
docker compose --env-file stack.env up -d