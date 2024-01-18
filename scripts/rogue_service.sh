#!/bin/bash

action="${1:-init}"
add_remove="${2:-add}"
service="${3}"

# if [ -z "${service}" && add_remove != ];
# 	echo "Error syntax sent to rogue_service.sh service variable is empty"
# 	exit 1
# fi

#rogue_active_services=()
{ read -a rogue_startup_services; read -a rogue_shutdown_services; } < /opt/RogueOs/$host_name/services.status
declare -p rogue_startup_services
declare -p rogue_shutdown_services

source /opt/RogueOS/.env

#run the action
if [ -f /ops/RogueOS/service-containers/service/$action.sh ]; then
	if [ ! /ops/RogueOS/service-containers/service/$action.sh ]; then
		echo "Rogue Service had an error when trying to $action $service"
		exit 1
	fi
fi

#if it succeded then add to the proper list
case "$action" in
    "init")
		# if [[ ! " ${rogue_active_services[*]} " =~ [[:space:]]${action}[[:space:]] ]]; then
		#     rogue_active_services+=("$action")
		#     echo "Init Rogue Service $service"
		# fi
		exists=[[ " ${rogue_startup_services[*]} " =~ [[:space:]]${service}[[:space:]] ]]
		! exsts && rogue_startup_services+=("$action") && echo "Added Rogue Service $service to startup"
        ;;

    "start")
        # if [[ ! " ${rogue_active_services[*]} " =~ [[:space:]]${action}[[:space:]] ]]; then
		#     rogue_active_services+=("$action")
		#     echo "Activated Rogue Service $service"
		# fi
		echo "Activated Rogue Service $service"
        ;;

    "stop")
		#	if [[ " ${rogue_active_services[*]} " =~ [[:space:]]${action}[[:space:]] ]]; then	  
		#     ${rogue_active_services[@]/$action}
		#     echo "Stopped Rogue Service $service"
		# fi
		echo "Stopped Rogue Service $service"
        ;;

    "startup")
		exists=[[ " ${rogue_startup_services[*]} " =~ [[:space:]]${service}[[:space:]] ]]

		if [[ "$add_remove" = "add" ]]; then
	        ! exsts && rogue_startup_services+=("$action") && echo "Added Rogue Service $service to startup"
		elif [[ "$add_remove" = "remove" ]]; then
			exists && {rogue_startup_services[@]/$action}
		else
			echo "Error adding/removing $service from startup"
		fi
        ;;

    "shudown")
		exists=[[ " ${rogue_shutdown_services[*]} " =~ [[:space:]]${service}[[:space:]] ]]

		if [[ "$add_remove" = "add" ]]; then
	        ! exsts && rogue_shutdown_services+=("$action") && echo "Added Rogue Service $service to shudown"
		elif [[ "$add_remove" = "remove" ]]; then
			exists && {rogue_shutdown_services[@]/$action}
		else
			echo "Error adding/removing $service from shudown"
		fi
        ;;

    "*")
		echo "unknown action sent to rogue_service.sh $1 $2"
esac


{ echo "${rogue_startup_services[*]}"; echo "${rogue_shutdown_services[*]}"; } >/opt/RogueOs/$host_name/services.status