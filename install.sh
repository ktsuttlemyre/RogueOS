#! /bin/bash
set -ex
#force working directory
cd /opt

os=RogueOS
dir=/opt/$os
host_name=$(hostname | cut -d. -f1)
branch=$host_name
remote_install="${1:-ro}"

if curl -ss https://api.github.com/repos/ktsuttlemyre/RogueOS/branches/$host_name | grep '"message": "Branch not found"' ; then 
  echo "You do not have a branch for this host_name = $host_name"
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
if [ -d "$dir" ]; then
  read -p "Do you wish to replace the current RogueOS? located at $dir? " -n 1 -r; echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      sudo rm -rf $dir
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
  sudo git clone "git@github.com:ktsuttlemyre/$os.git" -b $branch $dir
  #ensure we are in /opt/RogueOS path
  cd $dir # "$(dirname "$0")"
elif [ $remote_install = "ro" ]; then
  echo "Read only mode"
  # Downloads the whole repo
  # without version control (read only install)
  sudo mkdir $dir
  curl -LkSs "https://api.github.com/repos/ktsuttlemyre/RogueOS/tarball/$branch" | sudo tar xz --strip=1 -C $dir
  #ensure we are in /opt/RogueOS path
  cd $dir # "$(dirname "$0")"
fi

if ! [[ $(pwd) -ef $dir ]]; then
  echo "Must install RogueOS to $dir"
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
sudo chown -R $the_user $dir

#allows only user (owner) to do all actions; group and other users are allowed only to read.
sudo chmod -R 744 $dir
#make all .sh files excutible
find $dir -type f -iname "*.sh" -exec sudo chmod +x {} \;

#todo encrypt this somehow and feed it through in memory FS
echo "Writing host specific .env for RogueOS to $dir/.env"
cat > $dir/.env <<EOF
os="$os"
dir="/opt/$os"
host="$hostname"
secrets="$/secrets"
secrets_size=".5G"
EOF

source ./install_config.sh $host_name


