#!/usr/bin/env bash
# Written by Bintr on 14.11.2022
# Purpose: Jail Steam.

# $1 - login and password
# $2 - bot number
# $3 - Steam command

firejail --dns=1.1.1.1 --net="$(ip route | grep default | head -n 1 | awk '{print $5}')" --noprofile --x11=xvfb --blacklist="$(pwd)"/user_instances/b"$1"/.local/share/Steam/ubuntu12_64/steamwebhelper.sh --private="$(pwd)"/user_instances/b"$1" --hostname=localhost --name=b"$2" --env=PULSE_SERVER=unix:/tmp/pulse.sock --env=LD_PRELOAD=~/Desktop/catbot-setup-cli/just-disable-vac/build/bin64/libvpcfs.so.0:~/Desktop/catbot-setup-cli/just-disable-vac/build/bin32/libvpcfs.so.0 "$3" -silent -noreactlogin -login "$1" -nominidumps -no-browser -vrdisable -nocrashmonitor -noshaders >/dev/null 2>&1 &
sleep 30 # Give Steam plenty of time to start
firejail --join=b"$2" /opt/watchdog.sh "$1" "$3" >/dev/null 2>&1 &
