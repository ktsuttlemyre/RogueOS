#!/bin/bash

channel='KQSFL'

day="$(date '+%A')"
month="$(date '+%b')"
numerical_date="$(date +'%D')"
hour="$(date '+%H')"


title="$month. $day games [$numerical_date]"

case "$day"
  Monday)
    title="$month. $day Try Hard Games [$numerical_date]"
  ;;
  Thurs)
    title="$month. $day Social Sets [$numerical_date]"
  ;;
  Friday)
    title="$month. $day Fun [$numerical_date]"
  ;;
  Saturday)
    if [ "$hour" -lt 17 ]; then # 5:00
      title="$month. $day Tournament Sets [$numerical_date]"
    else
      title="$month. $day Sloppy Sets [$numerical_date]"
    fi
  ;;
  Sunday)
    if [ "$hour" -lt 17 ]; then # 5:00
      title="$month. $day Tournament Sets [$numerical_date]"
    else
      title="$month. $day Social Sets [$numerical_date]"
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
  twitch stream update --channel "$channel" --title "$title" --token $1
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
