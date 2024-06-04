#! /bin/bash
set -e
#set -x

#TODO figure out what minimmal install means
minimal_install=${minimal_install:-false}


echo "Installing Rogue OS. Some of the commands will need sudo access. Please grant sudo use."
#do a sudo command to get the password out of the way
sudo echo "Thank you for granting sudo privileges" || exit 1

env_file=$1
if [ -f "$env_file" ]; then
  set -a; source $env_file; set +a;
fi

#cant run in the dir we are going to install
os="RogueOS"
rogue_wdir="${rogue_wdir:-/opt/$os}"
if [[ ./ -ef "$rogue_wdir" ]] || [ "$PWD" = "$rogue_wdir" ] || [ "$(pwd)" = "$rogue_wdir" ]; then
  echo "Sorry, you can not run this installer from the Rogue install path $rogue_wdir"
fi

#force working directory to tmp
#_rogue_wdir="$rogue_wdir"
rogue_wdir=/tmp/RogueOS
mkdir -p /tmp/RogueOS
cd /tmp/RogueOS

################################### Functions ##########################################
function header () {
 echo -e "RogueOs[installer]  $1"
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


set_filepermissions () {
  old_pwd=$(pwd)
  cd "$rogue_wdir"

  
  
  #TODO create RogueOS user and chown all files and services
  # if [[ is mac os ]]; then
  # $rogue_wdir/scripts/adduser.mac.sh RogueOS
  # else
  # adduser RogueOS
  # fi
  # sudo chown -R RogueOS .
  the_user="${USER:-$SUDO_USER}"
  the_user="${the_user:-$LOGNAME}"
  the_user="${the_user:-$(id -n -u)}"
  
  sudo chown -R $the_user $rogue_wdir
  
  #allows only user (owner) to do all actions; group and other users are allowed only to read.
  sudo chmod -R 744 $rogue_wdir
  #make all .sh files excutible
  find $rogue_wdir -type f -iname "*\.sh" -exec sudo chmod +x {} \;


  #if we are in a git repo then update submodules
  if [ "$(git rev-parse --is-inside-work-tree)" = "true" ]; then
    echo "updating git submodules"
    git submodule update --init --recursive
    git submodule update --recursive
    git config core.filemode false
  fi


  ############################################################################################################
  header "Setting RogueEnvVars"
  #todo encrypt secrets somehow and feed it through in memory FS
  header "Writing host specific .env to $rogue_wdir/env"
  cat > $rogue_wdir/env <<EOF
  os="$os"
  rogue_wdir="$rogue_wdir"
  service_wd="$rogue_wdir/service-containers"
  host_wd="$rogue_wdir/hosts/$machine_name"
  machine_name="$machine_name"
  secrets="$HOME"
  secrets_size=".5G"
  linux_distro="$linux_distro"
  processor_arch="$processor_arch"
  processor_bits="$processor_bits"
  ramdisk="$ramdisk"
EOF

  
  cd "$old_pwd"

}

###########################################################################################################
header "preparing this environment to become Rogue"
# check if it is a raspberry pi
motherboard_arch=false
if [ -x "$(command -v python3)" ] ; then
  uname=`python3 -c "import platform; print(platform.uname())"`
  case $uname in
    *"-rpi-"*)
        motherboard_arch="raspberry pi";;
    *"-valve"*)
      motherboard_arch="steamdeck";;
    *)
        motherboard_arch="$uname"
        echo "Unknown motherboard_arch $uname";;
  esac
else
  header "found that Python3 not installed"
  exit 1
fi
#load os vars for identification
if [ -f /etc/os-release ]; then
  source /etc/os-release
else
  #TODO don't do this
  source /dev/stdin <<< "$(curl -s https://raw.githubusercontent.com/ktsuttlemyre/RogueOS/master/scripts/os-release.sh)"
fi

linux_distro=false
[ -z ${ID+x} ] && ID="$(uname -s)"

case "$ID" in
  raspbian) linux_distro="raspbian" ;;
  ubuntu) linux_distro="ubuntu" ;;
  arch) linux_distro="arch" ;;
  centos) linux_distro="centos" ;;
  Darwin*) linux_distro="mac" ;;
  steamos) linux_distro="steamos" ;;
  *) echo "This is an unknown distribution. Value observed is $ID";;
esac

