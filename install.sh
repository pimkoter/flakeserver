#!/usr/bin/env bash

echo "Welcome to installer"
read -p "Type machine name:" machine_name

if [-z "$machine_name" ]; then
  echo "ERROR: Machine name can't be empty" 
  exit 1
fi 

echo "Starting installation for machine $machine_name"

sudo nix --extra-expirimental-featurs "nix-command flakes" \
run github:nix-community/disko --mode disko ./flake.nix#$machine_name

sudo nixos-install --flake .#$machine_name --root /mnt

