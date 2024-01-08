#Rasberry pi lite
confirm_prompt(){
    read -p "$1" -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}
check_internet_connection(){
	#returns 0 if online
	nc -z 8.8.8.8 53  >/dev/null 2>&1
	return $?
}
get_credentials(){
	#show some options
	sudo iw dev wlan0 scan | grep "SSID: "
	read -p "Enter wifi name (SSID) you want to connect to: " WIFI_SSID
	read -s -p "Enter password: " WIFI_PASSWORD
	echo
}
#DEV NOTES
#
###NOTE USE THIS WIFI AUTO INSTALLER (seems apt full-upgrade will do this (might be able to get away with apt-upgrade))
#https://www.raspberrypi.org/forums/viewtopic.php?t=192985

#config
locale=en_US.UTF-8
layout=us
wifi_country=US
WIFI_SSID=$1
WIFI_PASSWORD=$2
WIFI_SSH=$3


##################
#	rasp-config
##################
#https://raspberrypi.stackexchange.com/questions/28907/how-could-one-automate-the-raspbian-raspi-config-setup
#https://github.com/RPi-Distro/raspi-config/blob/master/raspi-config

#force them to set a new password
#1 Change User Password
until sudo raspi-config nonint do_change_pass; do echo "Try again"; done

#2 Network Options
#N2 Wi-Fi
sudo raspi-config nonint do_wifi_country $wifi_country
#doesnt seem to work
#sudo raspi-config nonint do_wifi_ssid_passprhase $ssid $password


#4 Localisation Options
#I1 Change Locale
#uncheck en_GB
#check en_US.UTF-8 UTF-8
#en_US.UTF-8

sudo raspi-config nonint do_change_locale $locale
sudo raspi-config nonint do_configure_keyboard $layout


if [[ -z "${WIFI_SSID}" ]]; then
	get_credentials
fi
#|| $(confirm_prompt "try again?")
until [ check_internet_connection ]; do
	get_credentials

	#advanced scan mode on
	sudo raspi-config nonint do_wifi_ssid_passphrase $WIFI_SSID $WIFI_PASSWORD
done


#set wifi (trick go to local afterward and set network to us so the config file asks to reboot)
if [[ -z "${WIFI_SSH}" ]]; then
	sudo raspi-config nonint do_ssh 0
fi

#display current ip
echo "========IP ADRESS========"
echo "Local"
hostname -I
echo "Public "
curl ident.me
echo "========IP ADRESS========"

sudo apt update
sudo apt -y full-upgrade
#sudo raspi-config nonint do_update
echo "rebooting in "
for ((i=5; i>=1; i--)); do
	sleep 1
	echo -n "$i.."
done
sudo shutdown -r now
