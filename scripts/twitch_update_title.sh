#!/bin/bash

set -euo pipefail

day="$(date '+%A')"
month="$(date '+%b')"
numerical_date="$(date +'%D')"
hour="$(date '+%H')"
year="$(date '+%y')"


if [ $# -eq 0 ] ;  then
   echo 'must define args'
   exit 1
fi

while [ $# -ne 0 ] ;  do
  
  if [ $1 == '--client-secret'  ] ; then
    shift
    CLIENT_SECRET=$1
    echo 'setting client secret'
    shift
  elif [ $1 == '--client-id'  ] ; then
    shift
    echo 'setting client id'
    CLIENT_ID=$1
    shift
  elif [ $1 == '--user'  ] ; then
    shift
    echo 'setting username'
    USERNAME=$1
    shift
  elif [ $1 == '--channel'  ] ; then
    shift
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
    shift
  elif [ $1 == '--title'  ] ; then
    shift
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
    shift
  else
    echo "unknown option '$1'"
    exit 1
  fi
done

  


# Main script
# https://dev.twitch.tv/docs/api/reference/

# Get or refresh token
token_request=$(curl -X POST 'https://id.twitch.tv/oauth2/token' \
-H 'Content-Type: application/x-www-form-urlencoded' \
-d "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&grant_type=client_credentials")

resp_status=$(echo $token_request | jq .status)
echo $token_request | jq
if [ "$resp_status" == '400' ] ; then
  echo 'error fetching token'
  exit 1
fi


twitch_token=$(echo $token_request | jq -r .access_token)
echo "Twitch token: $twitch_token"

echo "Getting Broadcaster ID"

broadcaster_id=$(curl -X GET "https://api.twitch.tv/helix/users?login=$USERNAME" -H "Authorization: Bearer $twitch_token" -H "Client-Id: $CLIENT_ID" | jq -r .data[0].id)

echo "Broadcaster ID: $broadcaster_id"

echo 'Getting channel info'

curl -X GET "https://api.twitch.tv/helix/channels?broadcaster_id=$broadcaster_id" \
-H "Authorization: Bearer $twitch_token" \
-H "Client-Id: $CLIENT_ID"

echo 'Getting User Access Token'
user_resp=$(curl --location 'https://id.twitch.tv/oauth2/device'     --form "client_id=\"$CLIENT_ID\""     --form 'scopes="channel:manage:broadcast"')
echo "go to the following URL to verify access"
echo $user_resp | jq -r .verification_uri

device_code=$(echo $user_resp | jq -r .device_code)

read -p "Press Enter to continue"

auth_resp=$(curl --location 'https://id.twitch.tv/oauth2/token'     --form "client_id=\"$CLIENT_ID\""     --form 'scopes="channel:manage:broadcast"'     --form "device_code=\"$device_code\""     --form 'grant_type="urn:ietf:params:oauth:grant-type:device_code"')

twitch_token=$(echo $auth_resp | jq -r .access_token)

echo 'Updating channel info'

game_id=12333

curl -vv -X PATCH "https://api.twitch.tv/helix/channels?broadcaster_id=$broadcaster_id" \
-H "Authorization: Bearer $twitch_token" \
-H "Client-Id: $CLIENT_ID" \
-H 'Content-Type: application/json' \
--data-raw "{
             \"title\":\"there are helicopters in the game? REASON TO PLAY FORTNITE found\",
       \"broadcaster_language\":\"en\",
       \"tags\":[\"LevelingUp\"]
     }"
