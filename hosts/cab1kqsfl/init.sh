#!/bin/bash

original_pwd=$PWD

#install software for this computer
#npm install --global obs-cli
pip3 install obs-cli
brew install discord --cask


#create self hosted tunnel/gateway
#https://github.com/fractalnetworksco/selfhosted-gateway
git clone https://github.com/fractalnetworksco/selfhosted-gateway.git && cd selfhosted-gateway
make docker
make link GATEWAY=root@123.456.789.101 FQDN=$service.mydomain.com EXPOSE=$service:80 > $secrets/ddns/$service-gateway.yml
  # link:
  #   image: fractalnetworks/gateway-client:latest
  #   environment:
  #     LINK_DOMAIN: nginx.mydomain.com
  #     EXPOSE: nginx:80
  #     GATEWAY_CLIENT_WG_PRIVKEY: 4M7Ap0euzTxq7gTA/WIYIt3nU+i2FvHUc9eYTFQ2CGI=
  #     GATEWAY_LINK_WG_PUBKEY: Wipd6Pv7ttmII4/Oj82I5tmGZwuw6ucsE3G+hwsMR08=
  #     GATEWAY_ENDPOINT: 123.456.789.101:49185
  #   cap_add:
  #     - NET_ADMIN

# #install 2 portable versions of OBS
#untested
#TMPFOLDER=$(mktemp -d /tmp/rogue-XXXXX)
#image_name=OBS
#curl -o $TMPFOLDER/$image_name https://cdn-fastly.obsproject.com/downloads/OBS-Studio-30.0.2-macOS-Intel.dmg
# hdiutil attach $TMPFOLDER/$image_name
# #The image will be mounted to /Volumes/$image_name
#mkdir -p $rogue_wdir/apps
# sudo installer -package /Volumes/$image_name/$image_name.pkg -target $rogue_wdir/apps
#mv $rogue_wdir/apps/OBS.app $rogue_wdir/apps/OBS1.app
# sudo installer -package /Volumes/$image_name/$image_name.pkg -target $rogue_wdir/apps
#mv $rogue_wdir/apps/OBS.app $rogue_wdir/apps/OBS2.app
# chmod +x ~/Applications/OBS1/OBS1.app
# chmod +x ~/Applications/OBS2/OBS2.app
# #Finally unmount the image:
# hdiutil detach /Volumes/$image_name
