#!/bin/bash

#TODO watch the heat send discord message if too high
#normal 40-60c
#high 70-80c
#above 81 turn off? idk

echo "watching for battery usage and will shut down at target battery level"
$rogue_wdir/scripts/shutdown_when_battery_power.sh '80' '600' '10' &

$rogue_wdir/scripts/discord_alert.sh info "Ready to stream baby!"