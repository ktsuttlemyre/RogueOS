#!/bin/bash
docker run --rm -it --shm-size=512m -p 6901:6901 -e VNC_PW=password rogueos/rogueos:latest
