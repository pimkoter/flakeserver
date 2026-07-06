#!/usr/bin/env bash
set -euo pipefail

DISK_DEV="/dev/nvme0n1" # The drive to wipe and install to
TARGET_HOST="${1:-}"

# Detect if we are inside the local git repository, otherwise fallback to GitHub
if [ -d "./.git" ] || [ -d "../.git" ]; then
  echo "Local git repository detected. Evaluating local files..."
  FLAKE_REPO="."
else
  FLAKE_REPO="github:pimkoter/flakeserver"
fi

# If no hostname was passed as an argument, fetch them from the flake and ask
if [ -z "$TARGET_HOST" ]; then
  echo "Fetching available host configurations from $FLAKE_REPO..."
  
  # Added --refresh to bypass aggressive Nix flake caching
  MAPFILE=()
  while IFS= read -r line; do
    if [ -n "$line" ]; then
      MAPFILE+=("$line")
    fi
  done < <(nix eval --extra-experimental-features "nix-command flakes" --refresh --raw "${FLAKE_REPO}#nixosConfigurations" --apply "attrs: builtins.concatStringsSep \"\n\" (builtins.attrNames attrs)" 2>/dev/null)

  if [ ${#MAPFILE[@]} -eq 0 ]; then
    echo "Error: No nixosConfigurations found in $FLAKE_REPO."
    echo "Tip: If testing locally, make sure your files are staged in git: git add ."
    exit 1
  fi

  echo ""
  echo "Please select a host configuration to install:"
  select host in "${MAPFILE[@]}"; do
    if [ -n "$host" ]; then
      TARGET_HOST="$host"
      break
    else
      echo "Invalid selection. Please try again."
    fi
  done
fi

echo ""
echo "===================================================="
echo " Target Host: $TARGET_HOST"
echo " Target Disk: $DISK_DEV (ALL DATA WILL BE WIPED)"
echo "===================================================="
read -p "Proceed with installation? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Installation aborted."
  exit 0
fi

echo "=== 1. Partitioning and formatting $DISK_DEV ==="
nix run github:nix-community/disko -- --mode disko --flake "${FLAKE_REPO}#${TARGET_HOST}"

echo "=== 2. Creating the pristine blank snapshot ==="
mkdir -p /tmp/btrfs_base
mount /dev/disk/by-partlabel/disk-main-root /tmp/btrfs_base
btrfs subvolume snapshot /tmp/btrfs_base/@root /tmp/btrfs_base/@root-blank
umount /tmp/btrfs_base

echo "=== 3. Launching installation for host: $TARGET_HOST ==="
nixos-install --flake "${FLAKE_REPO}#${TARGET_HOST}" --no-root-passwd

echo "=== Automation Complete for $TARGET_HOST! You can now run: reboot ==="
