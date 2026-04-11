#!/bin/bash

SETTINGS_PATH=".vscode/settings.json"
IP=""

# Extract IP from settings.json
if [ -f "$SETTINGS_PATH" ]; then
    # Use grep and awk/cut to reliably extract the IP without jq
    IP=$(grep -E '"arduino\.ip"\s*:' "$SETTINGS_PATH" | awk -F'"' '{print $4}')
fi

if [ -z "$IP" ]; then
    echo "❌ No Arduino IP found. Please configure 'arduino.ip' in .vscode/settings.json"
    exit 0
fi

# Ensure SSH key exists
SSH_KEY="$HOME/.ssh/id_ed25519"
if [ ! -f "$SSH_KEY" ]; then
    echo "SSH key not found locally. Generating a new ed25519 key..."
    ssh-keygen -t ed25519 -f "$SSH_KEY" -N ""
fi

# Test if passwordless authentication already works
echo "Testing passwordless authentication to arduino@$IP..."
if ssh -o BatchMode=yes -o ConnectTimeout=3 "arduino@$IP" exit 2>/dev/null; then
    echo "✅ Passwordless SSH is already configured and working smoothly!"
else
    echo "Password authentication required. Securely copying public key to the Arduino..."
    echo -e "\033[0;36m>>> PLEASE ENTER THE ARDUINO PASSWORD BELOW <<<\033[0m"
    
    # Mac/Linux have ssh-copy-id built-in
    ssh-copy-id -i "$SSH_KEY.pub" "arduino@$IP"
    
    if [ $? -eq 0 ]; then
        echo "✅ SSH Key successfully registered on the Arduino!"
    else
        echo "❌ Failed to set up SSH key."
        exit 0
    fi
fi
