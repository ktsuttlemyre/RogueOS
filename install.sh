#! /bin/bash
set -ex
#force working directory
cd /opt

os="RogueOS"
rogue_wdir="/opt/$os"
host="$(hostname | cut -d. -f1)"
machine_name=$(scutil --get ComputerName 2>/dev/null || uname -n || host)
remote_install="${1:-ro}"
branch="${2:-$machine_name}"

if curl -ss https://api.github.com/repos/ktsuttlemyre/RogueOS/branches/$branch | grep '"message": "Branch not found"' ; then 
  echo "You do not have a branch = $branch"
  read -p "Do you wish to continue with read only Master branch? " -n 1 -r; echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      branch='' # blank means use master branch
      remote_install='ro'
  else
    echo "exiting"
    exit 0
  fi
fi

#if already installed then ask to delete and replace
if [ -d "$rogue_wdir" ]; then
  read -p "Do you wish to replace the current RogueOS? located at $rogue_wdir? " -n 1 -r; echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      sudo rm -rf $rogue_wdir
  else
    echo "exiting"
    exit 0
  fi
fi

if [ $remote_install = "dev" ]; then
  echo "Developer mode"
  read -p "Do you want to set a ssh key in github for this machine?" -n 1 -r; echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "geting github token to create sshkey"
      #get github token
      source ./scripts/rogue_secrets.sh user_tokens

      #set ssh key 
      ./scripts/generate_github_ssh_key.sh github_public_key_rw ]

  fi

  # using git (for devs)
  sudo git clone "git@github.com:ktsuttlemyre/$os.git" -b $branch $rogue_wdir
  #ensure we are in /opt/RogueOS path
  cd $rogue_wdir # "$(dirname "$0")"
elif [ $remote_install = "ro" ]; then
  echo "Read only mode"
  # Downloads the whole repo
  # without version control (read only install)
  sudo mkdir $rogue_wdir
  curl -LkSs "https://api.github.com/repos/ktsuttlemyre/RogueOS/tarball/$branch" | sudo tar xz --strip=1 -C $rogue_wdir
  #ensure we are in /opt/RogueOS path
  cd $rogue_wdir # "$(dirname "$0")"
fi

if ! [[ $(pwd) -ef $rogue_wdir ]]; then
  echo "Must install RogueOS to $rogue_wdir"
  exit 1
fi

#TODO create RogueOS user and chown all files and services
# if [[ is mac os ]]; then
# ./utils/adduser_mac.sh RogueOS
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
find $rogue_wdir -type f -iname "*.sh" -exec sudo chmod +x {} \;

#todo encrypt this somehow and feed it through in memory FS
echo "Writing host specific .env for RogueOS to $rogue_wdir/.env"
cat > $rogue_wdir/.env <<EOF
os="$os"
rogue_wdirir="$rogue_wdir"
host="$host"
machine_name="$machine_name"
secrets="$/secrets"
secrets_size=".5G"
EOF

source ./install_config.sh $machine_name


