!#/bin/bash
target_battery=${1:-'75'}
poll_interval=${2:-'600'} #seconds or 10 minutes
step_by=${3:-'10'}

while true; do
	power_state=$(pmset -g ps|sed -nE "s|.*'(.*) Power.*|\1|p")
	echo "$power_state"
	if [ "$power_state" = "Battery" ]; then
		battery_percent=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
		echo "$battery_percent"
		if [ "$battery_percent" -lt "$target_battery" ]; then
			if osascript -e "tell app \"System Events\" to display dialog \"On battery mode. Shutting down in $poll_interval seconds\" giving up after 600"; then
				echo "Shutting down"
				sleep $poll_interval
				$script_dir/shutdown.sh
				exit 0
			else
				target_battery="$((target_battery-step_by))"
			fi
		fi

	fi
	sleep $poll_interval
done