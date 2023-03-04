#!/usr/bin/env bash
# Written by Bintr on 28.01.2023
# Purpose: Restarts Steam and TF2 in case they crash.

login=$1
steam_command=$2

# Give Steam time to start
sleep 5

while :; do
  # Check if Steam is started and start TF2
  if [ "$(pidof "$steam_command" | wc -w)" -eq 2 ]; then
    bash -c 'cd ~/.local/share/Steam/steamapps/common/Team\ Fortress\ 2 && LD_LIBRARY_PATH="$LD_LIBRARY_PATH:./bin" LD_PRELOAD="/opt/novisual.so:~/Desktop/catbot-setup-cli/just-disable-vac/build/bin64/libvpcfs.so.0:~/Desktop/catbot-setup-cli/just-disable-vac/build/bin32/libvpcfs.so.0" PULSE_SERVER="unix:/tmp/pulse.sock" ./hl2_linux -game tf -sw -small -w 640 -h 200 -novid -noasync -nosteamcontroller -nojoy -noshaderapi -nomouse -nomessagebox -nominidumps -nohltv -nobreakpad -nosrgb -nostartupsound -noquicktime -no_texture_stream -nouserclip -mat_softwaretl -precachefontchars -limitvsconst -particles 512 -snoforceformat -softparticlesdefaultoff -threads 1 +mat_aaquality 0 +mat_antialias 0'
    sleep 10 # Plenty of time for the process to be started
  fi

  # TF2 crashed, restart both Steam and TF2
  if [ "$(pidof hl2_linux | wc -w)" -eq 0 ]; then
    killall -q -s SIGKILL "$steam_command"
    while [ "$(pidof "$steam_command" | wc -w)" -gt 0 ]; do
      sleep 2
    done

    $steam_command -silent -noreactlogin -login "$login" -nominidumps -no-browser -vrdisable -nocrashmonitor -noshaders
  fi

  sleep 5
done
