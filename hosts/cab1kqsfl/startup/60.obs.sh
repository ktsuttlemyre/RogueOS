#!/bin/bash
set -ex
#
#
#
#TODO https://github.com/EnriqueMoran/remoteDiscordShell


echo "Starting obs"
#obs --disable-updater --disable-shutdown-check --startstreaming --profile 'KQSFL' --scene "UnattendedKQSFL"  &
#$service_wd/restreamer/record_when_streaming.sh 'https://cab1.tildestar.com' 'unsure what to watch' &

~/Applications/OBS1/obs --portable --disable-updater --disable-shutdown-check &
#--profile 'KQSFL' --scene "UnattendedKQSFL --startstreaming"
~/Applications/OBS2/obs --portable --disable-updater --disable-shutdown-check &
