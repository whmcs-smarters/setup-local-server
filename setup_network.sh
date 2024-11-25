#!/bin/bash

# Define backup directory for .yaml files
BACKUP_DIR="/etc/netplan/backup_$(date +%F_%T)"
mkdir -p "$BACKUP_DIR"

# Function to get the current IP details
get_ip_details() {
    ip -o -4 addr list | awk '/inet/ && $2 != "lo" {print $4}' | awk -F '/' '{print $1}'
}

# Function to get the default gateway
get_default_gateway() {
    ip route | awk '/default/ {print $3}'
}

# Function to get the default interface
get_default_interface() {
    ip -o -4 route show to default | awk '{print $5}'
}

# Prompt user for confirmation
read -p "The script will set up a static IP address. Do you want to run this script? Y/n [Y]: " RUN_SCRIPT
RUN_SCRIPT=${RUN_SCRIPT:-Y}
if [[ $RUN_SCRIPT != [Yy] ]]; then
    echo "Script execution canceled."
    exit 1
fi

# Confirm static IP setup
read -p "Do you want to set up a Static IP Address? Y/n [Y]: " SETUP_STATIC_IP
SETUP_STATIC_IP=${SETUP_STATIC_IP:-Y}
if [[ $SETUP_STATIC_IP != [Yy] ]]; then
    echo "Static IP setup skipped."
    exit 1
fi

# Retrieve current IP and interface
CURRENT_IP=$(get_ip_details)
DEFAULT_INTERFACE=$(get_default_interface)
DEFAULT_GATEWAY=$(get_default_gateway)

# Show IP address and prompt user
echo "Current IP Address: $CURRENT_IP"
read -p "Press Enter to use this IP address or specify a new one: " NEW_IP
NEW_IP=${NEW_IP:-$CURRENT_IP}

# Show gateway and prompt user
echo "Current Gateway: $DEFAULT_GATEWAY"
read -p "Press Enter to use this gateway or specify a new one: " NEW_GATEWAY
NEW_GATEWAY=${NEW_GATEWAY:-$DEFAULT_GATEWAY}

# Ask user if they want to set up Bridge Mode
read -p "Do you want to set up Bridge Mode? Y/n [Y]: " SETUP_BRIDGE
SETUP_BRIDGE=${SETUP_BRIDGE:-Y}

# Create backup of existing .yaml files if they exist
if ls /etc/netplan/*.yaml >/dev/null 2>&1; then
    echo "Backing up existing .yaml files to $BACKUP_DIR..."
    cp /etc/netplan/*.yaml "$BACKUP_DIR"
else
    echo "No existing .yaml files found. Skipping backup."
fi

# Create a new Netplan configuration
NETPLAN_FILE="/etc/netplan/01-netcfg.yaml"
if [[ $SETUP_BRIDGE == [Yy] ]]; then
    # Prompt for bridge interface name
    read -p "Enter the name for the bridge interface [default: br0]: " BRIDGE_NAME
    BRIDGE_NAME=${BRIDGE_NAME:-br0}

    # Generate Netplan configuration for bridge mode
    cat <<EOF > "$NETPLAN_FILE"
network:
  version: 2
  renderer: networkd
  ethernets:
    $DEFAULT_INTERFACE:
      dhcp4: no
  bridges:
    $BRIDGE_NAME:
      interfaces: [$DEFAULT_INTERFACE]
      addresses:
        - $NEW_IP/24
      routes:
        - to: 0.0.0.0/0
          via: $NEW_GATEWAY
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
EOF
    echo "Bridge Mode configured with bridge name: $BRIDGE_NAME"
else
    # Generate Netplan configuration for static IP without bridge mode
    cat <<EOF > "$NETPLAN_FILE"
network:
  version: 2
  renderer: networkd
  ethernets:
    $DEFAULT_INTERFACE:
      dhcp4: no
      addresses:
        - $NEW_IP/24
      routes:
        - to: 0.0.0.0/0
          via: $NEW_GATEWAY
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
EOF
    echo "Static IP configured without Bridge Mode on interface: $DEFAULT_INTERFACE"
fi

# Set correct permissions
chmod 600 "$NETPLAN_FILE"

# Apply Netplan configuration
echo "Applying the new Netplan configuration..."
if netplan apply; then
    echo "Network configuration applied successfully!"
else
    echo "Error in applying configuration. Please check the YAML file for syntax issues."
    echo "YAML file location: $NETPLAN_FILE"
fi

# Display the final configuration
echo "Final network configuration:"
cat "$NETPLAN_FILE"
