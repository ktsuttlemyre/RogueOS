#!/bin/bash
set -ex
#
#
#
#TODO https://github.com/EnriqueMoran/remoteDiscordShell


echo "Starting obs"
obs --startstreaming --profile 'KQSFL' --scene "UnattendedKQSFL" --disable-updater --disable-shutdown-check &
#$service_wd/restreamer/record_when_streaming.sh 'https://cab1.tildestar.com' 'unsure what to watch' &


