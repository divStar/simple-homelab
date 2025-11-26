#!/bin/bash

# Parse command line arguments
DELETE_PROMETHEUS=false
DELETE_LOKI=false
DELETE_ALLOY=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --delete-prometheus-data)
      DELETE_PROMETHEUS=true
      shift
      ;;
    --delete-loki-data)
      DELETE_LOKI=true
      shift
      ;;
    --delete-alloy-data)
      DELETE_ALLOY=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--delete-prometheus-data] [--delete-loki-data] [--delete-alloy-data]"
      exit 1
      ;;
  esac
done

# Stop containers
echo "Stopping containers..."
docker compose --env-file stack.env down

# Delete and recreate volumes if requested
if [ "$DELETE_PROMETHEUS" = true ]; then
  echo "Deleting Prometheus data..."
  docker volume rm prometheus-data 2>/dev/null || echo "Volume prometheus-data does not exist, skipping..."
  docker volume create prometheus-data
  echo "Prometheus data volume recreated"
fi

if [ "$DELETE_LOKI" = true ]; then
  echo "Deleting Loki data..."
  docker volume rm loki-data 2>/dev/null || echo "Volume loki-data does not exist, skipping..."
  docker volume create loki-data
  echo "Loki data volume recreated"
fi

if [ "$DELETE_ALLOY" = true ]; then
  echo "Deleting Alloy data..."
  docker volume rm alloy-data 2>/dev/null || echo "Volume alloy-data does not exist, skipping..."
  docker volume create alloy-data
  echo "Alloy data volume recreated"
fi

# Inline configs
echo "Inlining configurations..."
./inline-configs.sh

# Start containers
echo "Starting containers..."
docker compose --env-file stack.env up -d

echo "Done!"