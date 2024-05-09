#!/bin/bash

docker build . -t rogueos/rogueos:latest
docker run --rm -it -p 3000:3000 rogueos/rogueos:latest bash
