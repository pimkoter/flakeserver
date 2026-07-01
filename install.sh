#!/usr/bin/env bash
set -e

echo "=== NixOS Installer ==="
read -p "Type machine name: " machine_name

if [[ -z "$machine_name" ]]; then
    echo "Error: Machine name cannot be empty."
    exit 1
fi

echo "Starting installation for machine $machine_name"

sudo nix run github:nix-community/disko -- ---mode disko --flake .#{machine_name}

echo "System install successful!"

for i in {10..1}; do
  echo "System restarts in $i seconds..."
  sleep 1
done

echo "Rebooting now..."
sudo reboot
