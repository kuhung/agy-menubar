#!/usr/bin/env bash
# ==============================================================================
# agy-menubar Installer
# https://github.com/kuhung/agy-menubar
# ==============================================================================

set -euo pipefail

BOLD="\033[1m"
GREEN="\033[32m"
CYAN="\033[36m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${CYAN}${BOLD}"
echo "   ___   _______  __      __  ___                  ___             "
echo "  / _ | / ___/\ \/ /____ /  |/  /__ ___  __ __ ___/ _ )___ _____ "
echo " / __ |/ (_ /  \  //___// /|_/ / -_) _ \/ // // _  _  / _ \`/ __/ "
echo "/_/ |_|\___/   /_/     /_/  /_/\__/_//_/\_,_/ \_,____/\_,_/_/    "
echo -e "${RESET}"
echo -e "${BOLD}Installing agy-menubar (macOS Context Monitor for Antigravity)...${RESET}\n"

# 1. OS check
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo -e "${RED}Error: agy-menubar only supports macOS.${RESET}"
    exit 1
fi

# 2. Python check
if ! command -v python3 >/dev/null 2>&1; then
    echo -e "${RED}Error: python3 is not installed or not in PATH.${RESET}"
    exit 1
fi

PYTHON_BIN="$(command -v python3)"

# 3. PyObjC / AppKit check
echo -e "Checking Python AppKit bindings (${PYTHON_BIN})..."
if ! "${PYTHON_BIN}" -c "import AppKit" >/dev/null 2>&1; then
    echo -e "${YELLOW}PyObjC AppKit is not installed. Installing pyobjc-framework-Cocoa...${RESET}"
    "${PYTHON_BIN}" -m pip install --quiet pyobjc-framework-Cocoa
fi
echo -e "${GREEN}✓ Python & AppKit dependencies verified.${RESET}"

# 4. Target directories
INSTALL_DIR="${HOME}/.local/bin"
PLIST_DIR="${HOME}/Library/LaunchAgents"
PLIST_FILE="${PLIST_DIR}/com.kuhung.agy-menubar.plist"
TARGET_BIN="${INSTALL_DIR}/agy-menubar"

mkdir -p "${INSTALL_DIR}"
mkdir -p "${PLIST_DIR}"

# 5. Binary installation (from local git repo or remote download)
SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
fi

if [[ -n "${SCRIPT_DIR}" && -f "${SCRIPT_DIR}/bin/agy-menubar" ]]; then
    echo -e "Installing binary from local repository..."
    cp "${SCRIPT_DIR}/bin/agy-menubar" "${TARGET_BIN}"
else
    echo -e "Downloading binary from GitHub..."
    curl -fsSL "https://raw.githubusercontent.com/kuhung/agy-menubar/main/bin/agy-menubar" -o "${TARGET_BIN}"
fi

chmod +x "${TARGET_BIN}"
echo -e "${GREEN}✓ Binary installed to ${TARGET_BIN}${RESET}"

# 6. Configure LaunchAgent for autostart
echo -e "Configuring background LaunchAgent daemon..."

# Unload previous service if running (only match python processes, never the installer script itself)
launchctl unload "${PLIST_FILE}" >/dev/null 2>&1 || true
pkill -f "[p]ython.*agy-menubar" >/dev/null 2>&1 || true

if [[ -n "${SCRIPT_DIR}" && -f "${SCRIPT_DIR}/launchd/com.kuhung.agy-menubar.plist" ]]; then
    sed -e "s|__PYTHON_BIN__|${PYTHON_BIN}|g" \
        -e "s|__BIN_PATH__|${TARGET_BIN}|g" \
        "${SCRIPT_DIR}/launchd/com.kuhung.agy-menubar.plist" > "${PLIST_FILE}"
else
    cat <<EOF > "${PLIST_FILE}"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.kuhung.agy-menubar</string>
    <key>ProgramArguments</key>
    <array>
        <string>${PYTHON_BIN}</string>
        <string>${TARGET_BIN}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/agy-menubar.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/agy-menubar.log</string>
</dict>
</plist>
EOF
fi

# Load and start daemon
launchctl load "${PLIST_FILE}"
echo -e "${GREEN}✓ LaunchAgent configured and service started.${RESET}"

# 7. Check PATH
if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
    echo -e "\n${YELLOW}Notice: ${INSTALL_DIR} is not in your current PATH.${RESET}"
    echo -e "Add this line to your ~/.zshrc or ~/.bash_profile:"
    echo -e "  export PATH=\"${INSTALL_DIR}:\$PATH\""
fi

echo -e "\n${GREEN}${BOLD}🎉 agy-menubar installed and running successfully!${RESET}"
echo -e "Look at your top macOS menu bar — you should see the dynamic ring icon."
echo -e "To uninstall anytime, simply run: ${CYAN}uninstall.sh${RESET}\n"
