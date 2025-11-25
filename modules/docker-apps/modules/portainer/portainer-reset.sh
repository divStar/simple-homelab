#!/bin/bash

docker compose --env-file stack.env down portainer
docker volume rm portainer-data
docker volume create portainer-data
docker compose --env-file stack.env up -d