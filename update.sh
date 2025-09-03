#!/bin/bash

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

run_command "Updating package list" "sudo apt update -y"
run_command "Upgrading all installed packages" "sudo apt upgrade -y"

# Update Flatpak packages if flatpak is installed
if command -v flatpak &> /dev/null; then
    run_command "Updating Flatpak packages" "sudo flatpak update -y"
else
    echo -e "${GREEN}Flatpak not found, skipping.${NC}\n"
fi

run_command "Cleaning up system" "sudo apt autoremove --purge -y && sudo apt autoclean -y"
run_command "Fixing any broken dependencies" "sudo apt install -f -y"
run_command "Reconfiguring any packages that are not fully installed" "sudo dpkg --configure -a"

# Update Pi-hole if pihole is installed
if command -v pihole &> /dev/null; then
    run_command "Updating Pi-hole" "sudo PIHOLE_SKIP_OS_CHECK=true pihole -up"
    run_command "Updating Pi-hole's gravity list" "sudo pihole -g"
else
    echo -e "${GREEN}Pi-hole not found, skipping.${NC}\n"
fi

echo -e "${GREEN}System update complete!${NC}"
