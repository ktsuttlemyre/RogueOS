#!/bin/bash
#custom image name
set -a      # turn on automatic exporting
source ./params.env
set +a      # turn off automatic exporting

export DOCKER_BUILDKIT=1

# if [ "$1" == "--" ]; then
#   if [ "$2" == "reset" ]; then
#     cd ..
#     rm -rf RogueSecrets/
#     docker rmi $(docker images --filter=reference="rogueos/*:*" -q) -f
#     git clone https://github.com/ktsuttlemyre/RogueSecrets.git
#     cd RogueSecrets/
#     chmod +x ./index.sh ./reset.sh
#     #./index.sh
#   fi
# fi

git_pull () {
  git stash
  git pull
  git stash pop
  git submodule update --init --recursive --remote
}

docker_build () {
  local log; log="$(docker build . -t $project/$image:$tag $1)"
  if [ $? -ne 0 ]; then
    echo "Error building image = $project/$image:$tag" > /dev/stderr
    echo "$log" > /dev/stderr
  fi
}

#if image not already here
if [ -z "$(docker images -q $project/$image:$tag 2> /dev/null)" ]; then
  docker_build
else
  #cache to rebuild image evey week hard rebuild every month
  created_date="$(docker inspect -f '{{ .Created }}' $project/$image:$tag)"
  created_week=$(date +'%V' -d +'%Y-%m-%dT%H:%M:%S' --date="$created_date")
  created_month=$(date +'%m' -d +'%Y-%m-%dT%H:%M:%S' --date="$created_date")
  current_week=$(date +'%V')
  current_month=$(date +'%m')
  if [ "$created_week" -ne "$current_week" ]; then
    git_pull
    [ "$created_month" -ne "$current_month" ] && cache='--no-cache'
    docker_build $cache
  fi
fi

#Run image
#TODO use docker compose
#docker compose -f <( envsubst < docker-compose.yaml ) --env-file <( env ) run --build "${project}"
docker compose -f <( envsubst < docker-compose.yaml ) --env-file <( env ) build
docker run --privileged --rm -it --shm-size=512m -p 6901:6901 -e VNC_PW=password rogueos/rogueos:latest
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
