#!/bin/bash

script_name=$(basename "$0")
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#do not use this because it will cause all these values to be sent to terminal
#set -a      # turn on automatic exporting
source "$(dirname $script_dir)/env"
[ -f "$host_wd/env" ] && source "$host_wd/env"
#set +a      # turn off automatic exporting


#how to call
#opts=( $OPTS )
#my-command "${opts[@]}"

( # Wait for lock on /tmp/batteryshutdown.lock (fd 200) for 1 seconds
    flock -x -w 1 200 || exit 1

    #todo run as rogueos
    #todo make this a function call and check for schedule and job seperate
    cronschedule="*/10 *  *  *  *"
    cronuser=""
    cronjob="$cronschedule $script_dir/$script_name"
    $rogue_wdir/cli/cron set "$cronschedule" "$cronuser" "$cronjob"

	target_battery="${1:-${battery_shutdown_percentage:-75}}"
	how_long_to_wait="${2:-${battery_shutdown_percentage:-10}}"
	force_shutdown_percentage="${3:-${battery_shutdown_percentage:-15}}"

	power_state=$(pmset -g ps|sed -nE "s|.*'(.*) Power.*|\1|p")
	if [ "$power_state" = "Battery" ]; then
		battery_percent=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
		echo "$power_state and at $battery_percent"
		if [ "$battery_percent" -lt "$target_battery" ]; then
			if [ -f /opt/RogueOS/batteryshutdown ]; then
				g="$(( $(date '+%s') -  $(date -r /opt/RogueOS/batteryshutdown '+%s') ))"
			fi
			if osascript -e "tell app \"System Events\" to display dialog \"On battery mode. Shutting down unless user input detected\" giving up after 600"; then
				touch /opt/RogueOS/batteryshutdown
			else
				if [ -f /opt/RogueOS/batteryshutdown ]; then
					rm /opt/RogueOS/batteryshutdown
				fi
			fi
		fi
	else
		echo "$power_state"
	fi

) 200>/tmp/batteryshutdown.lock





