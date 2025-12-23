#!/bin/bash
# Setup SSH key authentication for Haifa University DLC
# This allows password-less login

echo "=========================================="
echo "SSH Key Setup for DLC Password-less Login"
echo "=========================================="
echo ""

DLC_HOST="login01.dlc.cs.haifa.ac.il"

# Check if SSH key already exists
if [ -f ~/.ssh/id_rsa.pub ]; then
    echo "✓ SSH key already exists: ~/.ssh/id_rsa.pub"
else
    echo "Generating new SSH key pair..."
    ssh-keygen -t rsa -b 4096 -C "$(whoami)@$(hostname)" -f ~/.ssh/id_rsa -N ""
    echo "✓ SSH key generated"
fi

echo ""
echo "Your public key:"
echo "----------------------------------------"
cat ~/.ssh/id_rsa.pub
echo "----------------------------------------"
echo ""

# Prompt for username
read -p "Enter your DLC username: " DLC_USER

echo ""
echo "Copying SSH key to DLC server..."
echo "You will need to enter your password ONE MORE TIME:"
echo ""

# Copy key to DLC
ssh-copy-id -i ~/.ssh/id_rsa.pub "$DLC_USER@$DLC_HOST"

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✓ Success! SSH key installed"
    echo "=========================================="
    echo ""
    echo "Testing password-less login..."
    ssh -o BatchMode=yes "$DLC_USER@$DLC_HOST" "echo '✓ Password-less login works!'" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "You can now login without password:"
        echo "  ssh $DLC_USER@$DLC_HOST"
        echo ""
        echo "Optional: Add this alias to your ~/.zshrc:"
        echo "  alias dlc='ssh $DLC_USER@$DLC_HOST'"
    else
        echo "Note: Test connection failed, but key should be installed."
        echo "Try: ssh $DLC_USER@$DLC_HOST"
    fi
else
    echo ""
    echo "❌ Failed to copy SSH key"
    echo ""
    echo "Manual method:"
    echo "1. Copy your public key (shown above)"
    echo "2. SSH to DLC: ssh $DLC_USER@$DLC_HOST"
    echo "3. Run: mkdir -p ~/.ssh && chmod 700 ~/.ssh"
    echo "4. Run: echo 'YOUR_PUBLIC_KEY' >> ~/.ssh/authorized_keys"
    echo "5. Run: chmod 600 ~/.ssh/authorized_keys"
fi

echo ""
