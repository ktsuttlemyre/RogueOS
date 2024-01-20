#!/bin/bash
#set -ex

action="${1:-init}"
add_remove="${2:-add}"
service="${3:-$2}"

if [ "$add_remove" = "$service" ]; then
	add_remove='add'
fi

source "/opt/RogueOS/.env"

# if [ -z "${service}" && add_remove != ];
# 	echo "Error syntax sent to rogue_service.sh service variable is empty"
# 	exit 1
# fi

if [ -f $rogue_wdir/hosts/$machine_name/services.status ]; then
	echo "read from file"
	{ read -a rogue_startup_services; read -a rogue_shutdown_services; } <$rogue_wdir/hosts/$machine_name/services.status
	#declare -p rogue_active_services
	declare -p rogue_startup_services
	declare -p rogue_shutdown_services
else
	echo "declare"
	touch $rogue_wdir/hosts/$machine_name/services.status
	#declare -p rogue_active_services=()
	declare -p rogue_startup_services=()
	declare -p rogue_shutdown_services=()
fi

#run the action
if [ -f /opt/RogueOS/service-containers/$service/$action.sh ]; then
	echo "Running $action on $service"
	if [ ! /opt/RogueOS/service-containers/$service/$action.sh ]; then
		echo "Rogue Service had an error when trying to $action $service" >&2
		exit 1
	fi
fi

#[[ " ${rogue_active_services[*]} " =~ [[:space:]]${service}[[:space:]] ]]
#is_active=$?
[[ " ${rogue_startup_services[*]} " =~ [[:space:]]${service}[[:space:]] ]]
is_startup=$?
[[ " ${rogue_shutdown_services[*]} " =~ [[:space:]]${service}[[:space:]] ]]
is_shutdown=$?

echo "$action"
#if it succeded then add to the proper list
case "$action" in
    "init")
		##if service not found in array then add it
		#! $is_active && rogue_active_services+=("$service") && echo "Added Rogue Service $service to active"

		#if the service not found in array then add it
		[ "$is_startup"  -eq "1" ] && rogue_startup_services+=("$service") && echo "Added Rogue Service $service to startup"
        ;;

    "start")
		##if service not found in array then add it
		#! $is_active && rogue_active_services+=("$service") && echo "Activated Rogue Service $service"
        ;;

    "stop")
		##if the above service not found in array then add it
		#$is_active && ${rogue_active_services[@]/$service} && echo "Stopped Rogue Service $service"

        ;;

    "startup")
		if [[ "$add_remove" = "add" ]]; then
	        [ "$is_startup" -eq "1" ] && rogue_startup_services+=( "$service" ) && echo "Added Rogue Service $service to startup"
		elif [[ "$add_remove" = "remove" ]]; then
			[ "$is_startup" -eq "0" ] && rogue_startup_services=( "${rogue_startup_services[@]/$service}" )
		else
			echo "Error adding/removing $service from startup" >&2
			exit 1
		fi
        ;;

    "shutdown")
		if [[ "$add_remove" = "add" ]]; then
	        [ "$is_shutdown" -eq "1" ] && rogue_shutdown_services+=( "$service" ) && echo "Added Rogue Service $service to shudown"
		elif [[ "$add_remove" = "remove" ]]; then
			[ "$is_shutdown" -eq "0" ] && rogue_shutdown_services=( "${rogue_shutdown_services[@]/$service}" )
		else
			echo "Error adding/removing $service from shudown" >&2
			exit 1
		fi
        ;;

    "*")
		echo "unknown action sent to rogue_service.sh $1 $2" >&2
		exit 1
esac

printf "%s\n" "${rogue_startup_services[*]}" "${rogue_shutdown_services[*]}" > $rogue_wdir/hosts/$machine_name/services.status
