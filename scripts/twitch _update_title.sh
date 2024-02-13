#!/bin/bash

# Function to get a new OAuth token
get_token() {
  twitch token
}

# Function to update stream title
update_title() {
  twitch stream update --channel <your_channel_name> --title "Your New Title" --token $1
}

# Main script

# Get or refresh token
token=$(get_token)

# Check if the token is not empty
if [ -n "$token" ]; then
  # Update stream title
  update_title "$token"
else
  echo "Failed to get a valid token."
fi
