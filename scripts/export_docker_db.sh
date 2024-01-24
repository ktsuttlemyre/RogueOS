#!/bin/bash
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$(dirname $script_dir)/env"
source "$secrets/.env"
conainer_name="$1"
root_password="$2"
database="$3"
id=$(docker ps -aqf "name=$container_name")
docker exec "$id" /usr/bin/mysqldump -u root --password="$root_password" "$database"
