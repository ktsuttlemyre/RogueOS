#!/bin/bash
set -e 
set -o pipefail

#Install docker
if [ ! -x "$(command -v docker)" ]; then
	#easily install docker
	#https://www.freecodecamp.org/news/the-easy-way-to-set-up-docker-on-a-raspberry-pi-7d24ced073ef/
	curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh
	#run docker without sudo
	#Add the Docker group if it doesn’t already exist:
	sudo groupadd docker
	#Add the connected user “$USER” to the docker group. Change the user name to match your preferred user if you do not want to use your current user:
	sudo gpasswd -a $USER docker
	#for the changes to take effect logout/in or run :
	newgrp docker

	#You should now be able to run Docker without sudo. To test, try this:
	#docker run hello-world
fi

if [ ! -x "$(command -v docker-compose)" ]; then
	#Running docker-compose as a container and giving it access to volumes.
	docker run \    -v /var/run/docker.sock:/var/run/docker.sock \    -v "$PWD:/rootfs/$PWD" \    -w="/rootfs/$PWD" \    docker/compose:1.13.0 up
	#Next, make an alias to docker compose:
	echo alias docker-compose="'"'docker run \    -v /var/run/docker.sock:/var/run/docker.sock \    -v "$PWD:/rootfs/$PWD" \    -w="/rootfs/$PWD" \    docker/compose:1.13.0'"'" >> ~/.bashrc
	#Then reload bash:
	source ~/.bashrc
fi



