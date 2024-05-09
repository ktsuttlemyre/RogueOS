#https://github.com/linuxserver/docker-baseimage-kasmvnc
FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm


#
#  Add package repos
#
RUN apt remove -y openbox
RUN \
  #ensure apt is set up to work with https sources:
  apt update && \
  apt install -y apt-transport-https \
  #sublime text
  #https://www.sublimetext.com/docs/linux_repositories.html#apt
  wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null \
  echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list



RUN \
  apt update && \
  apt install -y \
   firefox-esr \
#   sublime-text \
   xclip 
#   i3-wm


COPY ./root /
RUN apt install -y cinnamon-desktop-environment

ARG exe=''
#
# Configurations
#
RUN \
#  if [ -z "$exe" ]; then \
    #echo "/usr/bin/i3" > /defaults/startwm.sh; \
    echo "/usr/bin/cinnamon" > /defaults/startwm.sh; 
#  else \
#    echo "$exe" > /defaults/autostart; \
#  fi
#RUN echo "export DISPLAY=:1" >> /root/.bashrc 
#RUN echo "export PATH="$PATH"" >> /root/.bashrc 

RUN useradd -ms /bin/bash shipwash
#which creates a home directory for the user and ensures that bash is the default shell.
USER shipwash
WORKDIR /home/shipwash

#USER kasm-user
