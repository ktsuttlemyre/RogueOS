#!/bin/bash


configs="./configs"
copy(){
	install -v "$1" -t "$2"
}


for d in */ ; do
	if [[ "$d" == "~" ]]; then
		copy "$configs/$d" "$configs/$USER"
	fi
	copy "$configs/$d" "$d/"
done