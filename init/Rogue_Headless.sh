#!/bin/bash
set -e 
set -o pipefail


sudo apt update
sudo apt -y full-upgrade
#################
#	Install 3rd party
#		wifi driver
#################
#https://www.raspberrypi.org/forums/viewtopic.php?t=192985


#sudo wget http://fars-robotics.net/install-wifi -O /usr/bin/install-wifi
#sudo chmod +x /usr/bin/install-wifi


################
#	install bridge
################
sudo apt install -y dnsmasq



######
# version control will be on at some point just do it
######
sudo apt install -y git


#oh-my-bash (themes)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
#set theme to zitron
../ROGUE REPLACE_BASH_VAR ~/.bashrc OSH_THEME random


echo "rebooting in "
for ((i=5; i>=1; i--)); do
	sleep 1
	echo -n "$i.."
done
sudo shutdown -r now