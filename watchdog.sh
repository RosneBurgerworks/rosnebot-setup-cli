#!/usr/bin/env bash
# Written by Bintr on 28.01.2023
# Purpose: Restarts Steam and TF2 in case they crash.

login=$1
steam_command=$2

# Increase this if it's the first time you're starting a bot, and it has to install Steam
sleep 10

while :; do
  # Check if Steam is started and start TF2
  if [ "$(pidof steam | wc -w)" -eq 1 ] && [ "$(pidof hl2_linux | wc -w)" -eq 0 ]; then
    cd /home/"$USER"/.local/share/Steam/steamapps/common/Team\ Fortress\ 2 && LD_LIBRARY_PATH="$LD_LIBRARY_PATH:./bin" LD_PRELOAD="/opt/novisual.so:/opt/bin64/libvpcfs.so.0:/opt/bin32/libvpcfs.so.0" PULSE_SERVER="unix:/tmp/pulse.sock" ./hl2_linux -game tf -sw -small -w 640 -h 200 -novid -noasync -nosteamcontroller -nojoy -noshaderapi -nomouse -nomessagebox -nominidumps -nohltv -nobreakpad -nosrgb -nostartupsound -noquicktime -no_texture_stream -nouserclip -mat_softwaretl -precachefontchars -limitvsconst -particles 512 -snoforceformat -softparticlesdefaultoff -threads 1 +mat_aaquality 0 +mat_antialias 0 >/dev/null 2>&1 &
    sleep 10 # Plenty of time for the TF2 process to be started
  fi

  # TF2 crashed, restart both Steam and TF2
  if [ "$(pidof hl2_linux | wc -w)" -eq 0 ]; then
    killall -q -s SIGKILL steam
    $steam_command -silent -vrdisable -nocrashmonitor -skipstreamingdrivers -login "$login" >/dev/null 2>&1 &
  fi

  # Give Steam some time to start
  sleep 30
done
