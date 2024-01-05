#! /bin/bash
#force working directory
cd /opt

OS=RogueOS
DIR=/opt/$OS
HOSTNAME=$(hostname | cut -d. -f1)
BRANCH=$HOSTNAME
REMOTE_INSTALL="ro"

if curl -ss https://api.github.com/repos/ktsuttlemyre/RogueOS/branches/$HOSTNAME | grep '"message": "Branch not found"' ; then 
  echo "You do not have a branch for this HOSTNAME = $HOSTNAME"
  read -p "Do you wish to continue with read only Master branch? " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      BRANCH='master'
      REMOTE_INSTALL='ro'
  else
    echo "exiting"
    exit 0
  fi
fi

if [ $REMOTE_INSTALL = "dev" ]; then
  # using git (for devs)
  sudo git clone "https://github.com/ktsuttlemyre/$OS.git" -b $BRANCH $DIR
  #ensure we are in /opt/RogueOS path
  sudo cd $DIR # "$(dirname "$0")"
elif [ $REMOTE_INSTALL = "ro" ]; then
  # Downloads the whole repo
  # without version control (read only install)
  curl -LkSs https://api.github.com/repos/ktsuttlemyre/RogueOS/tarball/$BRANCH -o $OS.tar.gz
  sudo mkdir $DIR
  tar -xzf $OS.tar.gz -C $DIR
  #ensure we are in /opt/RogueOS path
  sudo cd $DIR # "$(dirname "$0")"
fi

if ![[ $(pwd) -ef $DIR ]]; then
  echo "Must install RogueOS to $DIR"
  exit 1
fi
#allows only user (owner) to do all actions; group and other users are allowed only to read.
sudo chown -R 744 $DIR
#make all .sh files excutible
find $DIR -type f -iname "*.sh" -exec chmod +x {} \;

./install_config.sh $HOSTNAME


