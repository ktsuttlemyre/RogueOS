#!/bin/bash
host_name="${1:-$(hostname | cut -d. -f1)}"
docker compose --env-file ~/.env up
