#! /bin/bash
#set -ex

######## Add env vars if not sourced ###############
(return 0 2>/dev/null) && sourced=true || sourced=false
if ! $sourced; then
 script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
 source "$script_dir/env"
 unset script_dir
fi


DEVELOPER_TOOLS=false
DESKTOP=false
RESTART=false

file=$rogue_wdir/hosts/$machine_name/env
[[ -f "$file" ]] && source "$file"
unset file

env_file=$1
if [ -f "$env_file" ]; then
  set -a; source $env_file; set +a
fi


################################### Functions ##########################################
function header () {
 echo -e "RogueOs[config]  $1"
}

prompt() {
  message="$1"
  while true; do
    if ! [ -z "$2" ]; then
      yn="$2"
    else
      read -p "$message " yn
    fi
      case $yn in
          [Yy][Ee][Ss]* )
            return ;;
          [Nn][Oo]* )
            return 1 ;;
          [Cc][Aa][Nn][Cc][Ee][Ll]* )
            return 2 ;;
          [Ee][Xx][Ii][Tt]* )
            echo "user exit"
            exit 0 ;;
          * )
          echo "Please answer yes,no,cancel or exit."
          if ! [ -z "$2" ]; then
            echo "Invalid response. Program exiting now"
            exit 1
          fi;;  
      esac
  done
}

#############################################################################
header "Configuring $machine_name"
#get secrets from keyvault
#todo use memory for secret storage
#mount -o size="$secrets_size" -t tmpfs none /mnt/RogueOS/secrets 
if prompt "Do you wish to set environment secrets? " "$set_environment_secrets"; then
  if ! source $rogue_wdir/cli/secrets.sh "rogue_secrets:$machine_name"; then
    header "Did not set environment secrets. An error occured. Exiting now"
    exit 1
  fi
else
    header "using old secrets" 
fi

#install kasmvnc
if prompt "Do you want to install kasmvnc?" "$install_kasmvnc"; then
  echo "You can find the kasm_vnc package for your distro at https://github.com/kasmtech/KasmVNC/releases":
  read -p "Enter the url to your kasmvnc install or accept the default bookworm 1.3.1: " kasmvnc_url
  kasmvnc_url=${kasmvnc_url:-https://github.com/kasmtech/KasmVNC/releases/download/v1.3.1/kasmvncserver_bookworm_1.3.1_amd64.deb}
  echo $name

  wget "${kasmvnc_url}"

  if command -v apt &> /dev/null; then
    sudo apt-get install ./kasmvncserver_*.deb
   
    # Add your user to the ssl-cert group
    sudo addgroup $USER ssl-cert
   elif command -v dnf &> /dev/null; then
    # Ensure KasmVNC dependencies are available
    sudo dnf config-manager --set-enabled ol8_codeready_builder
    sudo dnf install oracle-epel-release-el8
    
    sudo dnf localinstall ./kasmvncserver_*.rpm
    
    # Add your user to the kasmvnc-cert group
    sudo usermod -a -G kasmvnc-cert $USER
   elif command -v yum &> /dev/null; then
    # Ensure KasmVNC dependencies are available
    sudo yum install epel-release
    
    sudo yum install ./kasmvncserver_*.rpm
    
    # Add your user to the kasmvnc-cert group
    sudo usermod -a -G kasmvnc-cert $USER
   fi
   rm *kasmvncserver_*
fi



#create template json for jinja2 interpolation
#https://stackoverflow.com/questions/74556998/create-json-of-environment-variables-name-value-pairs-from-array-of-environment
arr=($(tr '\n' ' ' <  <(printenv  | sed 's;=.*;;')))
env_json=$(jq -n '$ARGS.positional | map({ (.): env[.] }) | add' --args "${arr[@]}")

python3 -m pip install jinja2-cli


if [ "$linux_distro" = "mac" ]; then
  header "installing Mac software"
  brew upgrade || true
  brew upgrade --cask || true
  
  if [ -z "$ssh_subdomain" ]; then 
    echo "!!!warning!!!"
    echo "RogueOS has no ssh_subdomain RogueOS can not set a ssh_subdomain"
    echo "!!warning!!!"
  else
    brew install cloudflared
    if ! grep -q "Host $ssh_subdomain" ~/.ssh/config; then
      cat > ~/.ssh/config <<EOF
      Host $ssh_subdomain
      ProxyCommand /opt/homebrew/bin/cloudflared access ssh --hostname %h
EOF
    fi
  fi

  header "install hooks"
  #startup
  #jinja2 /opt/RogueOS/util/mac/startup.plist.jinja "$env_json" > /System/Library/LaunchAgents
  #login
  sudo cp $rogue_wdir/distro-configs/$linux_distro/Library/LaunchDaemons/com.startup.sysctl.plist /Library/LaunchDaemons/
else
  header "installing Linux software"

  header "Current Config is _____"

  if [ "$motherboard_arch" = "raspberry pi" ]; then
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
  sudo mkdir -p /etc/apt/keyrings
  REPO="$linux_distro" #known values are rasbian and ubuntu others expected to work based on the $linux_distro var detemined from /etc/os-release #ID var
  curl -fsSL https://download.docker.com/linux/$REPO/gpg | sudo gpg --dearmor --yes --output /etc/apt/keyrings/docker.gpg
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
  if [ ${processor_arch} == 'arm' ]; then
    sudo apt-get install -y qemu-system-arm
  else
    sudo apt-get install -y qemu qemu-user-static
  fi

  #add ssh
  #chedk if an sshd is running
  if [ -z "$(ps -aux | grep sshd)" ]; then
    sudo apt update
    sudo apt install -y openssh-server
    sudo service ssh start
    sudo systemctl enable ssh
    sudo ufw allow ssh
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

    #TODO use the docker container
    # header 'Install guacamole'
    # git clone "https://github.com/boschkundendienst/guacamole-docker-compose.git"
    # cd guacamole-docker-compose
    # $(./prepare.sh)
    # #docker-compose up -d
    # cd -
    
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

$rogue_wdir/cli/service.sh init

$rogue_wdir/cli/service.sh startup


if [ "$RESTART" = true ]; then
  header "RogueOS will now restart the computer"
  for i in {0..10}; do echo -ne "$i"'\r'; sleep 1; done; echo 
  sudo shutdown -r now
elif [ ${DESKTOP} = true ]; then
  header "RogueOS will now start the grafix session"
  for i in {0..10}; do echo -ne "$i"'\r'; sleep 1; done; echo 
  #Start xserver
  if command -v startx &> /dev/null; then
    startx &
  else
    sway &
  fi
fi

rm -rf "$env_file"
header "RogueOS is now configured"