if [ ! "$linux_distro" = "mac" ]; then
  processor_arch='arm'
  processor_bits='32'
  case $(uname -m) in
      i386)   processor_arch="x86"; processor_bits="32" ;;
      i686)   processor_arch="x86"; processor_bits="32" ;;
      x86_64) processor_arch="x86"; processor_bits="64" ;;
      arm)    dpkg --print-architecture | grep -q "arm64" && processor_arch="arm" && processor_bits="64" ;;
  esac
fi

header "Install script has determined you are running\n\tmotherboard_arch = ${motherboard_arch} \n\tlinux_distro = ${linux_distro} \n\tprocessor_arch = ${processor_arch} \n\tprocessor_bits = ${processor_bits}"

if [ ! "$linux_distro" = "steamos"]; then
  if ! prompt "This is a steamdeck. It is suggested you install RogueOS to distrobox. Do you wish to continue?" $install_on_steamdeck_as_host; then
    echo "exiting"
    exit 0
  fi
fi



if [ "$linux_distro" = "mac" ]; then
  # install brew
  if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    ! $minimal_install && sudo apt upgrade
    sudo apt update
    #sudo dpg --configure -a
    #In practice that means it provides some useful scripts for adding and removing PPAs:
    ! $minimal_install && sudo apt install -y software-properties-common
    sudo apt autoremove
  fi
fi


install_mpm () {
  command -v brew &> /dev/null && brew install meta-package-manager && return 0
  command -v pipx &> /dev/null && pipx install meta-package-manager && return 0
  command -v python &> /dev/null && python -m pip install meta-package-manager && return 0
  command -v python3 &> /dev/null && python3 -m pip install meta-package-manager && return 0
  command -v pip &> /dev/null && pip install meta-package-manager && return 0
  command -v pip3 &> /dev/null && pip3 install meta-package-manager && return 0
  command -v pacaur &> /dev/null && pacaur -S meta-package-manager && return 0
  command -v pacman &> /dev/null && pacman -S meta-package-manager && return 0
  command -v paru &> /dev/null && paru -S meta-package-manager && return 0
  command -v yay &> /dev/null && yay -S meta-package-manager && return 0
  command -v pacaur &> /dev/null && pacaur -S meta-package-manager && return 0
  return 1
}

if install_mpm; then
  header 'mpm installed'
else
  exit 1
fi 

ramdisk=''
if [ "$linux_distro" = "mac" ]; then
  ramdisk="/Volumes/RogueOSRam"
  brew upgrade || true
  brew upgrade --cask || true

  #https://superuser.com/questions/1480144/creating-a-ram-disk-on-macos
  brew install entr
else
  ramdisk="/mnt/RogueOSRam"
fi



#force latest
#if ! command -v git &> /dev/null; then
  if [ "$linux_distro" = "mac" ]; then
    brew install git
  else
    sudo apt-get install -y git
  fi
#fi

#create alias
#type python >/dev/null 2>&1 || alias python=python3

#type pip >/dev/null 2>&1 || alias pip=pip3

########################################################################
header "setting up nodejs"
#dependencies
if [ "$linux_distro" == "mac" ]; then
  brew install node jq yq
else
  #todo check version
  if ! command -v nvm &> /dev/null; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # this loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # this loads nvm bash completion
  fi
  
  if command -v node &> /dev/null; then
    node_version=$(node -v)
    
    # "node -v" outputs version in the format "v18.12.1"
    node_version=${node_version:1} # Remove 'v' at the beginning
    node_version=${node_version%\.*} # Remove trailing ".*".
    node_version=${node_version%\.*} # Remove trailing ".*".
  else
    node_version='1'
  fi
  node_version=$(($node_version)) # Convert the NodeJS version number from a string to an integer.

  if [ $node_version -lt 21 ]; then
     nvm install node
  fi
  if ! command -v yq &> /dev/null; then
    sudo add-apt-repository ppa:rmescandon/yq
  fi
  sudo apt update
  sudo apt-get install -y jq yq
fi


if ! command -v bw &> /dev/null; then
  npm install -g @bitwarden/cli
fi

################################### Repo and install management ###################################
header "Repo and installation linking"
repo="ktsuttlemyre/RogueOS/"
host="$(hostname)"
host="$(scutil --get ComputerName 2>/dev/null || uname -n || ${host%%.*})"
machine_name=${machine_name:-$host}
branch="$machine_name"
install_privileges="${install_privileges:-ro}"

