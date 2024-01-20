#!/bin/bash
set -ex

#add rogue vars
source /opt/RogueOS/.env

#add host vars
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
[ -f $script_dir/.env ] && source "$script_dir/.env"

#add secrets?
#TODO

echo "Starting RogueOS services"
#depricated?
# function docker_up () {
# 	IFS='_' read -r -a array <<< "$1"
# 	service="${array[0]}"
# 	id="${array[1]}"
# 	env="$2"
# 	yml="${3:-$rogue_wdir/hosts/$machine_name/$1.compose.yml}"
# 	#docker compose -f "$service_wd/$service/docker-compose.yml" -f "$yml" --env-file "$env" config # -d
# 	docker compose -f "$rogue_wdir/hosts/$machine_name/startup/0.novnc.yml"  -f ./service-containers/novnc/docker-compose.yml -f ./service-containers/rogue.labels.yml --env-file ~/.env  --project-name novnc config
# }
rogue_wdir=/opt/RogueOS.bak
#start services
for FILE in `ls $script_dir/startup/ | sort -g`; do
	IFS='.' read -ra array <<< "$FILE"
	service="${array[1]}"
	file_type=$(printf %s\\n "${array[@]:(-1)}")


	if [ "$file_type" = "yml" ]; then
		#if there is an env-file variable in the header then grab it
		env_file="$secrets/.env"
		line=$(head -n 1 "$rogue_wdir/hosts/$machine_name/startup/$FILE")
		if [[ $line == \#env\-file\=* ]]; then
			env_file="${line/\#env\-file\=/}"
			echo "found env_file for yml $env_file"
		fi
		echo "starting service $service from file $FILE filetype=$file_type"
		docker compose -f "$rogue_wdir/hosts/$machine_name/startup/$FILE"  -f "$rogue_wdir/service-containers/$service/docker-compose.yml" --env-file "$env_file"  --project-name "$service" config
	elif [[ "$filetype" = ".sh" ]]; then
		echo "running bash script from file $FILE filetype=$file_type"
		$FILE
	fi
	#todo add  -f ./service-containers/rogue.labels.yml to above command
done