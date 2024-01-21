#!/bin/bash

#add rogue vars
source /opt/RogueOS/.env
#add host vars
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
[ -f $script_dir/.env ] && source "$script_dir/.env"
#unset script_dir
#add secrets


original_pwd=$PWD

#install software for this computer
npm install --global obs-cli
brew install discord --cask

npm install any-json -g