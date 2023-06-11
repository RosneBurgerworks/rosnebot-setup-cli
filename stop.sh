#!/usr/bin/env bash
# Written by Bintr on 21.11.2022
# Purpose: Stop all processes started by the start script.

accounts_length=$(wc -l accounts.txt | awk '{print $1}')
# Stop all bots' firejail instances
for ((i = 0; i < accounts_length; ++i)); do
  firejail --quiet --shutdown=b"$i"
  echo "Stopped bot $i"
done

# Stop pulseaudio
[ -f /tmp/pulsemodule.id ] && pactl unload-module "$(cat /tmp/pulsemodule.id)" && rm /tmp/pulsemodule.id

# Stop nullnexus proxy
if [ -d nullnexus-proxy ]; then
  pushd nullnexus-proxy || exit
  pm2 stop index.js
  popd || exit
fi

ipc_server=$(pgrep -f /opt/cathook/ipc/server)
[ -n "$ipc_server" ] && sudo kill "${ipc_server}"
ipc_console=$(pgrep -f /opt/cathook/ipc/console)
[ -n "$ipc_console" ] && sudo kill "${ipc_console}"

# Stop the telegram relay
if [ -d cathook-tg-relay-bot ]; then
  pushd cathook-tg-relay-bot || exit
  pm2 stop bot.js
  popd || exit
fi

# Delete bots' network namespaces
sudo ./shutdown-netspaces.sh "$accounts_length"
