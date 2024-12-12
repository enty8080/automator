#!/bin/bash

# Script Name: secure_setup.sh
# Author: Ivan Nikolskiy
# Date Created: 01/12/2024
# Description: This script configures a secure environment by setting up a firewall,
#              disabling unused services (provided by the user).

# Exit immediately if a command exits with a non-zero status
set -e

# Check for root priviledges (for firewall-cmd and systemctl)
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo." >&2
    exit 1
fi

echo "Starting Secure Environment Setup..."

# Prompt user for allowed ports
echo "Please enter the allowed ports, separated by spaces:"
read -r -a FIREWALL_PORTS

# Prompt user for disallowed Ports
echo "Please enter the ports to disallow through the firewall, separated by spaces:"
read -r -a DISALLOWED_PORTS

# Firewall configuration
# (not using sudo because this script is run with EUID == 0)

echo "Configuring the firewall..."
if [ ${#FIREWALL_PORTS[@]} -eq 0 ]; then
    echo "No ports provided. Skipping allowed configuration."
else
    for PORT in "${FIREWALL_PORTS[@]}"; do
        echo "Allowing port $PORT..."
        firewall-cmd --permanent --zone=public --add-port=$PORT/tcp
    done
fi

if [ ${#DISALLOWED_PORTS[@]} -eq 0 ]; then
    echo "No ports provided. Skipping disallowing ports."
else
    for PORT in "${DISALLOWED_PORTS[@]}"; do
        echo "Disallowing port $PORT..."
        sudo firewall-cmd --permanent --zone=public --remove-port=$PORT/tcp
    done
fi

firewall-cmd --reload

# Prompt user for unused services
echo "Please enter unused services to disable, separated by spaces:"
read -r -a UNUSED_SERVICES

# Disable unused services
if [ ${#UNUSED_SERVICES[@]} -eq 0 ]; then
    echo "No services provided. Skipping unused services configuration."
else
    echo "Disabling unused services..."
    for SERVICE in "${UNUSED_SERVICES[@]}"; do
        echo "Disabling $SERVICE..."
        if systemctl disable "$SERVICE"; then
            echo "$SERVICE disabled successfully."
        else
            echo "$SERVICE could not be disabled or does not exist."
        fi
    done
fi

echo "Secure environment setup completed successfully!"
