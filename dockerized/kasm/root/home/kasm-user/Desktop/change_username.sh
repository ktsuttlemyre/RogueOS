#!/bin/bash

sudo usermod -l "$2" "$1"
sudo groupmod -n "$2" "$1"
sudo usermod -d $HOME -m "$2"
