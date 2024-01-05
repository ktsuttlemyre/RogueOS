#Descripion

For many years computers always had a keyboard, mouse, and monitor. After introducing the internet and the concept of The Internet of Things computers interact with and each other in many different ways. This project is the base OS for several of my other projects. RogueOS attempts to become what you need when you need it to fill that need. It does this by detecting how it can interact with the environment and sets itself up to best use that interaction.

RogueOS the base for my upcoming projects. At the heart of each functionality is an open source project but augmented for better experiences.

I have done a lot of customization and research to find the best tools to augment these functions.

###Rogue projects strive to be
 - Portable
 - one click installs and activations of features on any device
 - scriptible 
 - Responsive (will change functionality based on peripheral)
 - OS independent (priority: Web Tech > Linux > Mac > Windows)

Most of the projects depend on a core open source project but enhanced and customized to be more robust than they come.

###Modes of operation
|                   	| Monitor 	| Keyboard 	| Mouse 	| Gaming Pad 	| Internet 	| Intranet 	| Mic 	|
|-------------------	|:-------:	|:--------:	|:-----:	|:----------:	|:--------:	|:--------:	|:---:	|
| RogueOS           	|    \    	|     \    	|   \   	|      \     	|     \    	|     \    	|  \  	|
| RogueWM           	|    X    	|     X    	|   \   	|      \     	|     \    	|     \    	|  \  	|
| RogueCast         	|    X    	|          	|       	|      \     	|     \    	|     \    	|  \  	|
| RogueConsole         	|    X    	|     \    	|   \   	|      \     	|          	|     \    	|     	|
| RogueRadio        	|         	|          	|       	|            	|     \    	|     \    	|  \  	|
| Fourier (Backend) 	|         	|          	|       	|            	|     \    	|     \    	|     	|

Key
 X = Required
 \ = Optional


Projects Running on RogueOS
RogueWM - Window manager for when you are in Personal Computer mode
RogueCast - A media casting endpoint
RogueConsole - gaming system
RogueRadio - Radio player aimed for car stereo
Fourier - (browser based window manager/thin client)

Projects that will interact with this environment
RoguePad - Gaming pad for the phone



# Remote Install
## Read only install (no git interaction)
```bash
wget -O - https://raw.githubusercontent.com/ktsuttlemyre/RogueOS/master/remote_install.sh | bash
```
```bash
bash <( curl -s https://raw.githubusercontent.com/ktsuttlemyre/RogueOS/master/remote_install.sh )
```

if first argument is `dev` it will use git to install RogueOS
if first argument is empty then it will be downloaded as a file



In a runcmd cloud-init script
```yaml
#need update depreicated
runcmd:
  - export OS='RogueOS'
  - curl -LkSs https://api.github.com/repos/ktsuttlemyre/RogueOS/tarball -o $OS.tar.gz
  - mkdir $OS
  - tar -xzf $OS.tar.gz -C $OS
  - chmod +x $OS.sh
  - ./$OS.sh
```
The above can be appended to the `system-boot:/user-data` file in a raspberry pi image even on a windows machine after using etcher as the `system-boot` partition is fat32
s
