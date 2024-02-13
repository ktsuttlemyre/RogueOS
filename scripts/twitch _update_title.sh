#!/bin/bash

#twitch_channel='${1:-KQSFL}'
if [ -z "$twitch_channel" ]; then
  if [[ $machine_name == "cab1kqsfl" ]]; then
    twitch_channel='KQSFL'
  elif [[ $machine_name == "cab2kqfl" ]]; then
    twitch_channel='KQSFL_2'
  else
    echo "Env Variable twitch_channel can not be determined"
    exit 1
  fi
fi

day="$(date '+%A')"
month="$(date '+%b')"
numerical_date="$(date +'%D')"
hour="$(date '+%H')"
year="$(date '+%y')"


if [ -z "$1" ]; then
  case "$day" in
    Monday)
      title="$month. $day Try Hard Games '$year"
    ;;
    Thurs)
      title="$month. $day Social Sets '$year"
    ;;
    Friday)
      title="$month. $day Fun '$year"
    ;;
    Saturday)
      if [ "$hour" -lt 17 ]; then # 5:00
        title="$month. $day Tournament Sets '$year"
      else
        title="$month. $day Sloppy Sets '$year"
      fi
    ;;
    Sunday)
      if [ "$hour" -lt 17 ]; then # 5:00
        title="$month. $day Tournament Sets '$year"
      else
        title="$month. $day Social Sets '$year"
      fi
    ;;
    *)
      title="$month. $day Social Sets '$year"
    ;;
  esac
else
  title="$1"
fi
  
echo "$title"


# Main script

# Get or refresh token
twitch_token=$(twitch token 2>&1 >/dev/null |rev | cut -f 1 -d' '| rev)
echo "$twitch_token"
# Check if the token is not empty
if [ -n "$twitch_token" ]; then
  # Update stream title
#curl -X PUT "https://api.twitch.tv/helix/channels/btm_pl?channel\[status\]=big_test&_method=put&oauth_token=$twitch_token"
curl -X PATCH 'https://api.twitch.tv/helix/channels?broadcaster_id=XXXXX' \
-H 'Authorization: Bearer XXXXXXXX' \
-H 'Client-Id: XXXXXXXX' \
-H 'Content-Type: application/json' \
--data-raw '{"game_id":"XXXX", "title":"there are helicopters in the game? REASON TO PLAY FORTNITE found", "broadcaster_language":"en", "tags":["LevelingUp"]}'

# 'Client-ID: XXXXXX' \
# -H 'Accept: application/vnd.twitchtv.v5+json' \
# -H 'Authorization: OAuth YYYYYY' \ -d 'channel[game]=Mordhau' \
    #                 url: ,




    # let options = {
    #         url: "https://api.twitch.tv/kraken/channels/"+t.settings.current_channel+"?status="+new_title,
    #         headers: {
    #             "Authorization": "OAuth "+t.settings.clientId,
    #             "Accept": "application/vnd.twitchtv.v2+json"
    #         }
else
  echo "Failed to get a valid twitch_token."
fi
