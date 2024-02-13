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

title="${1:-($month. $day games \'$year)}"

case "$day"
  Monday)
    title="$month. $day Try Hard Games \'$year"
  ;;
  Thurs)
    title="$month. $day Social Sets \'$year"
  ;;
  Friday)
    title="$month. $day Fun \'$year"
  ;;
  Saturday)
    if [ "$hour" -lt 17 ]; then # 5:00
      title="$month. $day Tournament Sets \'$year"
    else
      title="$month. $day Sloppy Sets \'$year"
    fi
  ;;
  Sunday)
    if [ "$hour" -lt 17 ]; then # 5:00
      title="$month. $day Tournament Sets \'$year"
    else
      title="$month. $day Social Sets \'$year"
    fi
  ;;
  *)
  echo "unknown $day"
  ;;
esac

echo "$title"

# Function to get a new OAuth token
get_token() {
  twitch token
}

# Function to update stream title
update_title() {
  twitch stream update --channel "$twitch_channel" --title "$title" --token $1
}

# Main script

# Get or refresh token
twitch_token=$(get_token)

# Check if the token is not empty
if [ -n "$twitch_token" ]; then
  # Update stream title
  update_title "$twitch_token"
else
  echo "Failed to get a valid twitch_token."
fi
