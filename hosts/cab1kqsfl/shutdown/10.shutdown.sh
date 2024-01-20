run_dir='/opt/RogueOS/service-containers'
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
home=${HOME:-'/home/kqsfl'}

source $home/.env

#shutdown obs gracefully
obs-cli -H 'localhost' -P 4455 -p $obs_websocket_password stream stop
obs-cli -H 'localhost' -P 4455 -p $obs_websocket_password record stop
sleep 60
pkill -INT OBS

#stop services
docker compose -f $run_dir/novnc/docker-compose.yml down
docker compose -f $run_dir/restreamer/docker-compose.yml down
docker compose -f $run_dir/cloudflared/docker-compose.yml --env-file $HOME/.env down



#sudo shutdown now