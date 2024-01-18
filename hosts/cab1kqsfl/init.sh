#!/bin/bash

#install software for this computer
npm install --global obs-cli
brew install discord --cask

original_pwd=$PWD

#build special service containers
/opt/RogueOS/scripts/rogue_service.sh init novnc
/opt/RogueOS/scripts/rogue_service.sh init cloudflared
/opt/RogueOS/scripts/rogue_service.sh init restreamer


#set working directory back and close
cd $original_pwd