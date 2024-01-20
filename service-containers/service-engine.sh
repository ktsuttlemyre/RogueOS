#!/bin/bash
set -x

#add rogue vars
source /opt/RogueOS/.env

#add host vars
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

[ -f $host_wd/.env ] && source "$host_wd/.env"

#add secrets?
#TODO


handle_file () {
	ACTION="$1"
	FILE="$2"
	iter_dir="$3"
	if [[ $FILE == -* ]]; then
		#this one is disabled
	 	return
	fi

	IFS='.' read -ra array <<< "$FILE"
	service="${array[1]}"
	file_type=$(printf %s\\n "${array[@]:(-1)}")
	#if isDisabled
	if [ "${array[2]}" = "disbled" ]; then
		return
	fi

	if [ "$file_type" = "yml" ]; then

		#if there is an env-file variable in the header then grab it
		env_file="$secrets/.env"
		line=$(head -n 1 "$iter_dir/$FILE")
		if [[ $line == \#env\-file\=* ]]; then
			env_file="${line/\#env\-file\=/}"
			echo "found env_file for yml $env_file"
		fi

		echo "starting service $service from file $FILE filetype=$file_type"
		[ "$ACTION" = "init" ] && docker compose -f "$service_wd/$service/docker-compose.yml" --env-file "$env_file" build
		#todo add  -f ./service-containers/rogue.labels.yml to above command
		[ "$ACTION" = "startup" ] && docker compose -f "$iter_dir/$FILE"  -f "$service_wd/$service/docker-compose.yml" --env-file "$env_file"  --project-name "$service" up -d
		[ "$ACTION" = "shutdown" ] && docker compose -f "$iter_dir/$FILE"  -f "$service_wd/$service/docker-compose.yml" --env-file "$env_file"  --project-name "$service" down
	elif [[ "$filetype" = ".sh" ]]; then
		echo "running bash script from file $FILE filetype=$file_type"
		$FILE
	fi
}

echo "RogueOS servicen engine is perfoming $1"
#depricated?
# function docker_up () {
# 	IFS='_' read -r -a array <<< "$1"
# 	service="${array[0]}"
# 	id="${array[1]}"
# 	env="$2"
# 	yml="${3:-$host_wd/$1.compose.yml}"
# 	#docker compose -f "$service_wd/$service/docker-compose.yml" -f "$yml" --env-file "$env" config # -d
# 	docker compose -f "$host_wd/startup/0.novnc.yml"  -f ./service-containers/novnc/docker-compose.yml -f ./service-containers/rogue.labels.yml --env-file ~/.env  --project-name novnc config
# }

case "$1" in
    "init")
		#run init.sh
	    $host_wd/init.sh
		iter_dir=$host_wd/startup
		for FILE in `ls $iter_dir | sort -g`; do
			handle_file $1 $FILE $iter_dir
		done
		iter_dir=$host_wd/shutdown
		for FILE in `ls $iter_dir | sort -g`; do
			handle_file $1 $FILE $iter_dir
		done
	;;

    "startup")
	    iter_dir=$host_wd/startup
		for FILE in `ls $iter_dir | sort -g`; do
			handle_file $1 $FILE $iter_dir
		done
	;;

    "shutdown")
	    iter_dir=$host_wd/shutdown
		for FILE in `ls $iter_dir | sort -g`; do
			handle_file $1 $FILE $iter_dir
		done
	;;
	*)
        echo "Unknown command: $command" 
        exit 1
        ;;

esac


echo "Rogue Service Engine completed $1"