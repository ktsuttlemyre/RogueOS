
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
  - OS='RogueOS'; curl -LkSs https://api.github.com/repos/ktsuttlemyre/RogueOS/tarball -o $OS.tar.gz; mkdir $OS; tar -xzf $OS.tar.gz -C $OS
```
