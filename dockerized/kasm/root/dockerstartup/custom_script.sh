#!/bin/bash
#disabled for now
exit 0
#TODO run RSYNC to rogueos_data

#SYMLINK only things that will sync
files=(/rogueos_data/$host_name/$user_name/*)
ARRAY+=('/rogueos_data/$host_name/$user_name/.config/obs-studio')
ARRAY+=('/rogueos_data/$host_ name/$user_name/.config/rclone')

for file in "${files[@]}"; do
  if [[ $file = .* ]]; then
    continue
  fi
  ln -s $file /home/kasm-user/$file
done
