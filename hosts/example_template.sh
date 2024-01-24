#!/bin/bash


#get script dir
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#add rogue vars
#source $script_dir/.env" # if you are in the root of script_dir
#source "$(dirname $script_dir)/.env" if this goes up one parent of script_dir

[ -f $script_dir/env ] && source "$script_dir/env"
#unset script_dir

#add secrets
source "$secrets/env"




original_pwd=$PWD

#build special service containers
$rogue_wdir/scripts/apply_services.sh $script_dir/services.yml
