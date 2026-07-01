#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "          NixOS Flake Installer           "
echo "=========================================="

# 1. Prompt for machine name
read -p "Enter target machine name (e.g., beta): " machine_name

if [[ -z "$machine_name" ]]; then
    echo "❌ Error: Machine name cannot be empty."
    exit 1
fi

echo "🚀 Beginning deployment process for: $machine_name"

# 2. Reset mounts from any previous failed runs
echo "🔄 Cleaning up any existing mount points..."
sudo umount -R /mnt 2>/dev/null || true

# 3. Run Disko partitioning tool
echo "💾 Partitioning and formatting disk arrays via Disko..."
sudo nix run github:nix-community/disko -- --mode disko --flake .#"$machine_name"

# 4. Create the pristine Btrfs rollback snapshot required by preservation.nix
echo "📦 Initializing the pristine root snapshot template..."
mkdir -p /tmp/btrfs-root
# Mount the root of the Btrfs filesystem (subvolid=5) to a temporary directory
sudo mount -t btrfs -o subvol=/ /dev/disk/by-partlabel/disk-main-root /tmp/btrfs-root

# Create the blank snapshot tracking the clean root state Disko just deployed
sudo btrfs subvolume snapshot /tmp/btrfs-root/root /tmp/btrfs-root/root-blank

# Clean up temporary snapshot mount point
sudo umount /tmp/btrfs-root
rmdir /tmp/btrfs-root

# 5. Fix empty machine-id bug that crashes systemd-boot installation
echo "🆔 Pre-generating system machine-id to prevent bootloader errors..."
sudo mkdir -p /mnt/persistent/etc
dbus-uuidgen | sudo tee /mnt/persistent/etc/machine-id > /dev/null

sudo mkdir -p /mnt/etc
sudo cp /mnt/persistent/etc/machine-id /mnt/etc/machine-id

# 6. Redirect compilation cache space away from RAM onto the newly formatted drive
echo "📈 Diverting Nix temporary build path to physical storage..."
sudo mkdir -p /mnt/nix/tmp
export TMPDIR=/mnt/nix/tmp

# 7. Execute the final system setup profile closure
echo "⚙️  Running nixos-install..."
sudo nixos-install --flake .#"$machine_name"

echo "=========================================="
echo " 🎉 NixOS Installation Successful!       "
echo "=========================================="

# 8. Safe reboot countdown loop
for i in {10..1}; do
    echo "🔄 System restarts in $i seconds... (Ctrl+C to abort)"
    sleep 1
done

echo "👋 Rebooting into your new system now..."
sudo reboot
