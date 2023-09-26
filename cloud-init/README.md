
Use the command 
```bash
OS='RogueOS'
curl -LkSs https://api.github.com/repos/ktsuttlemyre/RogueOS/tarball -o $OS.tar.gz
mkdir $OS
tar -xzf $OS.tar.gz -C $OS
```
to download the whole repo


In a runcmd cloud-init script
```yaml
runcmd:
  - export OS='RogueOS'
  - curl -LkSs https://api.github.com/repos/ktsuttlemyre/RogueOS/tarball -o $OS.tar.gz
  - mkdir $OS
  - tar -xzf $OS.tar.gz -C $OS
  - chmod +x $OS.sh
  - ./$OS.sh
```
The above can be appended to the `system-boot:/user-data` file in a raspberry pi image even on a windows machine after using etcher as the `system-boot` partition is fat32
