#!/bin/bash
#post to discord webhook
#https://github.com/fieu/discord.sh

#message="$1"
#hook_url="$2"
#curl -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "{\"content\": \"$message\"}" $hook_url
#get DISCORD_WEBHOOK
source /opt/RogueOS/.env
source $secrets/.env

#how to use ./discord_alert.sh (default,error,warn,info,debug) (text) (any other arguments to send to discord.sh)


#get arguments sent to this script
#it is expected to be default, error, warn, info, etc
type=$1
shift
text=$1
shift
args=("$@")
echo "$type $text"


#set defaults
read -r -d '' default << EOM
{
"--text":"$text",
"--webhook-url":"$DISCORD_WEBHOOK"
}
EOM
read -r -d '' error << EOM
{
"--title":"Error!",
"--description":"$text",
"--color":"0xFF0000",
"--webhook-url":"$DISCORD_WEBHOOK"
}
EOM
read -r -d '' warn << EOM
{
"--title":"Warn!",
"--description":"$text",
"--color":"0xFFF3CD",
"--webhook-url":"$DISCORD_WEBHOOK"
}
EOM
read -r -d '' info << EOM
{
"--title":"Info:",
"--description":"$text",
"--color":"0x0000FF",
"--webhook-url":"$DISCORD_WEBHOOK"
}
EOM
read -r -d '' debug << EOM
{
"--title":"Debug:",
"--description":"$text",
"--color":"0xCFE2FF",
"--webhook-url":"$DISCORD_WEBHOOK"
}
EOM
read -r -d '' success << EOM
{
"--title":"Success!",
"--description":"$text",
"--color":"0x00FF00",
"--webhook-url":"$DISCORD_WEBHOOK"
}
EOM



#turn them into a json string
json="{"
for (( i=0; i<${#args[@]} ; i+=2 )) ; do
	json+="\"${args[i]}\":\"${args[i+1]}\""
	if ! [ -z ${args[i+2]+x} ]; then json+=','; fi
done
json+="}"
#echo "$json"

#use jq to merge the 2 together. first input is overwritten by second
merged=$(jq -n 'reduce inputs as $i ({}; . * $i)' <(echo "${!type}") <(echo "$json"))
#echo "$merged"

#convert merged json string into arguments (delimited by newline)
args=$(echo "$merged" | jq -r '. as $root |
	path(..) | . as $path |
	$root | getpath($path) as $value |
	select($value | scalars) |
	([$path[]] | join("_")) + "\n" + ($value)
	')
echo "$args"

#convert newline string into bash array
IFS=$'\n' y=($args)

#test itis array
#echo "THE FINNAL countdown ${y[3]}"

#run discord.sh to send
./libs/discord.sh/discord.sh "${y[@]}"

