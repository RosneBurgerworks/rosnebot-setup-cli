#!/usr/bin/env bash
# Written by Bintr on 14.11.2022
# Purpose: Jail Steam.

login=$1
bot_id=$2
steam_command=$3

firejail --dns=1.1.1.1 --net="$(ip route | grep default | head -n 1 | awk '{print $5}')" --noprofile --x11=xvfb --blacklist="$(pwd)"/user_instances/b"$bot_id"/.local/share/Steam/ubuntu12_64/steamwebhelper.sh --private="$(pwd)"/user_instances/b"$bot_id" --hostname=localhost --name=b"$bot_id" --env=PULSE_SERVER=unix:/tmp/pulse.sock --env=LD_PRELOAD=~/Desktop/catbot-setup-cli/just-disable-vac/build/bin64/libvpcfs.so.0:~/Desktop/catbot-setup-cli/just-disable-vac/build/bin32/libvpcfs.so.0 "$steam_command" -silent -login "$login" -nominidumps -vrdisable -nocrashmonitor -noshaders >/dev/null 2>&1 &
sleep 40 # Give Steam plenty of time to start
firejail --join=b"$bot_id" /opt/watchdog.sh "$login" "$steam_command" >/dev/null 2>&1 &
