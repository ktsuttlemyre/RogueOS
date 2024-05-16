#!/bin/bash
#disabled for now
exit 0
#TODO run RSYNC to rogueos_data

#SYMLINK only things that will sync
SYMLINK_FILES='/rogueos_data/$host_name/$user_name/*'
files=($SYMLINK_FILES)
files+=('/rogueos_data/$host_name/$user_name/.config/obs-studio')
files+=('/rogueos_data/$host_ name/$user_name/.config/rclone')

for file in "${files[@]}"; do
  if [[ $file = .* ]]; then
    continue
  fi
  ln -s $file /home/kasm-user/$file
done
