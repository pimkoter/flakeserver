#!/usr/bin/env bash
set -e

echo "Welcome to the installer"
read -p "Type machine name: " machine_name

if [[ -z "$machine_name" ]]; then
    echo "Error: Machine name cannot be empty."
    exit 1
fi

echo "Starting installation for machine $machine_name"

sudo nix --extra-experimental-features "nix-command flakes" \
  run 'github:nix-community/disko/latest#disko-install' -- \
  --flake ".#$machine_name" \
  --disk main /dev/sda
