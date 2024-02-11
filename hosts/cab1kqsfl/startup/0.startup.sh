#!/bin/bash
set -ex

uptime=''
if [ -f /proc/uptime ]; then
	uptime=$(cut -d '.' -f1 /proc/uptime)
else
	uptime=$(sysctl -n kern.boottime | cut -c14-18)
fi
if test "$uptime" -gt 1800 ; then
  echo "Skipping update as this isn't a cold boot"
  exit 1
fi

echo "Updating System"
if command -v brew &> /dev/null; then
	echo "Updating Brew"
  brew upgrade
	brew upgrade --cask
fi
python3 -m pip install --upgrade pip


echo "Cleaning old videos from $video_dir"
video_dir="$HOME/Movies"
# check old streams storage and limit the folder size
# 250 gb hdd
# 213.53gb after os and rogueos
# lets limit stream folder to 120gb
max_folder_size="120"
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



