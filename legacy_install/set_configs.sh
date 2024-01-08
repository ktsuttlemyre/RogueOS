#!/bin/bash


configs="./configs"
copy(){
	install -v "$1" -t "$2"
}


for d in "$configs/"* ; do
	if [[ "$d" == "home" ]]; then
		copy "$d" "/home/$USER"
	fi
	copy "$d" "/$d"
done
