#!/bin/bash

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$script_dir/env"


rm -rf $rogue_wdir

#TODO remove all hooks

#TODO stop all services

#TODO restart to ensure everything is cleaned up

while true; do
    read -p "It is suggested you restart computer to complete uninstall continue? " yn
    case $yn in
        [Yy][Ee][Ss]* )
			echo "Restarting"
			#get github token
			sudo shutdown -r now
			break;;
        [Nn][Oo]* ) break ;;
        * ) echo "Please answer yes or no.";;
    esac
done
