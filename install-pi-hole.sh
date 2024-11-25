#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root. Use sudo."
  exit 1
fi

# Check if a static IP is configured
echo "Checking if a static IP is configured..."

# Identify the network interface
NET_INTERFACE=$(ip route | grep default | awk '{print $5}')
if [[ -z "$NET_INTERFACE" ]]; then
  echo "No active network interface detected."
  exit 1
fi

# Get current IP and netmask
STATIC_IP=$(ip -o -f inet addr show "$NET_INTERFACE" | awk '{print $4}' | cut -d/ -f1)
if [[ -z "$STATIC_IP" ]]; then
  echo "No static IP detected. Ensure your system is configured with a static IP before running this script."
  exit 1
fi

echo "Static IP detected: $STATIC_IP"

# Ask for domain name setup
echo "Do you want to set up a domain name? (Y/N)"
read -r SET_DOMAIN

if [[ "$SET_DOMAIN" =~ ^[Yy]$ ]]; then
  echo "Enter the domain name (e.g., smartersdns.server):"
  read -r DOMAIN_NAME
else
  DOMAIN_NAME=$STATIC_IP
  echo "Using current IP address as domain name: $DOMAIN_NAME"
fi

# Update package list
echo "Updating package list..."
apt update -y

# Install dependencies
echo "Installing necessary dependencies..."
apt install -y curl net-tools

# Pre-configure Pi-hole with environment variables
echo "Setting up pre-configuration for Pi-hole..."
export PIHOLE_SKIP_OS_CHECK=true
export PIHOLE_INSTALL="true"
export PIHOLE_INTERFACE=$NET_INTERFACE
export PIHOLE_IPV4_ADDRESS="$STATIC_IP/24"
export PIHOLE_IPV6_ADDRESS=""
export PIHOLE_DNS_1="8.8.8.8"
export PIHOLE_DNS_2="8.8.4.4"
export PIHOLE_WEB_PASSWORD="admin"
export QUERY_LOGGING=true
export INSTALL_WEB_SERVER=true
export INSTALL_WEB_INTERFACE=true
export BLOCKING_ENABLED=true

# Run Pi-hole installer non-interactively
echo "Installing Pi-hole..."
curl -sSL https://install.pi-hole.net | bash /dev/stdin --unattended

# Configure domain name
echo "Configuring domain name..."
echo "$STATIC_IP $DOMAIN_NAME" >> /etc/pihole/custom.list
pihole restartdns

# Display installation details
echo "Installation complete!"
echo "========================================="
echo "Pi-hole Admin Panel: http://$STATIC_IP/admin"
echo "Admin Password: admin"
echo "Domain: $DOMAIN_NAME"
echo "Static IP Address: $STATIC_IP"
echo "========================================="
