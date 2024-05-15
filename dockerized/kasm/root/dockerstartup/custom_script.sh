#!/bin/bash

files=(/home/rogue_os/$user_name/*)
ARRAY+=('/home/rogue_os/$user_name/.config/obs-studio')
ARRAY+=('/home/rogue_os/$user_name/rclone')

for file in "${files[@]}"; do
  if [[ $file = .* ]]; then
    continue
  fi
  ln -s $file /home/kasm-user/$file
done
