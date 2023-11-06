##### Install rasp-config #####
#https://elbruno.com/2022/09/02/raspberrypi-install-raspi-config-on-ubuntu-22-04-1-lts/
#install in subshell cause whiptail not responding to inputs on ubuntu server 32 bit when ran from wget -O - <url> | bash
$(sudo apt-get install -y raspi-config)
#echo "deb http://archive.raspberrypi.org/debian/ buster main" >> /etc/apt/sources.list
#apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7FA3303E

#automate rasberry pi config
# https://raspberrypi.stackexchange.com/questions/28907/how-could-one-automate-the-raspbian-raspi-config-setup
#sudo raspi-config

####
# remove docker for official build
#
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
#add repo
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
#install
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

snap install sublime-text --classic

##### Install window manager #####
#https://www.adamlabay.net/2019/08/10/raspberry-pi-4-kodi-and-chrome-an-uncomfortable-alliance/
apt update & sudo apt install -y xinit i3 dmenu suckless-tools
#Add i3 to our xinit.rc file so startx will run i3
echo "exec i3" > .xinit.rc

#run raspi-config-> boot, select auto login desktop

##### Install kodi and chrome #####
apt install -y kodi chromium-browser seahorse


##### Download Advanced Launcher by typing
#wget https://github.com/SpiralCut/plugin.program.advanced.launcher/archive/master.zip
#Type nano chromium.sh and enter the following file contents:
##! /bin/bash
#chromium-browser --user-agent="Mozilla/5.0 (X11; CrOS armv7l 10895.56.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.102 Safari/537.36" --window-size=1920,1080 $1

#Return to the pi and open Kodi. Install Advanced Launcher.
#Navigate to Add-ons | Add-On Browser (the open box at the top next to the Settings gear)



#Start xserver
startx
