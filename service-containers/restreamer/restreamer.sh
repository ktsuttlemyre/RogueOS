#!/bin/bash
host_name="${1:-$(hostname | cut -d. -f1)}"
echo "$HOME"
docker compose --env-file $HOME/.env up
