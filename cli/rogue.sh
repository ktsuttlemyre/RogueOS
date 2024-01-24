#!/bin/bash
action=$1

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$(dirname $script_dir)/env"


if [ -f $rogue_wdir/$action.sh ]; then
	script=$rogue_wdir/$action.sh "${@:2}"
fi


#sudo protected and quaranteend to rogueos user:-D
#/bin/su -s /bin/bash -c $script --login rogueos
#TODO create the rogueos user and force all runtimes to be handled by them
$script