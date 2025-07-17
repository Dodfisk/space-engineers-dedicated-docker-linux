#!/bin/bash

set -euo pipefail

CONFIG_DIR="/appdata/space-engineers"
WORLD_DIR="$CONFIG_DIR/World"
CFG_FILE="$CONFIG_DIR/SpaceEngineersDedicated/SpaceEngineers-Dedicated.cfg"

# Check required world and config files
if [ ! -d "$WORLD_DIR" ]; then
  echo "[ERROR] World folder does not exist: $WORLD_DIR"
  exit 129
fi

if [ ! -f "$WORLD_DIR/Sandbox.sbc" ]; then
  echo "[ERROR] Sandbox.sbc file not found in world directory"
  exit 130
fi

if [ ! -f "$CFG_FILE" ]; then
  echo "[ERROR] SpaceEngineers-Dedicated.cfg is missing"
  exit 131
fi

# Normalize <LoadWorld> path
sed -i -E \
  's|<LoadWorld>.*</LoadWorld>|<LoadWorld>Z:\\appdata\\space-engineers\\World</LoadWorld>|g' \
  "$CFG_FILE"

# Optional: Set static game port
# sed -i -E 's|<ServerPort>.*</ServerPort>|<ServerPort>27016</ServerPort>|g' "$CFG_FILE"

# Plugins injection
PLUGIN_DIR="$CONFIG_DIR/Plugins"
PLUGIN_TAGS=""

if compgen -G "$PLUGIN_DIR/*.dll" > /dev/null; then
  PLUGIN_TAGS=$(find "$PLUGIN_DIR" -name '*.dll' | \
    awk '{ printf "<string>%s</string>", $0 }' | \
    awk '{ print "<Plugins>" $0 "</Plugins>" }')
else
  PLUGIN_TAGS="<Plugins />"
fi

# Escape slashes for sed
PLUGIN_TAGS_ESCAPED="${PLUGIN_TAGS//\//\\/}"

# Replace <Plugins> tag whether empty or populated
sed -i -E "s|<Plugins\s*/>|$PLUGIN_TAGS_ESCAPED|g" "$CFG_FILE"
sed -i -E "s|<Plugins>.*</Plugins>|$PLUGIN_TAGS_ESCAPED|g" "$CFG_FILE"

# SteamCMD update using Windows version
echo "[INFO] Running Windows SteamCMD update..."
runuser -l wine -c 'steamcmd +login anonymous +@sSteamCmdForcePlatformType windows +force_install_dir /appdata/space-engineers/SpaceEngineersDedicated +app_update 298740 +quit'

# Start server
echo "[INFO] Starting Space Engineers Dedicated Server..."
runuser -l wine -c '/entrypoint-space_engineers.bash'
