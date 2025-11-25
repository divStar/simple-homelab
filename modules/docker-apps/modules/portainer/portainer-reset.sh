#!/bin/bash

docker compose down portainer
docker volume rm portainer-data
docker volume create portainer-data
docker compose up -d
