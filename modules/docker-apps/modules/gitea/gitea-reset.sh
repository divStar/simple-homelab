#!/bin/bash

docker compose --env-file stack.env down
docker volume rm gitea-data
docker volume rm gitea-db-data
docker volume rm gitea-runner-data
docker volume create gitea-data
docker volume create gitea-db-data
docker volume create gitea-runner-data
docker compose --env-file stack.env up -d