#!/usr/bin/env bash
# Written by Bintr on 14.11.2022
# Purpose: Clone all necessary repositories.

set -e

if [ $EUID -eq 0 ]; then
  echo "This script must not be run as root!"
  exit
fi

if [ ! -d /opt/cathook ]; then
  echo "Please install Cathook on your main TF2 first."
  echo "https://github.com/explowz/cathook"
  exit
fi

# Idiot-proof this shit
if [ ! -d .git ] || [ ! -x "$(command -v git)" ]; then
  echo "You must clone the repository instead of downloading it."
  exit
fi

if [ ! -x "$(command -v route)" ] && [ ! -x /sbin/route ]; then
  echo "Route doesn't exist. Please install it. (net-tools)"
  exit
fi

if [ ! -x "$(command -v firejail)" ]; then
  echo "Firejail doesn't exist. Please install it. (firejail)"
  exit
fi

if [ ! -x "$(command -v Xvfb)" ]; then
  echo "Xvfb doesn't exist. Please install it. (xorg-server-xvfb)"
fi

if [ ! -x "$(command -v killall)" ]; then
  echo "Killall doesn't exist. Please install it. (psmisc)"
fi

if [ ! -d cathook ]; then
  git clone --recursive https://github.com/explowz/cathook.git
fi

if [ -d ~/.steam/steam/steamapps/common/Team\ Fortress\ 2/tf/maps ]; then
  if [ -d catbot-database ]; then
    echo "Fetching navmeshes..."
    pushd catbot-database
    git fetch --depth 1
    git reset --hard origin/master
    popd
  else
    git clone --depth 1 https://github.com/explowz/catbot-database.git
  fi

  echo "Copying navmeshes..."
  rsync catbot-database/nav\ meshes/*.nav ~/.steam/steam/steamapps/common/Team\ Fortress\ 2/tf/maps/
  chmod 755 ~/.steam/steam/steamapps/common/Team\ Fortress\ 2/tf/maps/*.nav # fix permissions, so tf2 is happy
fi

if [ ! -f /home/novisual.so ]; then
  mkdir -p build && pushd build
  cmake -DCMAKE_BUILD_TYPE=Release -DVisuals_DrawType="Textmode" -DVACBypass=1 -DEnableLogging=0 ../cathook/
  make -j"$(nproc --all)"
  if [ ! -f bin/libcathook.so ]; then
    echo "FATAL: Build failed"
    exit
  fi
  popd
  sudo mkdir -p "/opt/cathook/data/configs"
  sudo cp "build/bin/libcathook.so" "/opt/novisual.so"
  sudo chmod -R 0755 /opt/cathook/data/configs/
fi

if [ ! -d just-disable-vac ]; then
  git clone https://gitlab.com/nullworks/cathook/just-disable-vac.git
  pushd just-disable-vac
  mkdir -p build && pushd build
  cmake .. && make
  popd
  popd
fi

if [ ! -d cathook-ipc-server ]; then
  git clone --recursive https://github.com/nullworks/cathook-ipc-server.git
  pushd cathook-ipc-server
  ./install.sh
  popd
fi

if [ ! -d nullnexus-proxy ]; then
  sudo npm install pm2 -g
  git clone --recursive https://gitlab.com/nullworks/cathook/nullnexus-proxy.git
  pushd nullnexus-proxy
  ./update.sh
  popd
fi

sudo sed -i 's/^restricted-network yes/# restricted-network yes/g' /etc/firejail/firejail.config

echo "Installation finished."
