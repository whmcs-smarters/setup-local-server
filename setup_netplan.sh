#!/bin/bash

# Define variables
NETPLAN_DIR="/etc/netplan"
NEW_CONFIG_FILE="$NETPLAN_DIR/01-netcfg.yaml"
INTERFACE="enp3s0"
STATIC_IP="192.168.0.129/24"
GATEWAY="192.168.0.1"
DNS_PRIMARY="8.8.8.8"   # Primary DNS (Google Public DNS)
DNS_SECONDARY="8.8.4.4" # Secondary DNS (Google Public DNS)

# Backup existing Netplan configuration
echo "Backing up existing Netplan configuration..."
mkdir -p "$NETPLAN_DIR/backup"
cp $NETPLAN_DIR/*.yaml "$NETPLAN_DIR/backup/" 2>/dev/null

# Remove all existing YAML files
echo "Removing old Netplan configuration files..."
rm -f $NETPLAN_DIR/*.yaml

# Create a new Netplan configuration file
echo "Creating a new Netplan configuration file..."
cat <<EOL > $NEW_CONFIG_FILE
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    $INTERFACE:
      dhcp4: false
      dhcp6: false
      addresses:
        - $STATIC_IP
      routes:
        - to: default
          via: $GATEWAY
      nameservers:
        addresses:
          - $DNS_PRIMARY
          - $DNS_SECONDARY
EOL

# Set correct permissions for the configuration file
echo "Setting correct permissions for the configuration file..."
chmod 600 $NEW_CONFIG_FILE

# Apply the new Netplan configuration
echo "Applying the new Netplan configuration..."
netplan apply

# Restart NetworkManager to ensure settings take effect
echo "Restarting NetworkManager service..."
systemctl restart NetworkManager

# Display the new configuration
echo "New Netplan configuration applied:"
cat $NEW_CONFIG_FILE
