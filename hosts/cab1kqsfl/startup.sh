#!/bin/bash
set -ex
#
#
#
#TODO https://github.com/EnriqueMoran/remoteDiscordShell

#add rogue vars
source /opt/RogueOS/.env

#add host vars
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
[ -f $script_dir/.env ] && source "$script_dir/.env"

#add secrets
#TODO

echo "Updating system"
brew upgrade
brew upgrade --cask

video_dir="$HOME/Movies"
echo "Cleaning old videos from $video_dir"
# check old streams storage and limit the folder size
# 250 gb hdd
# 213.53gb after os and rogueos
# lets limit stream folder to 140gb
max_folder_size="140"
#this could be faster but meh
starting_size="$(du -gs "$video_dir" 2> /dev/null | cut -f1)"
num_vids=0
while [ "$(du -gs "$video_dir" 2> /dev/null | cut -f1)" -gt "$max_folder_size" ]; do
	rm -- "$(ls -rt | head -n 1)"
	((num_vids++))
done
if [ $num_vids -ne 0 ]; then
	final_size="$(du -gs "$video_dir" 2> /dev/null | cut -f1)"
	$rogue_wdir/scripts/discord_alert.sh info "Cleaned old videos folder $starting_size to $final_size deleting $num_vids videos"
fi

echo "Starting RogueOS services"
function docker_up () {
	IFS='_' read -r -a array <<< "$1"
	service="${array[0]}"
	id="${array[1]}"
	env="$2"
	yml="${3:-$rogue_wdir/hosts/$machine_name/$1.compose.yml}"
	docker compose -f "$service_wd/$service/docker-compose.yml" -f "$yml" --env-file "$env" config # -d
}

#start services
docker_up novnc $secrets/.env
docker_up nginx-proxy-manager

#docker compose -f $service_wd/novnc/docker-compose.yml up -d
#docker compose -f $service_wd/restreamer/docker-compose.yml up -d
#docker compose -f $service_wd/cloudflared/docker-compose.yml --env-file $HOME/.env up -d
exit 1

echo "Starting obs"
obs --startstreaming --profile 'KQSFL' --scene "UnattendedKQSFL" --disable-updater --disable-shutdown-check &
$service_wd/restreamer/record_when_streaming.sh 'https://cab1.tildestar.com' 'unsure what to watch' &


#TODO watch the heat send discord message if too high
#normal 40-60c
#high 70-80c
#above 81 turn off? idk

echo "watching for battery usage and will shut down at target battery level"
/opt/RogueOS/scripts/shutdown_when_battery_power.sh '80' '600' '10' &

$rogue_wdir/scripts/discord_alert.sh info "Ready to stream baby!"
