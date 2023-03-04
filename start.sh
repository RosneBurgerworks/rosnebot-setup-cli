#!/usr/bin/env bash
# Written by Bintr on 14.11.2022
# Purpose: Start cathook bots along with other needed scripts.

if [ $EUID -eq 0 ]; then
  echo "This script must not be run as root!"
  exit
fi

# Start the IPC server
ipc_server=$(pgrep /opt/cathook/ipc/bin/server)
[ -z "$ipc_server" ] && /opt/cathook/ipc/bin/server -s >/dev/null &
[ -z "$ipc_server" ] && echo $! >/tmp/cat-ipc-server.pid

# Start nullnexus proxy
if [ -d nullnexus-proxy ]; then
  pushd nullnexus-proxy || exit
  pm2 start index.js
  popd || exit
fi

# Start the Telegram relay
if [ -d cathook-tg-relay-bot ]; then
  pushd cathook-tg-relay-bot || exit
  pm2 start bot.js
  popd || exit
fi

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

# Symlink watchdog to a folder all bots have access to
sudo cp -u watchdog.sh /opt/

filename="accounts.txt"
accounts_length=$(wc -l $filename | awk '{print $1}')
sudo ./setup-netspaces.sh "$accounts_length"
index=0
# Start up all bots
while read -r login; do
  mkdir -p user_instances/b"$index"
  ./bot.sh "$login" "$index" "$steam_command"
  ((index++))
done <$filename
