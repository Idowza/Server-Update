# Server Update Script

A robust Bash script designed to automate the maintenance and update process for Debian/Ubuntu-based Linux servers. This script handles system packages, containerized applications, and specific services like Pi-hole in a single run.

## Features

- **System Updates**:
  - Refreshes APT package lists.
  - Performs a full system upgrade (`apt full-upgrade`) to ensure all dependencies are up to date.
  - Fixes broken dependencies automatically.
  - Reconfigures partially installed packages.

- **Application Updates**:
  - **Flatpak**: Detects and updates Flatpak applications if installed.
  - **Snap**: Detects and refreshes Snap packages if installed.
  - **Pi-hole**: Detects Pi-hole installation, updates the core system, and refreshes the Gravity list (ad-blocking domains).

- **System Cleanup**:
  - Removes unused dependencies (`autoremove`).
  - Clears the local package cache (`autoclean`) to free up disk space.

## Prerequisites

- A Debian or Ubuntu-based Linux distribution (uses `apt`).
- Root or `sudo` privileges are required to run the script.

## Usage

1.  **Download the script**:
    Clone this repository or download the `update.sh` file directly.

2.  **Make the script executable**:
    Open your terminal and run:
    ```bash
    chmod +x update.sh
    ```

3.  **Run the script**:
    Execute the script with root privileges:
    ```bash
    sudo ./update.sh
    ```

## What it does

When you run the script, it will sequentially:
1.  Check if you are running as root (exits if not).
2.  Update the system package repositories.
3.  Upgrade all installed packages.
4.  Check for `flatpak` and update if found.
5.  Check for `snap` and refresh if found.
6.  Perform system cleanup to remove obsolete packages and cache.
7.  Check for `pihole` and update both the software and blocklists if found.

## License

[MIT](LICENSE)
