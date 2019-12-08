#!/bin/bash
set -e 
set -o pipefail

#RogueTools

OS="RASBERIAN"
ROGUE_BUILD="FULL"
FOURIER="YES"

BASE_DIR="./installs"

confirm_prompt(){
    read -p "$1" -n 1 -r
    echo    # (optional) move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 1
    else
        return 0
    fi
}

if [ -f /usr/local/bin/rogueOS ]; then
	if confirm_prompt "Would you like to reset configs?"; then
		
	fi
fi


# Bash Menu Script Example
PS3='Choose what build you would like to start with: '
options=("HEADLESS" "BASE_DTE" "RICE" "Quit")
select ROGUE_BUILD in "${options[@]}"
do
	if [[ " ${options[@]} " =~ " ${ROGUE_BUILD} " ]]; then
		break
	else
		echo "option not valid"
	fi
done

PS3='Would you like to install FOURIER? '
options=("YES" "NO" "Quit")
select FOURIER in "${options[@]}"
do
	case $FOURIER in
		"YES")
			echo "you chose choice 1"
			;;
		"NO")
			echo "you chose choice 2"
			;;
		"Quit")
			break
			;;
		*) echo "invalid option $REPLY";;
	esac
done


function install_OS(){
	. "$BASE_DIR/Rogue_Headless.sh"
	if [ "$ROGUE_BUILD" = "HEADLESS" ]; then
		return $?
	fi

	. "$BASE_DIR/Rogue_Lite.sh"
	if [ "$ROGUE_BUILD" = "BASE_DTE" ]; then
		return $?
	fi

	. "$BASE_DIR/Rogue_Full.sh"
	return $?
}


if install_OS ; then
	if [ "$FOURIER" = "YES" ]; then
		. "$BASE_DIR/ROGUE_FOURIER.sh"
	fi
fi

if $?; then
	echo "successful"
else
	echo "errors"
fi

echo "cleaning up"
sudo apt autoremove


