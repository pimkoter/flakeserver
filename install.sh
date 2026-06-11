#!/usr/bin/env bash

echo "Welcome to installer"
read -p "Type machine name:" machine_name

echo "Starting installation for machine $machine_name"

sudo nix --extra-experimental-features "nix-command flakes" \
  run 'github:nix-community/disko/latest#disko-install' -- \
  --flake .#$machine_name \
  --disk main /dev/sda
