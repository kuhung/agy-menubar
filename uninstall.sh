#!/usr/bin/env bash
# ==============================================================================
# agy-menubar Uninstaller
# https://github.com/kuhung/agy-menubar
# ==============================================================================

set -euo pipefail

BOLD="\033[1m"
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${BOLD}Uninstalling agy-menubar...${RESET}"

PLIST_FILE="${HOME}/Library/LaunchAgents/com.kuhung.agy-menubar.plist"
TARGET_BIN="${HOME}/.local/bin/agy-menubar"

# Stop and remove LaunchAgent
if [[ -f "${PLIST_FILE}" ]]; then
    echo "Stopping launchd service..."
    launchctl unload "${PLIST_FILE}" 2>/dev/null || true
    rm -f "${PLIST_FILE}"
    echo "Removed LaunchAgent plist."
fi

# Kill running processes
pkill -f "agy-menubar" 2>/dev/null || true

# Remove binary
if [[ -f "${TARGET_BIN}" ]]; then
    rm -f "${TARGET_BIN}"
    echo "Removed binary ${TARGET_BIN}."
fi

echo -e "\n${GREEN}${BOLD}✓ agy-menubar has been completely uninstalled.${RESET}\n"
