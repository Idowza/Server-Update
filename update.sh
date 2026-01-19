#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}Please do not run as root${NC}"
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

run_command "Updating package list" sudo apt update -y
run_command "Upgrading all installed packages" sudo apt full-upgrade -y

# Update Flatpak packages if flatpak is installed
if command -v flatpak &> /dev/null; then
    run_command "Updating Flatpak packages" sudo flatpak update -y
else
    echo -e "${GREEN}Flatpak not found, skipping.${NC}\n"
fi

# Update Snap packages if snap is installed
if command -v snap &> /dev/null; then
    run_command "Updating Snap packages" sudo snap refresh
else
    echo -e "${GREEN}Snap not found, skipping.${NC}\n"
fi

run_command "Cleaning up system" sudo apt autoremove --purge -y
run_command "Cleaning package cache" sudo apt autoclean -y
run_command "Fixing any broken dependencies" sudo apt install -f -y
run_command "Reconfiguring any packages that are not fully installed" sudo dpkg --configure -a

# Update Pi-hole if pihole is installed
if command -v pihole &> /dev/null; then
    # Note: Pi-hole update usually requires root
    run_command "Updating Pi-hole" sudo env PIHOLE_SKIP_OS_CHECK=true pihole -up
    run_command "Updating Pi-hole's gravity list" sudo pihole -g
else
    echo -e "${GREEN}Pi-hole not found, skipping.${NC}\n"
fi

echo -e "${GREEN}System update complete!${NC}"
