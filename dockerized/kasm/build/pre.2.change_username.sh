#!/bin/bash
new="${1:rogue}"
current="${2:-USER}"

sudo usermod -l "$new" "$current"
sudo groupmod -n "$new" "$current"
sudo usermod -d /home/$new -m "$new"
#cp $HOME/* /home/$new/
