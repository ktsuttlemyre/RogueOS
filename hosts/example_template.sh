#!/bin/bash

#add rogue vars
source /opt/RogueOS/.env
#add host vars
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
[ -f $script_dir/.env ] && source "$script_dir/.env"
#unset script_dir
#add secrets




original_pwd=$PWD

#build special service containers
$rogue_wdir/scripts/apply_services.sh $script_dir/services.yml
