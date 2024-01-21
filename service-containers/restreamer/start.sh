#!/bin/bash
host_name="${1:-$(hostname | cut -d. -f1)}"
echo "$HOME"
export restreamer_http=80
export restreamer_https=443
export restreamer_rtmp=1935
export restreamer_rtmps=1936
export restreamer_srt=6000
docker compose --env-file $HOME/.env config
