apt install -y steam git python3-pip

#monitoring
apt install gpustat conky


# gpro headset
#https://www.reddit.com/r/linuxhardware/comments/o5yrvz/logitech_g_pro_x_wireless_headset_users_on_linux/

apt install pulseeffects lsp-plugins solaar
pacmd load-module module-virtual-surround-sink sink_name=vsurround sink_properties=device.description=VirtualSurround hrir=/opt/hrir/hrir-kemar.wav master=alsa_output.usb-Logitech_PRO_X_Wireless_Gaming_Headset-00.analog-stereo

#ssh
sudo apt install openssh-server
sudo ufw allow ssh
sudo ufw enable
sudo ufw reload
sudo ufw status verbose

#TODO add fail2ban

llama gpt
#TODO use rogeos docker install here
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#installation
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
apt install -y nvidia-docker2
#
# https://hub.docker.com/r/ollama/ollama
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

docker run -d --gpus=all -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
docker exec -it ollama ollama run llama2:70b



#gaming setup
sudo apt install steam
#fix vulkon shader processing
declare -a dirs=("$HOME/.local/share/Steam" "$HOME/.steam/debian-installation" "$HOME/.var/app/com.valvesoftware.Steam/data/Steam/" "$HOME/.local/share/Steam/")

## now loop through the above array
for dir in "${dirs[@]}"; do
    if [ -d $dir ]; then
      folder=$dir
      break
    fi
done

echo "unShaderBackgroundProcessingThreads $(nproc)" >> ${folder}steam_dev.cfg
