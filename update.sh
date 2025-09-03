#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Please use sudo." >&2
  exit 1
fi

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to run commands and check for errors
run_command() {
    echo -e "${GREEN}$1...${NC}"
    if ! eval "$2"; then
        echo -e "${RED}Error: '$1' failed.${NC}"
    fi
    echo # for a newline
}

run_command "Updating package list" "apt update -y"
run_command "Upgrading all installed packages" "apt upgrade -y"

# Update Flatpak packages if flatpak is installed
if command -v flatpak &> /dev/null; then
    run_command "Updating Flatpak packages" "flatpak update -y"
else
    echo -e "${GREEN}Flatpak not found, skipping.${NC}\n"
fi

run_command "Cleaning up system" "apt autoremove --purge -y && apt autoclean -y"
run_command "Fixing any broken dependencies" "apt install -f -y"
run_command "Reconfiguring any packages that are not fully installed" "dpkg --configure -a"

# Update Pi-hole if pihole is installed
if command -v pihole &> /dev/null; then
    run_command "Updating Pi-hole" "PIHOLE_SKIP_OS_CHECK=true pihole -up"
    run_command "Updating Pi-hole's gravity list" "pihole -g"
else
    echo -e "${GREEN}Pi-hole not found, skipping.${NC}\n"
fi

echo -e "${GREEN}System update complete!${NC}"
