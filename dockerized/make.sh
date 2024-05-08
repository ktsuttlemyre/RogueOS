#!/bin/bash
#Devnote
#
# Linux Mint 21 is based on Ubuntu 22.04.Jammy Jellyfish
#
#
iso='linuxmint-21.3-cinnamon-64bit.iso'
wget "https://mirrors.seas.harvard.edu/linuxmint/stable/21.3/${ISO}"

#https://medium.com/@SofianeHamlaoui/convert-iso-images-to-docker-images-4e1b1b637d75
mkdir rootfs unquashfs
sudo mount -o loop "${iso}" rootfs
shfs=$(find . -type f | grep filesystem.squashfs | head -n 1)
sudo unsquashfs -f -d unsquashfs/ "${shfs}"
sudo tar -C unsquashfs -c . | docker import - rogueos/base
#test
#docker run -h ubuntu -i -t rogueos/base bash

#add kasmvnc
#https://github.com/linuxserver/docker-baseimage-kasmvnc

