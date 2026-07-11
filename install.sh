#!/usr/bin/env bash

set -euo pipefail

echo "========================================================"
echo " Gathering available VM profiles from Flake..."
echo "========================================================"

# 1. Ensure changes are staged so Nix can read them properly
git add -A 2>/dev/null || true

# 2. Dynamically extract the host keys and filter out the 'NAME' blueprint
echo "--> Reading flake outputs..."
AVAILABLE_HOSTS=($(nix eval --experimental-features "nix-command flakes" .#nixosConfigurations --apply "builtins.attrNames" --json |
  jq -r '.[] | select(. != "NAME")'))

# 3. Check if we found any valid target hosts
if [ ${#AVAILABLE_HOSTS[@]} -eq 0 ]; then
  echo "❌ Error: No deployable NixOS configurations found in this Flake (excluding blueprints)."
  exit 1
fi

# 4. Present an interactive menu to the user
echo ""
echo "Select the host configuration to deploy onto /dev/sda:"
select TARGET_HOST in "${AVAILABLE_HOSTS[@]}"; do
  if [ -n "${TARGET_HOST}" ]; then
    echo "--> Selected target: ${TARGET_HOST}"
    break
  else
    echo "Invalid selection. Please choose a number from the list."
  fi
done

echo "========================================================"
echo " Preparing installation for: ${TARGET_HOST}"
echo "========================================================"

# 5. Locate and run disko using your configuration layout
echo "--> Locating disko configuration file..."
# Find any file ending in disko.nix or matching a disko pattern
DISKO_PATH=$(find . -name "*disko.nix" -print -quit)

if [ -z "$DISKO_PATH" ]; then
  echo "❌ Error: Could not find a disko configuration file in this repository."
  exit 1
fi

echo "--> Found layout at: ${DISKO_PATH}"
echo "--> Partitioning and formatting /dev/sda with Disko..."
sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- \
  --mode disko "$DISKO_PATH"
# 6. Copy repository context to the target file system mount
echo "--> Syncing configuration files to /mnt..."
sudo mkdir -p /mnt/etc/nixos
sudo cp -r . /mnt/etc/nixos

# 7. Complete the final install hook passing the selected profile name
echo "--> Running nixos-install..."
sudo nixos-install --flake "/mnt/etc/nixos#${TARGET_HOST}" --no-root-passwd

echo "========================================================"
echo " Setup complete for ${TARGET_HOST}! Ready to reboot. "
echo "========================================================"
