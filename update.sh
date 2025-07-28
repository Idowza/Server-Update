#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Colors
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Update the package list
echo -e "${GREEN}Updating package list...${NC}"
sudo apt update -y

# Upgrade all installed packages
echo -e "${GREEN}Upgrading all installed packages...${NC}"
sudo apt upgrade -y

# Update Flatpak packages
echo -e "${GREEN}Updating Flatpak packages...${NC}"
sudo flatpak update -y

# Remove unnecessary packages and purge old configuration files
echo -e "${GREEN}Cleaning up system...${NC}"
sudo apt autoremove --purge -y
sudo apt autoclean -y

# Fix broken dependencies
echo -e "${GREEN}Fixing any broken dependencies...${NC}"
sudo apt install -f -y

# Reconfigure any packages that are not fully installed
echo -e "${GREEN}Reconfiguring any packages that are not fully installed...${NC}"
sudo dpkg --configure -a

# Update Pi-hole
echo -e "${GREEN}Updating Pi-hole...${NC}"
sudo PIHOLE_SKIP_OS_CHECK=true pihole -up

# Update Pi-hole's gravity list
echo -e "${GREEN}Updating Pi-hole's gravity list...${NC}"
sudo pihole -g

echo -e "${GREEN}System update complete!${NC}"