#restore workdir
#rogue_wdir="$_rogue_wdir"
#if already installed then ask to delete and replace
if [ -d "$rogue_wdir" ]; then
  if prompt "Do you wish to replace the current RogueOS? located at $rogue_wdir? " $replace_old_rogue; then
      sudo rm -rf $rogue_wdir;
  else
    echo "exiting"
    exit 0
  fi
fi

sudo mkdir $rogue_wdir
if curl -ss "https://api.github.com/repos/${repo}branches/${branch}" | grep '"message": "Branch not found"' ; then
  #curl -LkSs "https://api.github.com/repos/${repo}tarball/" | sudo tar xz --strip=1 -C $rogue_wdir
  git clone https://github.com/ktsuttlemyre/RogueOS.git $rogue_wdir
  set_filepermissions
  echo "You do not have a branch for this host: $branch"
  if prompt "Do you wish to create ${branch} now? " "$create_branch"; then
    while [ -z "${github_public_key_rw}" ]; do
      source $rogue_wdir/cli/secrets.sh 'user_tokens'
    done
    TOKEN="$github_public_key_rw" #this comes from rogue_secrets
    Previous_branch_name='master'
    New_branch_name="$branch"

    SHA=$(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/repos/${repo}git/refs/heads/${Previous_branch_name}" | jq -r '.object.sha')

    curl -s -X POST -H "Authorization: token $TOKEN" \
    -d  "{\"ref\": \"refs/heads/$New_branch_name\",\"sha\": \"$SHA\"}"  "https://api.github.com/repos/${repo}git/refs"
    sudo rm -rf $rogue_wdir;
    sudo mkdir $rogue_wdir
  else
    echo "Using master branch in read only mode"
    branch='' # blank means use master branch
    install_privileges='ro'
  fi
fi
#Install branch or master branch (handles fallback to master gracefully) 
#curl -LkSs "https://api.github.com/repos/${repo}tarball/${branch}" | sudo tar xz --strip=1 -C $rogue_wdir
sudo git clone https://github.com/ktsuttlemyre/RogueOS.git -b "${branch}" $rogue_wdir
set_filepermissions

#see if we should elevate privlages from read only to git
if [ $install_privileges = "dev" ]; then
  header "Linking to git repo $repo on branch $branch"
  if prompt "Do you want to set a ssh key in github for this machine? " "$set_github_ssh_key"; then
    echo "geting github token to create sshkey"
    #get github token
    while [ -z "${github_public_key_rw}" ]; do
      source $rogue_wdir/cli/secrets.sh 'user_tokens'
    done

    #set ssh key 
    ${rogue_wdir}/scripts/generate_github_ssh_key.sh "${github_public_key_rw}"
  fi

  #remove read only and upgrade to versioned
  sudo rm -rf $rogue_wdir;
  # using git (for devs)
  
  sudo git clone "git@github.com:${repo}.git" -b $branch $rogue_wdir
fi


#set work dir to /opt/RogueOS path
cd $rogue_wdir # "$(dirname "$0")"

if ! [[ $(pwd) -ef $rogue_wdir ]]; then
  header "Must install RogueOS to $rogue_wdir"
  exit 1
fi

set_filepermissions


#################################################################3
header "Setting up python venv"
if [ "$linux_distro" != "mac" ]; then
 sudo apt-get install -y python3-pip
#else
#  python3 -m ensurepip --upgrade
fi

#create virtual environment without pip and with access to system site packages
python3 -m venv "${rogue_wdir}/.venv" --without-pip --system-site-packages
source "${rogue_wdir}/.venv/bin/activate"
#example
#python3 -m pip install Django


#https://askubuntu.com/questions/1390779/how-do-i-safely-switch-from-gnome-to-kde-plasma
if prompt "Do you wish to install kde plasma? This will allow kasmvnc to run in gpu accelerated mode " $install_kde; then
  if [[ $XDG_CURRENT_DESKTOP == *"GNOME"* ]]; then
    sudo apt update; sudo apt upgrade
    sudo apt-mark minimize-manual
    sudo apt install kubuntu-desktop
    sudo apt install $(check-language-support -l en)
    sudo apt remove ubuntu-desktop
    sudo apt remove ubuntu-desktop-minimal || true
    sudo apt remove ubuntu-desktop-raspi || true
    //TODO auto logout and log into a kde session
    gnome-session-quit
    sudo apt autoremove
  fi
fi


###########################################################################################################
source $rogue_wdir/config.sh "$env_file"

rm -rf "$env_file"
header "RogueOS is now Ready"

