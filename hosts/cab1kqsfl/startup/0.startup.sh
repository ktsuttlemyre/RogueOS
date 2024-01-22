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
python3 -m pip install --upgrade pip

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



