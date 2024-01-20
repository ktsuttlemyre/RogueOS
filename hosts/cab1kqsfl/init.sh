#!/bin/bash

#add rogue vars
source /opt/RogueOS/.env
#add host vars
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$script_dir/.env"
#unset script_dir
#add secrets


#install software for this computer
npm install --global obs-cli
brew install discord --cask

original_pwd=$PWD

#build special service containers
$rogue_wdir/scripts/apply_services.sh $script_dir/services.yml
