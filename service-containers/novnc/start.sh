#!/bin/bash
source /opt/RogueOS/.env
export novnc_http=6080
docker-compose -f /service-containers/novnc/docker-compose.yml build
