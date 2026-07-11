#!/usr/bin/env bash

set -euo pipefail

echo "========================================================"
echo " Gathering available VM profiles from Flake..."
echo "========================================================"

# 1. Ensure changes are staged so Nix can read them properly
git add -A 2>/dev/null || true

# 2. Extract host keys and exclude the 'NAME' blueprint
echo "--> Reading flake outputs..."
AVAILABLE_HOSTS=($(nix eval --experimental-features "nix-command flakes" .#nixosConfigurations --apply "builtins.attrNames" --json |
  jq -r '.[] | select(. != "NAME")'))

if [ ${#AVAILABLE_HOSTS[@]} -eq 0 ]; then
  echo "❌ Error: No deployable NixOS configurations found in this Flake."
  exit 1
fi

# 3. Interactive menu selection
echo ""
echo "Select the host configuration to deploy:"
select TARGET_HOST in "${AVAILABLE_HOSTS[@]}"; do
  if [ -n "${TARGET_HOST}" ]; then
    echo "--> Selected target: ${TARGET_HOST}"
    break
  else
    echo "Invalid selection. Please choose a number from the list."
  fi
done

echo "========================================================"
echo " Formatting and Installing: ${TARGET_HOST}"
echo "========================================================"

# 1. Partition and mount /dev/sda to /mnt
echo "--> Running Disko partitioning..."
sudo nix run 'github:nix-community/disko/latest#disko' -- --mode disko --flake ".#${TARGET_HOST}"

# 2. Copy your configuration repository into the target so it's preserved after boot
echo "--> Syncing configuration files to /mnt/etc/nixos..."
sudo mkdir -p /mnt/etc/nixos
sudo cp -r . /mnt/etc/nixos

# 3. Use standard nixos-install (Builds directly on your hard drive)
echo "--> Building and installing NixOS profile..."
sudo nixos-install --flake "/mnt/etc/nixos#${TARGET_HOST}" --no-root-passwd

echo "========================================================"
echo " Setup complete for ${TARGET_HOST}! Ready to reboot. "
echo "========================================================"
