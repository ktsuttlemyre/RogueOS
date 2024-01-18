#!/bin/bash
source /opt/RogueOS/.env
docker-compose -f /service-containers/novnc/docker-compose.yml build
