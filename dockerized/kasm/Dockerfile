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

######### Custom RogueOS Here ###########

#add sudo
RUN apt-get update \
    && apt-get install -y --no-install-recommends sudo \
    && echo 'kasm-user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && rm -rf /var/lib/apt/list/*

#
#remove snap
#

#https://gist.github.com/allisson/7ff8487b696fd30c4767341d3d797595
COPY ./build ./
RUN for sh in ./build/*.sh; do chmod +x $sh && $sh; done && rm -rf ./build

# tip from https://www.omgubuntu.co.uk/2022/04/how-to-install-firefox-deb-apt-ubuntu-22-04
#add-apt-repository -y ppa:mozillateam/ppa
#echo '
#Package: *
#Pin: release o=LP-PPA-mozillateam
#Pin-Priority: 1001
#' | tee /etc/apt/preferences.d/mozilla-firefox

#
#  Add package repos
#


#  Add GPG keys
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
  cp /usr/share/applications/sublime_text.desktop $HOME/Desktop/ \
  && chmod +x $HOME/Desktop/sublime_text.desktop \
  && chown 1000:1000 $HOME/Desktop/sublime_text.desktop

# Add startup rutine
RUN \
  echo "/usr/bin/desktop_ready && /opt/sublime_text/sublime_text &" > $STARTUPDIR/custom_startup.sh \
  && chmod +x $STARTUPDIR/custom_startup.sh

# change background RUN wget https://cdn.hipwallpaper.com/i/92/9/0Ts6mr.png -O /usr/share/backgrounds/bg_default.png

#sublime text updated docs?
#https://www.sublimetext.com/docs/linux_repositories.html#apt
#wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archiv>
#echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list


COPY ./root /
#RUN apt-get install -y cinnamon-desktop-environment

ARG exe=''
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



##### GTK Theme Options
RUN \
    GTKTHEME=( "Default" "Greybird" "Greybird-dark" "Orchis-Light" "Orchis-Dark" ) && \
    ##### Window Manager Options
    XFWM4THEME=( "Default" "Greybird" "Greybird-dark" "Orchis-Light" "Orchis-Dark" ) && \
    ##### Background Options
    # WALLPAPER[1]=/usr/share/backgrounds/xfce/xfce-verticals.png
    # WALLPAPER[2]=/usr/share/backgrounds/xfce/xfce-blue.png
    # WALLPAPER[3]=/home/toz/upload/2560x1440.png
    # WALLPAPER[4]=/home/toz/upload/1920x1080.png
    ##### make the changes
    xfconf-query -c xsettings -p /Net/ThemeName -s ${GTKTHEME[2]} && \
    xfconf-query -c xfwm4 -p /general/theme -s ${XFWM4THEME[2]}

#xfconf-query -c xfce4-desktop -p  /backdrop/screen0/monitorVirtual-1/workspace0/last-image -s ${WALLPAPER[$1]}



######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
