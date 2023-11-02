##### Install rasp-config #####
#https://elbruno.com/2022/09/02/raspberrypi-install-raspi-config-on-ubuntu-22-04-1-lts/
sudo apt-get install -y raspi-config
#echo "deb http://archive.raspberrypi.org/debian/ buster main" >> /etc/apt/sources.list
#apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7FA3303E
sudo raspi-config

##### Install window manager #####
#https://www.adamlabay.net/2019/08/10/raspberry-pi-4-kodi-and-chrome-an-uncomfortable-alliance/
apt update & sudo apt install -y xinit i3 dmenu suckless-tools
#Add i3 to our xinit.rc file so startx will run i3
echo "exec i3" > .xinit.rc

#Start xserver
startx

#run raspi-config-> boot, select auto login desktop

##### Install kodi and chrome #####
apt install -y kodi chromium-browser seahorseexit


##### Download Advanced Launcher by typing
wget https://github.com/SpiralCut/plugin.program.advanced.launcher/archive/master.zip
Type nano chromium.sh and enter the following file contents:
#! /bin/bash
#chromium-browser --user-agent="Mozilla/5.0 (X11; CrOS armv7l 10895.56.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.102 Safari/537.36" --window-size=1920,1080 $1

Return to the pi and open Kodi. Install Advanced Launcher.
Navigate to Add-ons | Add-On Browser (the open box at the top next to the Settings gear)
