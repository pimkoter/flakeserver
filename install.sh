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
echo " Running disko-install for: ${TARGET_HOST}"
echo "========================================================"

# 1. Manually trigger the partition/mount phase first so /mnt exists
echo "--> Partitioning disk..."
sudo nix run 'github:nix-community/disko/latest#disko' -- --mode disko --flake ".#${TARGET_HOST}"

# 2. Create a temporary folder on the physical disk
sudo mkdir -p /mnt/tmp

# 3. Force Nix to use the physical disk for its build cache
echo "--> Building and installing NixOS profile..."
sudo TMPDIR=/mnt/tmp nix run 'github:nix-community/disko/latest#disko-install' -- \
  --flake ".#${TARGET_HOST}" \
  --disk sda /dev/sda \
  --write-efi-boot-entries

echo "========================================================"
echo " Setup complete for ${TARGET_HOST}! Ready to reboot. "
echo "========================================================"
