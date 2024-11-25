---

# Setup Network Script

This repository contains a Bash script to configure a static IP address or set up a bridge mode on Ubuntu systems using Netplan. The script ensures proper YAML configuration, handles backups of existing `.yaml` files, and provides a user-friendly interactive setup process.

## Features
- Configure a static IP address with user prompts.
- Optionally set up a bridge mode interface.
- Automatic detection of the current IP address, gateway, and interface.
- Backup of existing Netplan configuration files (`*.yaml`) before applying new settings.
- Error handling and strict file permissions for security.

## Requirements
- Ubuntu system with Netplan installed (default on Ubuntu 18.04+).
- Root privileges to execute the script.

## Installation and Usage

### Step 1: Download the Script
Run the following command to download the script:
```bash
wget https://raw.githubusercontent.com/whmcs-smarters/setup-local-server/refs/heads/main/setup_network.sh
```

### Step 2: Make the Script Executable
Grant execute permissions to the script:
```bash
chmod +x setup_network.sh
```

### Step 3: Run the Script
Execute the script with `sudo` to ensure proper permissions:
```bash
sudo ./setup_network.sh
```

### What Happens Next?
1. The script will prompt you for confirmation to proceed.
2. You'll be asked to confirm or modify the current IP address and gateway.
3. Optionally, you can configure bridge mode.
4. The script will back up existing Netplan configuration files to a timestamped directory.
5. It will generate and apply a new Netplan configuration.

### Example Output
Below is an example of the script's prompts:
```
The script will set up a static IP address. Do you want to run this script? Y/n [Y]:
Current IP Address: 192.168.0.100
Press Enter to use this IP address or specify a new one:
Current Gateway: 192.168.0.1
Press Enter to use this gateway or specify a new one:
Do you want to set up Bridge Mode? Y/n [Y]:
```

## Troubleshooting
- If the script encounters errors during `netplan apply`, review the generated YAML file:
  ```bash
  sudo nano /etc/netplan/01-netcfg.yaml
  ```
- Test the configuration with:
  ```bash
  sudo netplan try
  ```

## License
This project is licensed under the MIT License.

---

This `README.md` provides all necessary information for using the script, including an example output and troubleshooting tips. Let me know if you need further modifications!
