#!/bin/bash

# Update the package list
sudo apt update -y
# Upgrade all installed packages
sudo apt upgrade -y
# Update Flatpak packages
sudo flatpak update -y
# Remove unnecessary packages
sudo apt autoremove -y
# Clean up the local repository
sudo apt autoclean -y
# Purge old configuration files
sudo apt autopurge -y
# Fix broken dependencies
sudo apt install -f -y
# Reconfigure any packages that are not fully installed
sudo dpkg --configure -a

# Update Pi-hole
sudo PIHOLE_SKIP_OS_CHECK=true pihole -up
# Update Pi-hole's gravity list
sudo pihole -g
