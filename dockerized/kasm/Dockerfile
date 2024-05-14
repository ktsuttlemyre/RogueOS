#https://github.com/linuxserver/docker-baseimage-kasmvnc
#FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm
FROM kasmweb/ubuntu-jammy-dind-rootless:1.15.0-rolling
#FROM kasmweb/core-ubuntu-jammy:1.15.0-rolling
#custom image code
#https://kasmweb.com/docs/latest/how_to/building_images.html
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

##########################################
######### Custom RogueOS Below ###########

########################
#      Add sudo
########################
RUN apt-get update \
    && apt-get install -y --no-install-recommends sudo \
    && echo 'kasm-user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && rm -rf /var/lib/apt/list/*

########################
#   Run Build scripts
########################
COPY ./build ./build
RUN for sh in ./build/pre.*.sh; do chmod +x $sh && $sh; done

# tip from https://www.omgubuntu.co.uk/2022/04/how-to-install-firefox-deb-apt-ubuntu-22-04
#add-apt-repository -y ppa:mozillateam/ppa
#echo '
#Package: *
#Pin: release o=LP-PPA-mozillateam
#Pin-Priority: 1001
#' | tee /etc/apt/preferences.d/mozilla-firefox

########################
#  Add package repos
########################
RUN  \
  wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add - \
  && apt-get update \
  && apt-get install -y --no-install-recommends \ 
    apt-transport-https \
  ## add deb packages
  && echo "deb https://download.sublimetext.com/ apt/stable/" |  tee /etc/apt/sources.list.d/sublime-text.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    sublime-text \
    xclip \
    inotify-tools \
    i3-wm \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
RUN \
  ## add desktop icons
  cp /usr/share/applications/sublime_text.desktop $HOME/Desktop/
#cp /usr/share/applications/*.desktop $HOME/Desktop/
RUN for dsk in $HOME/Desktop/*.desktop; do chmod +x $dsk && chown 1000:1000 $dsk; done 


# # Add startup rutine
RUN \
  echo "/usr/bin/desktop_ready && xfconf-query -c xsettings -p /Net/ThemeName -s 'Greybird-dark' && xfconf-query -c xfwm4 -p /general/theme -s 'Greybird-dark'" > $STARTUPDIR/custom_startup.sh \
  && chmod +x $STARTUPDIR/custom_startup.sh


# change background RUN wget https://cdn.hipwallpaper.com/i/92/9/0Ts6mr.png -O /usr/share/backgrounds/bg_default.png

#sublime text updated docs?
#https://www.sublimetext.com/docs/linux_repositories.html#apt
#wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archiv>
#echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list


COPY ./root /
#RUN apt-get install -y cinnamon-desktop-environment

#ARG exe=''
#
# Configurations
#
#RUN \
#  if [ -z "$exe" ]; then \
    #echo "/usr/bin/i3" > /defaults/startwm.sh; \
#    echo "/usr/bin/cinnamon" > /defaults/startwm.sh;
#  else \
#    echo "$exe" > /defaults/autostart; \
#  fi
#RUN echo "export DISPLAY=:1" >> /root/.bashrc 
#RUN echo "export PATH="$PATH"" >> /root/.bashrc 

RUN for sh in ./build/post.*.sh; do chmod +x $sh && $sh; done && rm -rf ./build

####################################################
######### End Rogue Customizations Above ###########
####################################################

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
