#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

# Function to run commands and check for errors
run_command() {
    local message="$1"
    shift # Shift arguments so $1 becomes the command and the rest are args
    
    echo -e "${GREEN}$message...${NC}"
    if ! "$@"; then
        echo -e "${RED}Error: '$message' failed.${NC}"
    fi
    echo # for a newline
}

run_command "Updating package list" apt update -y
run_command "Upgrading all installed packages" apt full-upgrade -y

# Update Flatpak packages if flatpak is installed
if command -v flatpak &> /dev/null; then
    run_command "Updating Flatpak packages" flatpak update -y
else
    echo -e "${GREEN}Flatpak not found, skipping.${NC}\n"
fi

# Update Snap packages if snap is installed
if command -v snap &> /dev/null; then
    run_command "Updating Snap packages" snap refresh
else
    echo -e "${GREEN}Snap not found, skipping.${NC}\n"
fi

run_command "Cleaning up system" apt autoremove --purge -y
run_command "Cleaning package cache" apt autoclean -y
run_command "Fixing any broken dependencies" apt install -f -y
run_command "Reconfiguring any packages that are not fully installed" dpkg --configure -a

# Update Pi-hole if pihole is installed
if command -v pihole &> /dev/null; then
    # Note: Pi-hole update usually requires root, so sudo is implicit here since we check for root at start
    run_command "Updating Pi-hole" env PIHOLE_SKIP_OS_CHECK=true pihole -up
    run_command "Updating Pi-hole's gravity list" pihole -g
else
    echo -e "${GREEN}Pi-hole not found, skipping.${NC}\n"
fi

echo -e "${GREEN}System update complete!${NC}"
