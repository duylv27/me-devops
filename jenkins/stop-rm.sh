#!/bin/bash
if [ -z "$1" ]; then
  echo "Usage: $0 <container_id>"
  exit 1
fi

CONTAINER_ID="$1"
docker stop "$CONTAINER_ID"
docker rm "$CONTAINER_ID"
