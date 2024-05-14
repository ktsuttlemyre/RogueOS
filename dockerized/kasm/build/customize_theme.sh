#!/bin/bash
##### GTK Theme Options

GTKTHEME=( "Default" "Greybird" "Greybird-dark" "Orchis-Light" "Orchis-Dark" )
##### Window Manager Options
XFWM4THEME=( "Default" "Greybird" "Greybird-dark" "Orchis-Light" "Orchis-Dark" )
##### Background Options
WALLPAPER[1]=/usr/share/backgrounds/xfce/xfce-verticals.png
WALLPAPER[2]=/usr/share/backgrounds/xfce/xfce-blue.png
WALLPAPER[3]=/home/toz/upload/2560x1440.png
WALLPAPER[4]=/home/toz/upload/1920x1080.png
##### make the changes
xfconf-query -c xsettings -p /Net/ThemeName -s ${GTKTHEME[2]}
xfconf-query -c xfwm4 -p /general/theme -s ${XFWM4THEME[2]}
#xfconf-query -c xfce4-desktop -p  /backdrop/screen0/monitorVirtual-1/workspace0/last-image -s ${WALLPAPER[$1]}
