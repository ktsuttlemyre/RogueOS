#!/bin/bash

pi_user="$1"
pi_ip="$2"

if [ -z "pi_user" ]; then
  echo "Please provide a Pi username"
  exit 1
fi


if [ -z "pi_user" ]; then
  echo "Please provide a Pi IP address"
  exit 1
fi

echo -n "Password to log into $pi_ip with user $pi_user"
read -s password
echo
sshpass -p "$password" ssh -L 53682:localhost:53682 -C -N -l $pi_user $pi_ip &
SSH_TUNNEL_PID=$!

sshpass -p "$password" ssh -t $pi_user@$pi_ip 'cd /a/great/place; bash'
password=false
unset password

kill $SSH_TUNNEL_PID
