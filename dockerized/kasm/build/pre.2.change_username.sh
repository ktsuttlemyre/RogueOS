#!/bin/bash
new="${1:rogue}"
current="${2:-kasm-user}"

usermod -l "$new" "$current"
groupmod -n "$new" "$current"
usermod -d /home/$new -m "$new"
#cp $HOME/* /home/$new/
