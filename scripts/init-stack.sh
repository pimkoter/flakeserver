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

# 2. Create secrets folder
sudo mkdir -p /etc/jellystack

# 3. Trigger systemd-tmpfiles to create app data folders so configurations can generate
echo "⚙️  Initializing folder structures..."
sudo systemd-tmpfiles --create

# 4. Build and apply NixOS configuration once to pull docker images & launch containers
# Note: Declarr might fail on this first run because secrets.nix is missing/placeholder
echo "🚀 Performing initial NixOS build to spin up containers..."
sudo nixos-rebuild switch || echo "⚠️  First rebuild had errors (likely Declarr placeholders), continuing to key extraction..."

echo "⏳ Waiting for services to initialize configurations and generate API keys..."
sleep 15

# 5. Functions to safely extract API keys from various formats
get_xml_key() {
  local file="$1"
  [ -f "$file" ] && grep -oP '(?<=<ApiKey>)[^<]+' "$file" || echo ""
}

get_json_key() {
  local file="$1"
  [ -f "$file" ] && grep -oP '(?<="apiKey": ")[^"]+' "$file" || echo ""
}

get_yaml_key() {
  local file="$1"
  [ -f "$file" ] && grep -oP '(?<=apikey: )[^ ]+' "$file" || echo ""
}

PROWLARR_CONFIG="$BASE_DIR/config/prowlarr/config.xml"
RADARR_CONFIG="$BASE_DIR/config/radarr/config.xml"
SONARR_CONFIG="$BASE_DIR/config/sonarr/config.xml"
LIDARR_CONFIG="$BASE_DIR/config/lidarr/config.xml"
SEERR_CONFIG="$BASE_DIR/config/seerr/settings.json"
BAZARR_CONFIG="$BASE_DIR/config/bazarr/config.yaml"

# Wait loop until all keys are ready
while true; do
  PROWLARR_KEY=$(get_xml_key "$PROWLARR_CONFIG")
  RADARR_KEY=$(get_xml_key "$RADARR_CONFIG")
  SONARR_KEY=$(get_xml_key "$SONARR_CONFIG")
  LIDARR_KEY=$(get_xml_key "$LIDARR_CONFIG")
  SEERR_KEY=$(get_json_key "$SEERR_CONFIG")
  BAZARR_KEY=$(get_yaml_key "$BAZARR_CONFIG")

  if [ -n "$PROWLARR_KEY" ] && [ -n "$RADARR_KEY" ] && [ -n "$SONARR_KEY" ] && \
     [ -n "$LIDARR_KEY" ] && [ -n "$SEERR_KEY" ] && [ -n "$BAZARR_KEY" ]; then
    echo "✅ All API keys successfully intercepted!"
    break
  fi
  echo "Waiting for app configs to populate... (Checking again in 5s)"
  sleep 5
done

# 6. Write keys out to the untracked secrets file Nix reads from
echo "🔐 Writing API keys securely to /etc/jellystack/secrets.nix..."
sudo tee /etc/jellystack/secrets.nix >/dev/null <<EOF
{
  prowlarrKey = "$PROWLARR_KEY";
  radarrKey = "$RADARR_KEY";
  sonarrKey = "$SONARR_KEY";
  lidarrKey = "$LIDARR_KEY";
  seerrKey = "$SEERR_KEY";
  bazarrKey = "$BAZARR_KEY";
}
EOF

# 7. Re-run switch so Declarr picks up the freshly populated keys and hooks the stack together
echo "🔄 Re-running NixOS rebuild to finalize Declarr configurations..."
sudo nixos-rebuild switch

echo "🎉 Stack is fully online and inter-connected!"
