#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Track any failed steps
FAILED_STEPS=()

# Check if running as root
if [[ "$EUID" -eq 0 ]]; then
    echo -e "${RED}Please do not run this script directly as root.${NC}" >&2
    exit 1
fi

# Prompt for sudo password upfront and keep the timestamp fresh
echo -e "${GREEN}Authenticating sudo privileges...${NC}"
if ! sudo -v; then
    echo -e "${RED}Error: Sudo authentication failed.${NC}" >&2
    exit 1
fi
echo

# Function to run commands and check for errors
run_command() {
    local message="$1"
    shift # Shift arguments so $1 becomes the command and the rest are args

    echo -e "${GREEN}${message}...${NC}"
    if ! "$@"; then
        echo -e "${RED}Error: '${message}' failed.${NC}" >&2
        FAILED_STEPS+=("$message")
        echo
        return 1
    fi
    echo
    return 0
}

# --- APT Updates & Maintenance ---
run_command "Updating APT package list" sudo apt update

if ! run_command "Upgrading all installed APT packages" sudo apt full-upgrade -y; then
    echo -e "${YELLOW}Upgrade encountered an issue. Attempting to repair dpkg/APT state...${NC}"
    run_command "Reconfiguring unpacked packages" sudo dpkg --configure -a
    run_command "Fixing broken dependencies" sudo apt install -f -y
fi

run_command "Removing unused packages" sudo apt autoremove --purge -y
run_command "Cleaning APT package cache" sudo apt autoclean -y

# --- Flatpak Updates ---
if command -v flatpak &> /dev/null; then
    run_command "Updating system Flatpak packages" sudo flatpak update --system -y
    run_command "Updating user Flatpak packages" flatpak update --user -y
    run_command "Removing unused system Flatpak runtimes" sudo flatpak uninstall --system --unused -y
    run_command "Removing unused user Flatpak runtimes" flatpak uninstall --user --unused -y
else
    echo -e "${YELLOW}Flatpak not found, skipping.${NC}\n"
fi

# --- Snap Updates ---
if command -v snap &> /dev/null; then
    run_command "Updating Snap packages" sudo snap refresh
else
    echo -e "${YELLOW}Snap not found, skipping.${NC}\n"
fi

# --- Pi-hole Updates ---
if command -v pihole &> /dev/null; then
    run_command "Updating Pi-hole" sudo env PIHOLE_SKIP_OS_CHECK=true pihole -up
    run_command "Updating Pi-hole gravity list" sudo pihole -g
else
    echo -e "${YELLOW}Pi-hole not found, skipping.${NC}\n"
fi

# --- Reboot Check & Final Summary ---
if [[ -f /var/run/reboot-required ]]; then
    echo -e "${YELLOW}*** A system reboot is required to complete the updates. ***${NC}\n"
fi

if [[ ${#FAILED_STEPS[@]} -eq 0 ]]; then
    echo -e "${GREEN}System update complete with no errors!${NC}"
    exit 0
else
    echo -e "${RED}System update finished, but the following steps had errors:${NC}" >&2
    for step in "${FAILED_STEPS[@]}"; do
        echo -e "${RED}  - ${step}${NC}" >&2
    done
    exit 1
fi