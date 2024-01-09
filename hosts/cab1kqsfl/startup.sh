dir=/opt/RogueOS/service-containers/
docker compose -f $dir/novnc/docker-compose.yml up -d
docker-compose -f $dir/restreamer/docker-compose.yml --env-file $HOME/.env up -d
