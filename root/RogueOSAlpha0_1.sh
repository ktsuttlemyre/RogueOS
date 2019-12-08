



#Dev notes
#lightdm is login manager because it is light, supports wayland, uses webkit, remote logins etc 
#	rasbarian (and thus raspi-conf) supports lightdm as a login manager and can be toggled and supported via the raspi-config
#i3 is the window manager 

######################
#	install window manager
#######################
sudo apt install xserver-xorg xinit #minimal xserver
sudo apt install lightdm #login manager
#next programs are all described by this 3 set video set
#https://www.youtube.com/watch?v=j1I63wGcvU4&list=PL5ze0DjYv5DbCv9vNEzFmP6sU7ZmkGzcf&index=1
sudo apt install i3
#feh sets background
#arandr gui to  xrander comand generator
#rofi is fuzzy dmenu replacement (top bar)
sudo apt install feh arandr rofi #window manager and tools
#compositor (for window transparency and shadows)
sudo apt install compton
#gtk cusotmization gui
#https://askubuntu.com/questions/598943/how-to-de-uglify-i3-wm
sudo apt install lxappearance gtk-chtheme qt4-config

#747 mb or .7gb of space for the following libraries (if you dont force --no-install-recommends on apt)
#xserver-xorg xinit lightdm i3 feh arandr rofi compton lxappearance

sudo apt update && apt -y full-upgrade

sudo apt install 

#https://www.youtube.com/watch?v=8-S0cWnLBKg&list=PL5ze0DjYv5DbCv9vNEzFmP6sU7ZmkGzcf&index=2
#https://github.com/FortAwesome/Font-Awesome/releases
#get TTF
set $RogueHome 
set $workspace "1: Editor"
set $workspace "2: Editor"
set $workspace "3: Editor"
set $workspace "4: Editor"
set $workspace "5: Editor"

bindsym $mod+1 workspace $workspace1

#config

https://faq.i3wm.org/question/3747/enabling-multimedia-keys/?answer=3759#post-id-3759
feh --bg-scale

exec $RogueHome/startup.sh
exec_always $RogueHome/windowManager.sh



#xprop to get class
assign [class="FireFox"] $workspace10


hide_edge_borders both



#################
#	Install 3rd party
#		wifi driver
#################
#https://www.raspberrypi.org/forums/viewtopic.php?t=192985

sudo wget http://fars-robotics.net/install-wifi -O /usr/bin/install-wifi
sudo chmod +x /usr/bin/install-wifi


################
#	install bridge
################
sudo apt install dnsmasq
