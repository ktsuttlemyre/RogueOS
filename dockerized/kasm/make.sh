#!/bin/bash
#Devnote
#
# Linux Mint 21 is based on Ubuntu 22.04.Jammy Jellyfish
#
#
iso='linuxmint-21.3-cinnamon-64bit.iso'
wget -e robots=off "https://mirrors.seas.harvard.edu/linuxmint/stable/21.3/${ISO}"

#https://medium.com/@SofianeHamlaoui/convert-iso-images-to-docker-images-4e1b1b637d75
declare -a dirs=("rootfs" "unquashfs" "docker-baseimage-kasmvnc")

for dir in "${dirs[@]}"; do
  if [ -d "./$dir" ]; then
   sudo rm -rf "./$dir"
  fi
  mkdir "./$dir"
done

git clone https://github.com/linuxserver/docker-baseimage-kasmvnc.git -b ubuntujammy

sudo mount -o loop "${iso}" rootfs
shfs=$(sudo find . -type f | grep filesystem.squashfs | head -n 1)
sudo unsquashfs -f -d unsquashfs/ "${shfs}"
sudo tar -C unsquashfs -c . | docker import - rogueos/base
sudo umount rootfs
rm -rf rootfs
rm -rf unsquashfs
#test
#docker run -h ubuntu -i -t rogueos/base bash

#add kasmvnc
#https://github.com/linuxserver/docker-baseimage-kasmvnc
docker build . -t rogueos/rogueos:latest

