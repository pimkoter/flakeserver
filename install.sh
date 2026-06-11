#!/usr/bin/env bash
set -e

echo "=== NixOS Installer ==="
read -p "Type machine name: " machine_name

if [[ -z "$machine_name" ]]; then
    echo "Error: Machine name cannot be empty."
    exit 1
fi

echo "Starting installation for machine $machine_name"

# Installatie commando
sudo nix --extra-experimental-features "nix-command flakes" \
  run 'github:nix-community/disko/latest#disko-install' -- \
  --flake ".#$machine_name" \
  --disk main /dev/sda

echo "System install successful!"

# Aftellen van 10 naar 1
for i in {10..1}; do
  echo "System restarts in $i seconds..."
  sleep 1
done

echo "Rebooting now..."
sudo reboot
