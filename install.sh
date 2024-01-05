#! /bin/bash
#force working directory
cd /opt

os=RogueOS
dir=/opt/$os
host_name=$(hostname | cut -d. -f1)
branch=$host_name
remote_install="ro"

if curl -ss https://api.github.com/repos/ktsuttlemyre/RogueOS/branches/$host_name | grep '"message": "Branch not found"' ; then 
  echo "You do not have a branch for this host_name = $host_name"
  read -p "Do you wish to continue with read only Master branch? " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      branch='master'
      remote_install='ro'
  else
    echo "exiting"
    exit 0
  fi
fi

if [ $remote_install = "dev" ]; then
  # using git (for devs)
  sudo git clone "https://github.com/ktsuttlemyre/$os.git" -b $branch $dir
  #ensure we are in /opt/RogueOS path
  sudo cd $dir # "$(dirname "$0")"
elif [ $remote_install = "ro" ]; then
  # Downloads the whole repo
  # without version control (read only install)
  curl -LkSs https://api.github.com/repos/ktsuttlemyre/RogueOS/tarball/$branch -o $os.tar.gz
  sudo mkdir $dir
  tar -xzf $os.tar.gz -C $dir
  #ensure we are in /opt/RogueOS path
  sudo cd $dir # "$(dirname "$0")"
fi

if ![[ $(pwd) -ef $dir ]]; then
  echo "Must install RogueOS to $dir"
  exit 1
fi
#allows only user (owner) to do all actions; group and other users are allowed only to read.
sudo chown -R 744 $dir
#make all .sh files excutible
find $dir -type f -iname "*.sh" -exec chmod +x {} \;

./install_config.sh $host_name


