#!/usr/bin/env bash

echo "Welcome to installer"
read -p "Type machine name:" machine_name

if [-z "$machine_name" ]; then
  echo "ERROR: Machine name can't be empty" 
  exit 1
fi 

echo "Starting installation for machine $machine_name"

sudo nix --extra-experimental-featurs "nix-command flakes" \
run 'github:nix-community/disko/latest#disko-install' -- \
--flake .#$machine_name \
--disk main /dev/sda
