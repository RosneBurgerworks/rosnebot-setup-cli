#!/bin/bash
# Written by Bintr on 14.11.2022
# Purpose: Start rosnebots along with other needed scripts.

if [ $EUID -eq 0 ]; then
  echo "This script must not be run as root!"
  exit
fi

# Start the IPC server
[ -z $(pgrep -f /opt/cathook/ipc/bin/server) ] && /opt/cathook/ipc/bin/server -s >/dev/null &

if [ -x "$(command -v pulseaudio)" ]; then
  echo "Setting up Pulseaudio socket..."
  pulse=$(pgrep -u "$USER" pulseaudio)
  [ -n "$pulse" ] && pulseaudio --start &>/dev/null &
  pactl load-module module-native-protocol-unix auth-anonymous=1 socket=/tmp/pulse.sock >/tmp/pulsemodule.id
fi

if [ -x "$(command -v steam-native)" ]; then
  steam_command="steam-native"
else
  steam_command="steam"
fi

# Copy scripts to a folder where all bots have access
sudo cp -u watchdog.sh /opt/
sudo cp -u setup-steamapps.sh /opt/

# Mount it somewhere all bots have access to
sudo mkdir -p /opt/steamapps
mountpoint -q /opt/steamapps || sudo mount --bind ~/.steam/steam/steamapps/ /opt/steamapps

filename="accounts.txt"
accounts_length=$(wc -l $filename | awk '{print $1}')
if [ "$accounts_length" -gt 255 ]; then
  echo "You have more than 255 accounts. The IPC will not be able to handle all, and some will not be able to connect!"
fi

# Start source lock watchdog
./deletelock.sh >/dev/null 2>&1 &

sudo ./setup-netspaces.sh "$accounts_length"
index=0
# Start up all bots
while read -r login; do
  mkdir -p user_instances/b"$index"
  ./bot.sh "$login" "$index" "$steam_command"
  echo "Started bot $index"
  ((index++))
done <$filename
