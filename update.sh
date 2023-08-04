#!/bin/bash

OLD_UPDATE=$(git rev-parse HEAD:update)
git pull --ff
NEW_UPDATE=$(git rev-parse HEAD:update)

if [ "$OLD_UPDATE" != "$NEW_UPDATE" ]; then
  echo Update script self update!
  exec "$0" "$@"
fi

pushd cathook || exit
git pull --ff
git submodule update --init --recursive
popd || exit

mkdir -p build
pushd build || exit
cmake -DCMAKE_BUILD_TYPE=Release -DVisuals_DrawType="Textmode" -DVACBypass=1 -DEnableLogging=0 ../cathook/
make -j"$(nproc --all)"
if [ ! -f bin/libcathook.so ]; then
  echo "FATAL: Build failed"
  exit
fi
popd || exit
sudo cp build/bin/libcathook.so /opt/novisual.so

pushd just-disable-vac || exit
git pull -ff
mkdir -p build && pushd build || exit
cmake .. && make
sudo cp -r bin32 /opt/
sudo cp -r bin64 /opt/
popd || exit
popd || exit

pushd cathook-ipc-server || exit
git remote set-url origin https://github.com/nullworks/cathook-ipc-server.git
bash update.sh
popd || exit

pushd nullnexus-proxy || exit
git remote set-url origin https://gitlab.com/nullworks/cathook/nullnexus-proxy.git
bash update.sh
popd || exit

echo "Fetching navmeshes..."
if [ -d catbot-database ]; then
  pushd catbot-database || exit
  git fetch --depth 1
  git reset --hard origin/master
  popd || exit
else
  git clone --depth 1 https://github.com/explowz/catbot-database.git
fi

echo "Copying navmeshes..."
rsync catbot-database/nav\ meshes/*.nav ~/.steam/steam/steamapps/common/Team\ Fortress\ 2/tf/maps/
chmod 755 ~/.steam/steam/steamapps/common/Team\ Fortress\ 2/tf/maps/*.nav # fix permissions so tf2 is happy

echo "Done"
