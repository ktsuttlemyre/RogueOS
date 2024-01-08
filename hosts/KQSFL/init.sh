#!/bin/bash

echo "Installing cab1kqsfl config"

cd 
git clone https://github.com/tiagostutz/docker-traefik-letsencrypt.git
cd ./docker-traefik-letsencrypt/tls
docker compose build

git clone https://github.com/ktsuttlemyre/RogueOS
cd ./RogueOS/instances/kqsfl_cab1
#all service_containers found at RogueOS/service_containers

../utils/runservices.sh

