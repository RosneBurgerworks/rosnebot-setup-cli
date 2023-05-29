#!/usr/bin/env bash
# Written by Bintr on 13.05.2023
# Purpose: Replace steamapps folder with our default one

# Resolve parent path
parent_path=$(dirname .local/share/Steam/steamapps/)

# Rename the directory
mv "$parent_path"/steamapps "$parent_path"/steamapps_old

# Create a symbolic link
ln -s /opt/steamapps/ "$parent_path"/steamapps
