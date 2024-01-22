#originally
#https://github.com/EnriqueMoran/remoteDiscordShell
mkdir -p $HOME/discord-file-transfer-bot
cd $HOME/discord-file-transfer-bot
if [ ! -d ./.venv ]; then
  python3 -m venv .venv
  source .venv/bin/activate
  python3 -m pip install 'requests==2.31.0'
  python3 -m pip install 'discord==2.3.2'
else
  source .venv/bin/activate
fi
if [ ! -d ./app ]; then
  git clone https://github.com/ktsuttlemyre/discord-file-transfer-bot.git ./app
fi

python3 ./app/discord-file-transfer-bot.py &
