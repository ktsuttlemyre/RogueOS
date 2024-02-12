#! /bin/bash
set -e
set -x

echo "Installing Rogue OS. Some of the commands will need sudo access. Please grant sudo use."
#do a sudo command to get the password out of the way
sudo echo "Thank you for granting sudo privileges" || exit 1

#cant run in the dir we are going to install
os="RogueOS"
rogue_wdir="/opt/$os"
if [[ ./ -ef "$rogue_wdir" ]] || [ "$PWD" = "$rogue_wdir" ] || [ "$(pwd)" = "$rogue_wdir" ]; then
  echo "Sorry, you can not run this installer from the Rogue install path $rogue_wdir"
fi

#force working directory to tmp
mkdir -p /tmp/RogueOS
cd /tmp/

################################### Functions ##########################################
function header () {
 echo -e "RogueOs[installer]  $1"
}

prompt() {
  message="$1"
  while true; do
      read -p "$message " yn
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
          * ) echo "Please answer yes,no,cancel,exit.";;
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

  
  cd "$old_pwd"

}

###########################################################################################################
header "preparing this environment to become Rogue"
# check if it is a raspberry pi
cpu_board=false
if [ -x "$(command -v python3)" ] ; then
  R_PI=`python3 -c "import platform; print('-rpi-' in platform.uname())"`
  if [ "$cpu_board" = "True" ] ; then
    cpu_board='PI'
  fi
else
  header "found that Python3 not installed"
  exit 1
fi
#load os vars for identification
if [ -f /etc/os-release ]; then
  source /etc/os-release
else
  source $rogue_wdir/scripts/os-release.sh
fi
ID="${ID:-$OS}"

linux_distro=false
if [ -z ${ID+x} ]; then 
  ID="$(uname -s)"
fi

case "$ID" in
  raspbian) linux_distro="raspbian" ;;
  ubuntu) linux_distro="ubuntu" ;;
  arch) linux_distro="arch" ;;
  centos) linux_distro="centos" ;;
  Darwin*) linux_distro="mac" ;;
  *) echo "This is an unknown distribution. Value observed is $ID"
      ;;
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

header "Install script has determined you are running\n\tcpu_board = ${cpu_board} \n\tlinux_distro = ${linux_distro} \n\tprocessor_arch = ${processor_arch} \n\tprocessor_bits = ${processor_bits}"


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



if ! type "git" > /dev/null; then
  if [ "$linux_distro" = "mac" ]; then
    brew install git
  else
    sudo apt-get install git
  fi
fi

#create alias
#type python >/dev/null 2>&1 || alias python=python3

#type pip >/dev/null 2>&1 || alias pip=pip3

########################################################################
header "setting up nodejs"
#dependencies
if [ "$linux_distro" != "mac" ]; then
  sudo apt-get install -y nodejs npm
fi


if ! type "bw" > /dev/null; then
  sudo npm install -g @bitwarden/cli
fi

if [ "$linux_distro" != "mac" ]; then
  sudo apt-get install -y  jq
else
  brew install jq
fi

################################### Repo and install management ###################################
header "Repo and installation linking"
repo="ktsuttlemyre/RogueOS/"

host="$(hostname | cut -d. -f1)"
machine_name=$(scutil --get ComputerName 2>/dev/null || uname -n || host)
machine_name=${1:-machine_name}
branch="$machine_name"
install_privlages="${2:-ro}"

#if already installed then ask to delete and replace
if [ -d "$rogue_wdir" ]; then
  if prompt "Do you wish to replace the current RogueOS? located at $rogue_wdir? "; then
      sudo rm -rf $rogue_wdir;
  else
    echo "exiting"
    exit 0
  fi
fi

sudo mkdir $rogue_wdir
if curl -ss "https://api.github.com/repos/${repo}branches/${branch}" | grep '"message": "Branch not found"' ; then
  #curl -LkSs "https://api.github.com/repos/${repo}tarball/" | sudo tar xz --strip=1 -C $rogue_wdir
  sudo git clone https://github.com/ktsuttlemyre/RogueOS.git $rogue_wdir
  set_filepermissions
  echo "You do not have a branch for this host: $branch"
  if prompt "Do you wish to create ${branch} now? "; then
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
    install_privlages='ro'
  fi
fi
#Install branch or master branch (handles fallback to master gracefully) 
#curl -LkSs "https://api.github.com/repos/${repo}tarball/${branch}" | sudo tar xz --strip=1 -C $rogue_wdir
sudo git clone https://github.com/ktsuttlemyre/RogueOS.git -b "${branch}" $rogue_wdir
set_filepermissions

#see if we should elevate privlages from read only to git
if [ $install_privlages = "dev" ]; then
  header "Linking to git repo"
  if prompt "Do you want to set a ssh key in github for this machine? "; then
    echo "geting github token to create sshkey"
    #get github token
    while [ -z "${github_public_key_rw}" ]; do
      source $rogue_wdir/cli/secrets.sh 'user_tokens'
    done

    #set ssh key 
    ${rogue_wdir}/scripts/generate_github_ssh_key.sh 'github_public_key_rw'
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
 sudo apt-get install python3-pip
#else
#  python3 -m ensurepip --upgrade
fi

#create virtual environment without pip and with access to system site packages
python3 -m venv "${rogue_wdir}/.venv" --without-pip --system-site-packages
source "${rogue_wdir}/.venv/bin/activate"
#example
#python3 -m pip install Django



###########################################################################################################
header "Configuring $machine_name"
source $rogue_wdir/config.sh $machine_name


header "RogueOS is now Ready"

