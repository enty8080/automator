#!/bin/bash

# Script Name: user_setup.sh
# Author: Ivan Nikolskiy
# Date Created: 01/12/2024
# Description: This script creates a new user, assigns a home directory, sets a password, and adds them to a group.

# Exit immediately if a command exits with a non-zero status
set -e

# Check for root priviledges (for useradd and passwd)
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo." >&2
    exit 1
fi

# Prompt for user details
echo "Enter details for the new user: "

read -p "Username: " USERNAME
read -p "Primary Group (leave empty for default): " GROUP
read -p "Home Directory (leave empty for default): " HOME_DIR
read -p "Account Expiration Date (YYYY-MM-DD, leave empty for no expiration): " EXPIRE_DATE
read -sp "Password: " PASSWORD
echo

# Create the user command dynamically
USER_CMD="useradd"

# Add username
USER_CMD+=" $USERNAME"

# Add group if specified
if [ -n "$GROUP" ]; then
    USER_CMD+=" -g $GROUP"
fi

# Add home directory if specified
if [ -n "$HOME_DIR" ]; then
    USER_CMD+=" -d $HOME_DIR"
fi

# Add expiration date if specified
if [ -n "$EXPIRE_DATE" ]; then
    USER_CMD+=" -e $EXPIRE_DATE"
fi

# Execute the user creation command
echo "Creating user..."
$USER_CMD

# Set the user password
echo "$PASSWORD" | passwd --stdin "$USERNAME"

# Output success message
echo "User $USERNAME created successfully."
