#!/bin/bash

docker compose --env-file stack.env down outline
docker volume rm outline-data
docker volume rm outline-db-data
docker volume rm outline-redis-config
docker volume create outline-data
docker volume create outline-db-data
docker volume create outline-redis-config
docker compose --env-file stack.env up -d