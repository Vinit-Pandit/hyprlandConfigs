#!/bin/bash

# Bluetooth Auto-Pairing Agent
# This script automatically confirms all Bluetooth pairing requests

# Kill any existing instances
pkill -f "bt-agent.sh" > /dev/null 2>&1

# Create a named pipe for interaction
PIPE="/tmp/bt-agent-$$"
mkfifo "$PIPE" 2>/dev/null || true

# Function to handle confirmations
(
    while true; do
        # Read from bluetoothctl
        read -r line || break
        
        # If it's a confirmation request, respond with "yes"
        if [[ "$line" == *"Confirm passkey"* ]] || [[ "$line" == *"Authorize service"* ]] || [[ "$line" == *"confirm"* ]]; then
            echo "yes"
        fi
    done
) | bluetoothctl 2>&1 &

# Keep script running
wait
