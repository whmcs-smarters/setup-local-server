# Setup Netplan Script

This repository contains a bash script to configure a static IP, gateway, and DNS settings on Ubuntu systems using `Netplan` and `NetworkManager`.

## Script Features

- Sets a static IP address for a specified network interface.
- Configures primary and secondary DNS servers.
- Ensures secure file permissions for Netplan YAML configuration.
- Automatically applies the changes.

## Requirements

- **Operating System:** Ubuntu (20.04 or later)
- **Privileges:** Root access or sudo privileges

## Quick Start

Follow these steps to download and run the script:

### Step 1: Download the Script

Run the following command to download the script to your system:

```bash
curl -O https://raw.githubusercontent.com/whmcs-smarters/setup-local-server/refs/heads/main/setup_netplan.sh
