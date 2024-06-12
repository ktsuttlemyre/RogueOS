#Descripion

For many years computers always had a keyboard, mouse, and monitor. After introducing the internet and the concept of The Internet of Things computers interact with and each other in many different ways. This project is the base OS for several of my other projects. RogueOS attempts to become what you need when you need it to fill that need. It does this by detecting how it can interact with the environment and sets itself up to best use that interaction.

RogueOS the base for my upcoming projects. At the heart of each functionality is an open source project but augmented for better experiences.

I have done a lot of customization and research to find the best tools to augment these functions.

###Rogue projects strive to be
 - Portable
 - one click installs and activations of features on any device
 - scriptible 
 - Responsive (will change functionality based on peripheral)
 - OS independent (priority: Web Tech > Linux > Mac > Windows)

Most of the projects depend on a core open source project but enhanced and customized to be more robust than they come.

###Modes of operation
|                   	| Monitor 	| Keyboard 	| Mouse 	| Gaming Pad 	| Internet 	| Intranet 	| Mic 	|
|-------------------	|:-------:	|:--------:	|:-----:	|:----------:	|:--------:	|:--------:	|:---:	|
| RogueOS           	|    \    	|     \    	|   \   	|      \     	|     \    	|     \    	|  \  	|
| RogueWM           	|    X    	|     X    	|   \   	|      \     	|     \    	|     \    	|  \  	|
| RogueCast         	|    X    	|          	|       	|      \     	|     \    	|     \    	|  \  	|
| RogueConsole         	|    X    	|     \    	|   \   	|      \     	|          	|     \    	|     	|
| RogueRadio        	|         	|          	|       	|            	|     \    	|     \    	|  \  	|
| Fourier (Backend) 	|         	|          	|       	|            	|     \    	|     \    	|     	|

Key
 X = Required
 \ = Optional


Projects Running on RogueOS
RogueWM - Window manager for when you are in Personal Computer mode
RogueCast - A media casting endpoint
RogueConsole - gaming system
RogueRadio - Radio player aimed for car stereo
Fourier - (browser based window manager/thin client)

Projects that will interact with this environment
RoguePad - Gaming pad for the phone



# Remote Install
## Interactive install
```bash
bash <(wget -qO- -nv https://raw.githubusercontent.com/ktsuttlemyre/RogueOS/master/install.sh)
```
```bash
bash <(curl -s https://raw.githubusercontent.com/ktsuttlemyre/RogueOS/master/install.sh)
```

## Non-interactive install
#### via env vars
```bash
(
#optional
#export machine_name=''
#export install_privileges='dev'
#export set_environment_secrets='yes'
#export replace_old_rogue='yes'
#export create_branch='yes'
#export set_github_ssh_key='yes'
bash <(curl -s https://raw.githubusercontent.com/ktsuttlemyre/RogueOS/master/install.sh)
)
```
#### or from an env file
```bash
(
#optional
#export machine_name=''
bash <(curl -s https://raw.githubusercontent.com/ktsuttlemyre/RogueOS/master/install.sh) env
)
```
note: env file variables will override the exported ones before the call
note: also env file will be deleted after attempted install

You can automate answers via the following variables
set_environment_secrets='yes,no,cancel or exit'
replace_old_rogue='yes,no,cancel or exit'
create_branch='yes,no,cancel or exit'
set_github_ssh_key='yes,no,cancel or exit'

In a runcmd cloud-init script
```yaml
#need update depreicated
runcmd:
  - export OS='RogueOS'
  - curl -LkSs https://api.github.com/repos/ktsuttlemyre/RogueOS/tarball -o $OS.tar.gz
  - mkdir $OS
  - tar -xzf $OS.tar.gz -C $OS
  - chmod +x $OS.sh
  - ./$OS.sh
```
The above can be appended to the `system-boot:/user-data` file in a raspberry pi image even on a windows machine after using etcher as the `system-boot` partition is fat32



#Software used
https://github.com/fractalnetworksco/selfhosted-gateway

#Software Services


```
TODO add in mounting of ramdisk
header "Creating RAM Disk"
ramdisk=''
#install nginx to system communication ramdisk
if [ "$linux_distro" = "mac" ]; then
  echo "installing Mac software"
  ramdisk=/Volumes/RogueOSRam
  $rogue_wdir/cli/rogue mountram "$ramdisk"

  brew upgrade || true
  brew upgrade --cask || true

  #https://superuser.com/questions/1480144/creating-a-ram-disk-on-macos
  brew install entr
else
  ramdisk=/mnt/RogueOSRam
  #todo sleep service funciton
  $rogue_wdir/cli/rogue mountram "$ramdisk" 8192
fi
```



dev note
```
command -v wget >/dev/null 2>&1 && { ; exit 1; } ||
g="$(command -v adfsa >/dev/null 2>&1 && echo wget || echo curl)"

{url='https://raw.githubusercontent.com/ktsuttlemyre/RogueOS/master/install.sh'
cmd="$(command -v adfsa >/dev/null 2>&1 && echo wget -qO- -nv $url || echo curl -s $url)"
$cmd
}
```


### Manage KASMVNC

#### configs
main config is in /root/etc/kasmvnc/kasmvnc.yaml
xstart is in /home/.vnc/xstart

#### Additinal install
Turn off compositing https://kasmweb.com/kasmvnc/docs/master/gpu_acceleration.html#desktop-compositing
Dont use Gnome
use x11 not wayland 
 - disable wayland https://askubuntu.com/questions/1428525/how-to-permanetely-disable-wayland
Use nouveau2 drivers (open source) because Nvidia doesnt support DRI3


#### Stopping KASMVNC
killall Xvnc; kasmvncserver -kill :1 
where :1 can be any display number, ususally :1 unless running mutiple instances

#### List all KASMVNC servers
kasmvncserver -list

if you get an error about connectiong to the snakeoil certificate make sure to run as usergroup
sg ssl-cert kasmvncserver 

docker run --privileged --rm -it --shm-size=512m -p 6901:6901 -e VNC_PW=password -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY -h $HOSTNAME -v $HOME/.Xauthority:/home/kasm-user/.Xauthority  ghcr.io/ktsuttlemyre/rogueos:master /opt/sublime_text/sublime_text


https://l10nn.medium.com/running-x11-applications-with-docker-75133178d090


kqsfl@cab2kqsfl:~/tmp$ setsid sh -c 'exec x11docker --desktop --xorg --init=tini x11docker/xfce <> /dev/tty2 >&0 2>&1'
