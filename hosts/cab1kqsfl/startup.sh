run_dir='/opt/RogueOS/service-containers'
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

#do all updates on startup
echo "Updating system"
brew upgrade
brew upgrade --cask

echo "Cleaning old videos from $video_dir"
# check old streams storage and limit the folder size
# 250 gb hdd
# 213.53gb after os and rogueos
# lets limit stream folder to 140gb
video_dir="$HOME/Movies"
max_folder_size="140"
#this could be faster but meh
while [ "$(du -gs "$video_dir" 2> /dev/null | cut -f1)" -gt "$max_folder_size" ]; do
	rm -- "$(ls -rt | head -n 1)"
done

echo "Starting RogueOS services"
#start services
docker compose -f $run_dir/novnc/docker-compose.yml up -d
docker compose -f $run_dir/restreamer/docker-compose.yml up -d
docker compose -f $run_dir/cloudflared/docker-compose.yml --env-file $HOME/.env up -d

echo "Starting obs"
obs --startstreaming --profile 'KQSFL' --scene "UnattendedKQSFL" --disable-updater --disable-shutdown-check &
$run_dir/restreamer/record_when_streaming.sh 'https://cab1.tildestar.com' 'unsure what to watch' &


echo "watching for battery usage and will shut down at target battery level"
/opt/RogueOS/scripts/shutdown_when_battery_power.sh '80' '600' '10' &
