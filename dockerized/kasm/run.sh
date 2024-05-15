#!/bin/bash
#custom image name
set -a      # turn on automatic exporting
source ./params.env
set +a      # turn off automatic exporting

export DOCKER_BUILDKIT=1

git_pull () {
  git stash
  git pull
  git stash pop
  git submodule update --init --recursive --remote
}


build_base () {
  cache="${1}"
  local log; log="$(docker build . -t $project/$image:$tag $1)"
  if [ $? -ne 0 ]; then
    echo "Error building image = $project/$image:$tag" > /dev/stderr
    echo "$log" > /dev/stderr
    exit 1
  fi
  
  #Build image
  #docker compose -f <( envsubst < docker-compose.yaml ) --env-file <( env ) build $cache
}


run () {
  host_name="${1}"
  user_name="${2:-kasm-user}"
  if [ -z "$(docker images -q $project/$image:$tag 2> /dev/null)" ]; then
    build_base
  fi
  if [ -z "$host_name" ]; then
    image_name=${project}/${image}:${tag}
  else
    image_name=${project}/${image}:${tag}-$host_name
    if [ -z "$(docker images -q $image_name 2> /dev/null)" ]; then
      docker tag ${project}/${image}:${tag} $image_name
    fi
  fi
  #if image not already here
  # if [ -z "$(docker images -q $project/$image:$tag 2> /dev/null)" ]; then
  #   build_base
  # else
  #   #cache to rebuild image evey week hard rebuild every month
  #   created_date="$(docker inspect -f '{{ .Created }}' $project/$image:$tag)"
  #   created_week=$(date +'%V' -d +'%Y-%m-%dT%H:%M:%S' --date="$created_date")
  #   created_month=$(date +'%m' -d +'%Y-%m-%dT%H:%M:%S' --date="$created_date")
  #   current_week=$(date +'%V')
  #   current_month=$(date +'%m')
  #   if [ "$created_week" -ne "$current_week" ]; then
  #     git_pull
  #     [ "$created_month" -ne "$current_month" ] && cache='--no-cache'
  #     build_base $cache
  #   fi
  # fi

  container_name=rogueos-${host_name:-base}
  #!!! don't use --rm in run unless you set up a server on the host to run docker commit before exiting the container
  docker run --privileged  -it --name $container_name -v $HOME/$host_name:/home/rogue --shm-size=512m -p 6901:6901 -e VNC_PW=password $image_name
  if ! [ -z "$is_service" ]; then
     docker compose -f <( envsubst < docker-compose.yaml ) down
  fi
    
  # rogue_envvars="${PWD}/.exported_envs.env"
  # if [ -f $rogue_envvars ]; then
  #   unamestr=$(uname)
  #   if [ "$unamestr" = 'Linux' ]; then
  #     export $(grep -v '^#' $rogue_envvars | xargs -d '\n')
  #   elif [ "$unamestr" = 'FreeBSD' ] || [ "$unamestr" = 'Darwin' ]; then
  #     export $(grep -v '^#' $rogue_envvars | xargs -0)
  #   fi
  #   rm $rogue_envvars
  # fi
  if [ -z "$host_name" ]; then
    docker commit $container_name $image_name
    docker rm $container_name
  fi
}

#if [ "$1" == "--" ]; then
case "$1" in
  "build")
    build_base "$2"
    ;;
  "run"|"")
    run "$2"
    ;;
  "inspect")
     echo "devnote: use https://github.com/wagoodman/dive/"
    ;;
  "reset")
    echo "untested, please fix"
    #cd ..
    #rm -rf RogueSecrets/
    #docker rmi $(docker images --filter=reference="rogueos/*:*" -q) -f
    #git clone https://github.com/ktsuttlemyre/RogueSecrets.git
    #cd RogueSecrets/
    #chmod +x ./index.sh ./reset.sh
    #./index.sh
    ;;
  *)
    echo "error unknown commands $@"
esac
#fi
