#!/bin/bash
# Written by Bintr on 28.01.2023
# Purpose: Restarts Steam and TF2 in case they crash.

login=$1
steam_command=$2
bot_id=$3

was_updating=false

if [[ $steam_command == "steam-native" ]]; then
  library_path="$LD_LIBRARY_PATH:./bin"
else
  library_path="$(/home/"$USER"/.local/share/Steam/ubuntu12_32/steam-runtime/run.sh printenv LD_LIBRARY_PATH):./bin"
fi

sleep 10

while :; do
  if [[ $was_updating = false && "$(cat /tmp/b"$bot_id")" == *" Downloading update ("* ]]; then
    was_updating=true
    sleep 90
  else
    # Give Steam some time to start
    sleep 10
  fi

  # Check if Steam is started and start TF2
  if [[ "$(pidof steam | wc -w)" -eq 1 && "$(pidof hl2_linux | wc -w)" -eq 0 ]]; then
    cd /home/"$USER"/.local/share/Steam/steamapps/common/Team\ Fortress\ 2 && LD_LIBRARY_PATH=$library_path LD_PRELOAD="/opt/novisual.so:/opt/bin64/libvpcfs.so.0:/opt/bin32/libvpcfs.so.0" PULSE_SERVER="unix:/tmp/pulse.sock" ./hl2_linux -game tf -sw -small -w 640 -h 200 -novid -noasync -noassert -nosteamcontroller -nojoy -noshaderapi -nomouse -nocrashdialog -nomessagebox -nominidumps -nohltv -nobreakpad -nosrgb -nostartupsound -noquicktime -no_texture_stream -nouserclip -mat_softwaretl -precachefontchars -limitvsconst -particles 512 -snoforceformat -softparticlesdefaultoff -threads 1 +mat_aaquality 0 +mat_antialias 0 >/dev/null 2>&1 &
    sleep 10 # Plenty of time for the TF2 process to be started
  fi

  # TF2 crashed, restart both Steam and TF2
  if [ "$(pidof hl2_linux | wc -w)" -eq 0 ]; then
    killall -q steam

    count=0
    while "$(pidof steam | wc -w)" -gt 0; do
      sleep 2
      # Send SIGKILL if Steam is trying to close for more than 20 seconds
      if [[ count -eq 10 ]]; then
        killall -q -s SIGKILL steam
        break
      fi
      ((count++))
    done

    $steam_command -silent -vrdisable -nocrashmonitor -skipstreamingdrivers -cef-disable-d3d11 -cef-single-process -cef-disable-gpu -cef-disable-breakpad -login $login >/tmp/b"$bot_id" 2>&1 &
    was_updating=false
  fi
done
