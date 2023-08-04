#!/bin/bash
# Written by Bintr on 14.11.2022
# Purpose: Jail Steam.

login=$1
bot_id=$2
steam_command=$3

# Start firejail instance with Steam
firejail --dns=1.1.1.1 --net="$(route -n | grep '^0\.0\.0\.0' | grep -o '[^ ]*$' | head -1)" --veth-name=veth"$bot_id" --noprofile --nodvd --noinput --notv --nou2f --novideo --quiet --x11=xvfb --private="$(pwd)"/user_instances/b"$bot_id" --hostname=localhost --name=b"$bot_id" --env=PULSE_SERVER=unix:/tmp/pulse.sock --env=LD_PRELOAD=/opt/bin64/libvpcfs.so.0:/opt/bin32/libvpcfs.so.0 "$steam_command" -silent -vrdisable -nocrashmonitor -skipstreamingdrivers -cef-disable-d3d11 -cef-single-process -cef-disable-gpu -cef-disable-breakpad -login $login >/tmp/b"$bot_id" 2>&1 &

# Sleeping for less will not give firejail enough time to start the sandbox
sleep 2
firejail -c --quiet --join=b"$bot_id" /opt/setup-steamapps.sh >/dev/null 2>&1 &

# Run watchdog inside script
firejail -c --quiet --join=b"$bot_id" /opt/watchdog.sh "$login" "$steam_command" "$bot_id" >/dev/null 2>&1 &
