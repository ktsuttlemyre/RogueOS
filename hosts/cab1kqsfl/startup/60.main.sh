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


echo "Starting obs"
obs --startstreaming --profile 'KQSFL' --scene "UnattendedKQSFL" --disable-updater --disable-shutdown-check &
#$service_wd/restreamer/record_when_streaming.sh 'https://cab1.tildestar.com' 'unsure what to watch' &


#TODO watch the heat send discord message if too high
#normal 40-60c
#high 70-80c
#above 81 turn off? idk

echo "watching for battery usage and will shut down at target battery level"
/opt/RogueOS/scripts/shutdown_when_battery_power.sh '80' '600' '10' &

$rogue_wdir/scripts/discord_alert.sh info "Ready to stream baby!"