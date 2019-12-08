#!/bin/bash
set -e 
set -o pipefail



log(){
	echo "======================"
	echo "$1"
	echo "======================"
}
installing(){
	log "Minimal x server"
	pacapt install --noconfirm xserver-xorg xinit #TODO could be more miniamal probably
}
pacapt(){ #shim
	if [ "$1" != "install" ] && [ "$2" != "--noconfirm" ]; then
		echo "shim needs updating"
		exit 1
	fi
	#https://github.com/icy/pacapt#usage
	#pacapt install --noconfirm "${@:2}"
	sudo apt install -y "${@:3}"
}


declare -a modes=("base" 
                "polish"
                )
#if $1 is config then config only
#DEV NOTES:
#lightdm is login manager because it is light, supports wayland, uses webkit, remote logins etc 
#	rasbarian (and thus raspi-conf) supports lightdm as a login manager and can be toggled and supported via the raspi-config
#i3 is the window manager


sudo apt update
sudo apt -y full-upgrade

for mode in "${modes[@]}"; do
#for mode in $modes; do
	arr=("$mode")
	mode=${arr[0]}
	install=${arr[1]}
	config=${arr[2]}
	silent=${arr[3]}

	
	case "$mode" in
		headless)

			#################
			#	Install 3rd party
			#		wifi driver
			#################
			#https://www.raspberrypi.org/forums/viewtopic.php?t=192985


			#sudo wget http://fars-robotics.net/install-wifi -O /usr/bin/install-wifi
			#sudo chmod +x /usr/bin/install-wifi


			################
			#	install bridge
			################
			sudo apt install -y dnsmasq



			######
			# version control will be on at some point just do it
			######
			sudo apt install -y git


			#oh-my-bash (themes)
			sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
			#set theme to zitron
			../ROGUE REPLACE_BASH_VAR ~/.bashrc OSH_THEME random


			sudo apt install -y trash-cli
		;;
		desktop*)
			install && \
				installing "minimal x server" xserver-xorg xinit #TODO could be more miniamal probably

			#next programs are all described by this 3 set video set
			#https://www.youtube.com/watch?v=j1I63wGcvU4&list=PL5ze0DjYv5DbCv9vNEzFmP6sU7ZmkGzcf&index=1
			install && \
				installing "window manager" i3
		;;&
		desktop_full)
			install && \
				installing "login manager/display manager" lightdm
			#rofi is fuzzy dmenu replacement (top bar)
			install && \
				installing "better run prompt with fuzzy search" rofi

			#gtk cusotmization gui
			#https://askubuntu.com/questions/598943/how-to-de-uglify-i3-wm
			#feh sets background
			#arandr gui to  xrander comand generator
			install && \
				installing "Minimal Theme managment" feh arandr lxappearance gtk-chtheme qt4-qtconfig && \
				#747 mb or .7gb of space for the following libraries (if you dont force --no-install-recommends on apt)
				#xserver-xorg xinit lightdm i3 feh arandr rofi compton lxappearance
				#fix copy and paste in 
				installing 'fix copy & paste' autocutsel
				#set it to boot when any x session starts
				#this is now in rogueos startup
				#echo 'autocutsel &' >> /etc/X11/xinit/xinitrc
			git clone --depth=1 git@github.com:ryanoasis/nerd-fonts.git
			
		;;&

		auto_theme*)
			install && \
				installing "Auto theme" imagemagick python3-pip sysvinit-utils #for pywal pidof is typically in sysvinit-utils
				#note got this error /home/pi/.local/bin not on path consider adding this dirctory to path

			install && \
				pip3 install pywal
				#TODO look for warning that says 
				#"are installed in '/home/pi/.location/bin' which is not on PATH.
				#\sConsider adding this directory to PATH or, if you prefer to suppress this warning, use --no-warn-script-location
				#and extract the path variable to add below
				#i converted /home/pi/ to $HOME cause thats how .profile does it
			config && \
				echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
			#see https://unix.stackexchange.com/questions/212360/copying-pasting-with-urxvt
			log "GTK interface and skinning support"
			install && \
				#libraries use to compile utlitiy to reload gtk
				installing "GTK python bindings" python-gobject python-pil && \
				#raspberian lite needs this. idk i had to google the error
				#https://github.com/raspberrypi/skygate/issues/4
				installing "" gir1.2-gtk-3.0 && \
				installing "" libjpeg-dev zlib1g-dev xsettingsd && \
				sudo pip3 install wpgtk && \
				wpg-install.sh -otgirIpdb && \
				echo "set Widget to 'FlatColor' and Icon Theme to 'FlattrColor' for auto theming gtk applicaitons based on background" && \
				lxappearance
				#alternate solution https://askubuntu.com/questions/353914/copy-paste-between-terminals-and-application-windows-in-i3
		;;&

		enhancements) #compositor and animations
			#compositor (for window transparency and shadows)
			install && \
				installing "compton" compton

			#TODO set up cool keybindng interface through rofi
			#https://www.youtube.com/watch?v=Y6ldzp8_x0Y
		;;&

		power_tools)


			#easystoke
			install g++ libboost-serialization-dev libgtkmm-3.0-dev libxtst-dev libdbus-glib-1-dev intltool xserver-xorg-dev
			wget http://openartisthq.org/easystroke/patched-easystroke-master.tar.bz2
			tar xvjf patched-easystroke-master.tar.bz2
			cd patched-easystroke-master/easystroke
			make
			sudo make install

			#mouse gestures
			#not maintained anymore
			# sudo apt install pkg-config autoconf libtool libx11-dev libxrender-dev libxtst-dev libxml2-dev git
			# git clone https://github.com/deters/mygestures.git
			# cd mygestures/
			# sh autogen.sh
			# ./configure
			# make
			# sudo make install
		;;&

		# *)
		# 	STATEMENTS
		# ;;
	esac
done



echo "rebooting in "
for ((i=5; i>=1; i--)); do
	sleep 1
	echo -n "$i.."
done
sudo shutdown -r now


