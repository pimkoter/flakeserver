#!/usr/bin/env bash
set -euo pipefail

# 1. Fetch the mount point dynamically from Nix config to know where configurations live
echo "🔍 Resolving media base directory..."
BASE_DIR=$(nixos-option disks.mntPoint | grep -o '".*"' | sed 's/"//g')

if [ -z "$BASE_DIR" ]; then
  echo "❌ Could not find config.disks.mntPoint dynamic value. Ensure your configuration is active."
  exit 1
fi

echo "📁 Found media base path at: $BASE_DIR"

# 2. Ensure custom Docker network exists
echo "🌐 Creating internal Docker bridge network..."
docker network create jellystack 2>/dev/null || true

# 3. Create secrets folder
sudo mkdir -p /etc/jellystack

# 4. Trigger systemd-tmpfiles to create app data folders so configurations can generate
echo "⚙️  Initializing folder structures..."
sudo systemd-tmpfiles --create

# 5. Build and apply NixOS configuration once to pull docker images & launch containers
echo "🚀 Performing initial NixOS build to spin up containers..."
sudo nixos-rebuild switch

echo "⏳ Waiting for Arr services to initialize configurations and generate API keys..."
sleep 15

# 6. Function to safely extract API keys from container XML configuration files
get_api_key() {
  local file="$1"
  if [ -f "$file" ]; then
    # Parse XML <ApiKey> value cleanly
    grep -oP '(?<=<ApiKey>)[^<]+' "$file" || echo ""
  else
    echo ""
  fi
}

PROWLARR_CONFIG="$BASE_DIR/config/prowlarr/config.xml"
RADARR_CONFIG="$BASE_DIR/config/radarr/config.xml"
SONARR_CONFIG="$BASE_DIR/config/sonarr/config.xml"

# Wait loop until all keys are ready
while true; do
  PROWLARR_KEY=$(get_api_key "$PROWLARR_CONFIG")
  RADARR_KEY=$(get_api_key "$RADARR_CONFIG")
  SONARR_KEY=$(get_api_key "$SONARR_CONFIG")

  if [ -n "$PROWLARR_KEY" ] && [ -n "$RADARR_KEY" ] && [ -n "$SONARR_KEY" ]; then
    echo "✅ All API keys successfully intercepted!"
    break
  fi
  echo "Waiting for app configs to populate... (Checking again in 5s)"
  sleep 5
done

# 7. Write keys out to the untracked secrets file Nix reads from
echo "🔐 Writing API keys securely to /etc/jellystack/secrets.nix..."
sudo tee /etc/jellystack/secrets.nix >/dev/null <<EOF
{
  prowlarrKey = "$PROWLARR_KEY";
  radarrKey = "$RADARR_KEY";
  sonarrKey = "$SONARR_KEY";
}
EOF

# 8. Re-run switch so Declarr picks up the freshly populated keys and hooks the stack together
echo "🔄 Re-running NixOS rebuild to finalize Declarr configurations..."
sudo nixos-rebuild switch

echo "🎉 Stack is fully online and inter-connected! Access Seerr at http://<VM-IP>:5055"
