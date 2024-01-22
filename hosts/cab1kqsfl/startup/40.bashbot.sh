#https://github.com/EnriqueMoran/remoteDiscordShell
mkdir -p $HOME/bashbot
cd $HOME/bashbot

if [ ! -d ./app ]; then
  git clone https://github.com/Adikso/BashBot.git ./app
fi

if [ ! -d ./.venv ]; then
  python3 -m venv .venv
  source .venv/bin/activate
  pip3 install -r ./app/requirements.txt
else
  source .venv/bin/activate
fi


python3 ./app/bashbot.py &
#python3 BashBot.zip
