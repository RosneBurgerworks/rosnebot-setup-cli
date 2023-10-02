#!/bin/bash
# Written by Bintr on 21.11.2022
# Purpose: Stop all processes started by the start script.

accounts_length=$(wc -l accounts.txt | awk '{print $1}')
# Stop all bots' firejail instances
for ((i = 0; i < accounts_length; ++i)); do
  firejail --quiet --shutdown=b"$i"
  echo "Stopped bot $i"
done

kill "$(pgrep deletelock.sh)"

# Stop the IPC server
[ -f /tmp/cat-ipc-server.pid ] && sudo kill "$(cat /tmp/cat-ipc-server.pid)"

# Delete the PID file of the IPC server
[ -f /tmp/cat-ipc-server.pid ] && sudo rm /tmp/cat-ipc-server.pid

# Stop pulseaudio
[ -f /tmp/pulsemodule.id ] && pactl unload-module "$(cat /tmp/pulsemodule.id)" && rm /tmp/pulsemodule.id

ipc_server=$(pgrep -f /opt/cathook/ipc/server)
[ -n "$ipc_server" ] && sudo kill "${ipc_server}"
ipc_console=$(pgrep -f /opt/cathook/ipc/console)
[ -n "$ipc_console" ] && sudo kill "${ipc_console}"

# Delete bots' network namespaces
sudo ./shutdown-netspaces.sh "$accounts_length"
