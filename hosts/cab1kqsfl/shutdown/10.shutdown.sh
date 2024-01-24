#shutdown obs gracefully
obs-cli -H 'localhost' -P 4455 -p $obs_websocket_password stream stop
obs-cli -H 'localhost' -P 4455 -p $obs_websocket_password record stop
sleep 60
pkill -INT OBS

#sudo shutdown now