#!/bin/bash

# Set wine environment
export WINEARCH=win64
export WINEDEBUG=-all
export WINEPREFIX=/wineprefix

# Optional: Initialize Wine prefix on first run
if [ ! -f "$WINEPREFIX/system.reg" ]; then
  echo "[INFO] Initializing Wine prefix at $WINEPREFIX..."
  wineboot -i
fi

# Ensure working directory exists
SERVER_DIR="/appdata/space-engineers/bins/SpaceEngineersDedicated/DedicatedServer64"
cd "$SERVER_DIR" || {
  echo "[ERROR] Server directory not found: $SERVER_DIR"
  exit 1
}

# Optionally download mods using Windows steamcmd.exe
# if [ -f /home/se/win-steamcmd/steamcmd.exe ]; then
#   echo "[INFO] Running Windows SteamCMD for mods..."
#   wine /home/se/win-steamcmd/steamcmd.exe +login anonymous +workshop_download_item 244850 <mod_id> +quit
# fi

# Launch Space Engineers Dedicated Server
echo "[INFO] Starting Space Engineers Dedicated Server..."
wine SpaceEngineersDedicated.exe \
  -noconsole \
  -path Z:\\appdata\\space-engineers\\bins\\SpaceEngineersDedicated \
  -ignorelastsession
