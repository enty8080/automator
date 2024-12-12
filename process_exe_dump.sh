#!/bin/bash

# Script Name: memory_dump.sh
# Author: Ivan Nikolskiy
# Date Created: 01/12/2024
# Description: This script takes a process ID and an output file, then it checks if process executable is deleted.
#              If the executable file of the process was deleted, it helps recover it from memory.
#              Useful if you have a malware running in your system and it was loaded reflectively

# Exit immediately if a command exits with a non-zero status
set -e

# Check for root priviledges (for firewall-cmd and systemctl)
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo." >&2
    exit 1
fi

# Prompt for Process ID and Output File
read -p "Enter the Process ID (PID): " PID
read -p "Enter the Output File Path: " OUTPUT_FILE

# Validate PID is a correct integer
if ! [[ "$PID" =~ ^[0-9]+$ ]]; then
    echo "Error: PID must be a valid integer." >&2
    exit 1
fi

# Validate that the PID exists
if ! kill -0 "$PID" 2>/dev/null; then
    echo "Error: Process with PID $PID does not exist." >&2
    exit 1
fi

# Check if the executable file is deleted
EXEC_PATH=$(readlink -f /proc/$PID/exe 2>/dev/null)
if [[ "$EXEC_PATH" == *"(deleted)"* ]]; then
    echo "Warning: The executable file for process $PID has been deleted."
    echo "Attempting to recover executable from memory."

    if cp /proc/$PID/exe "$OUTPUT_FILE" 2>/dev/null; then
        echo "Executable recovered successfully and saved to $OUTPUT_FILE."
    else
        echo "Error: Failed to recover the executable." >&2
        exit 1
    fi
else
    echo "Executable path: $EXEC_PATH"
    if cp "$EXEC_PATH" "$OUTPUT_FILE" 2>/dev/null; then
        echo "Executable copied successfully to $OUTPUT_FILE."
    else
        echo "Error: Failed to copy the executable." >&2
        exit 1
    fi
fi
