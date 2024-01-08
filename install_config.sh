#! /bin/bash
#set -o pipefail
host_name="${1:-$(hostname | cut -d. -f1)}"


#get secrets
source ./scripts/rogue_secrets.sh "rogue_secrets:$host_name"


DEVELOPER_TOOLS=false
DESKTOP=false
RESTART=false

file=./hosts/$host_name/init.env
[[ -f "$file" ]] && source "$file"

# check if it is a raspberry pi
BOARD=false
if [ -x "$(command -v python)" ] ; then
  R_PI=`python -c "import platform; print('-rpi-' in platform.uname())"`
  if [ "$BOARD" = "True" ] ; then
    BOARD='PI'
  fi
else
  echo "Python not installed"
  exit 1
fi
#load os vars for identification
. /etc/os-release
DISTRO=false
if [ -z ${ID+x} ]; then 
  ID="$(uname -s)"
fi

case "$ID" in
  raspbian) DISTRO="raspbian" ;;
  ubuntu) DISTRO="ubuntu" ;;
  arch) DISTRO="arch" ;;
  centos) DISTRO="centos" ;;
  Darwin*) DISTRO=mac;
  *) echo "This is an unknown distribution. Value observed is $ID"
      ;;
esac

if [ "$DISTRO" = "mac" ]; then
  echo "installing Mac software"
  echo "install hooks"
  #startup
  #jinja /opt/RogueOS/util/mac/startup.plist.jinja > /System/Library/LaunchAgents
  #login
  

else
  echo "installing Linux software"
  ARCH='arm'
  BITS='32'
  case $(uname -m) in
      i386)   ARCH="x86"; BITS="32" ;;
      i686)   ARCH="x86"; BITS="32" ;;
      x86_64) ARCH="x86"; BITS="64" ;;
      arm)    dpkg --print-architecture | grep -q "arm64" && ARCH="arm" && BITS="64" ;;
  esac

  function header () {
   echo "##############"
   echo "$1"
  }

  header "Install script has determined you are running Hardware Board = ${BOARD} \n DISTRO = ${DISTRO} \n ARCH = ${ARCH} \n BITS = ${BITS}"
  header "Current Config is _____"

  if [ "$BOARD" = "PI" ]; then
    ##### Install rasp-config #####
    #https://elbruno.com/2022/09/02/raspberrypi-install-raspi-config-on-ubuntu-22-04-1-lts/
    #install in subshell cause whiptail not responding to inputs on ubuntu server 32 bit when ran from wget -O - <url> | bash
    header 'Installing raspi-config'
    $(sudo apt-get install -y raspi-config)
    #echo "deb http://archive.raspberrypi.org/debian/ buster main" >> /etc/apt/sources.list
    #apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7FA3303E
    
    #automate rasberry pi config
    # https://raspberrypi.stackexchange.com/questions/28907/how-could-one-automate-the-raspbian-raspi-config-setup
    #sudo raspi-config
  fi

  header 'remove docker for official build'
  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
  #add repo
  # Add Docker's official GPG key:
  sudo apt-get update
  sudo apt-get install ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  REPO="$DISTRO" #known values are rasbian and ubuntu others expected to work based on the $DISTRO var detemined from /etc/os-release #ID var
  curl -fsSL https://download.docker.com/linux/$REPO/gpg | sudo gpg --dearmor --output - > /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  # Add the repository to Apt sources:
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$REPO \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update

  header 'installing docker'
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo groupadd docker
  #Add the connected user "$USER" to the docker group. Change the user name to match your preferred user if you do not want to use your current user:
  sudo usermod -aG docker $USER
  getent group docker || newgrp docker || true #continue if group exits

  header 'docker emulation extentions'
  if [ ${ARCH} == 'arm' ]; then
    sudo apt-get install -y qemu-system-arm
  else
    sudo apt-get install -y qemu qemu-user-static
  fi

  if [ ${DESKTOP} = true ]; then
    header 'Install window manager'
    #https://www.adamlabay.net/2019/08/10/raspberry-pi-4-kodi-and-chrome-an-uncomfortable-alliance/
    apt update & sudo apt install -y xinit i3 dmenu suckless-tools
    #Add i3 to our xinit.rc file so startx will run i3
    echo "exec i3" > .xinit.rc
    
    #run raspi-config-> boot, select auto login desktop
    header 'Install kodi and chrome'
    sudo apt install -y kodi chromium-browser seahorse

    header 'Install guacamole'
    git clone "https://github.com/boschkundendienst/guacamole-docker-compose.git"
    cd guacamole-docker-compose
    $(./prepare.sh)
    #docker-compose up -d
    cd -
    
    ##### Download Advanced Launcher by typing
    #wget https://github.com/SpiralCut/plugin.program.advanced.launcher/archive/master.zip
    #Type nano chromium.sh and enter the following file contents:
    ##! /bin/bash
    #chromium-browser --user-agent="Mozilla/5.0 (X11; CrOS armv7l 10895.56.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.102 Safari/537.36" --window-size=1920,1080 $1
    
    #Return to the pi and open Kodi. Install Advanced Launcher.
    #Navigate to Add-ons | Add-On Browser (the open box at the top next to the Settings gear)
  fi

  if [ ${DEVELOPER_TOOLS} = true ]; then
    header 'developer tools'
    snap install sublime-text --classic
  fi
fi

./hosts/$host_name/init.sh

header "Is install script forcing restart? $RESTART"
for i in {0..10}; do echo -ne "$i"'\r'; sleep 1; done; echo 
if [ "$RESTART" = true ]; then
   sudo shutdown -r now
else
  #Start xserver
  if [ ${DESKTOP} = true ]; then
    if command -v startx &> /dev/null; then
      startx
    else
      sway
    fi
  fi
fi
