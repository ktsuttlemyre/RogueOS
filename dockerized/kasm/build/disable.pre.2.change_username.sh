#!/bin/bash
new="${1:-rogue}"
current="${2:-$USER}"
current="${current:-kasm-user}"

usermod -l "$new" "$current"
groupmod -n "$new" "$current"
usermod -d /home/$new -m "$new"
#cp $HOME/* /home/$new/
ln -s /home/$new /home/$current
