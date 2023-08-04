#!/bin/bash
# Written by Bintr on 03.08.2023
# Purpose: Deletes the source engine lock created when an instance of TF2 is launched.

while :; do
  if [ -f /tmp/source_engine_2925226592.lock ]; then
    rm /tmp/source_engine_2925226592.lock
  fi
  sleep 0.2
done
