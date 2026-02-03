#!/bin/bash
# Script to set up SSH tunnel for accessing Jupyter Lab running on DLC
# Run this on your LOCAL machine in a separate terminal

DLC_USER="rnitzan1"
DLC_HOST="login01.dlc.cs.haifa.ac.il"
LOCAL_PORT=18888
REMOTE_PORT=8888

echo "=========================================="
echo "Setting up SSH tunnel for Jupyter Lab"
echo "=========================================="
echo ""
echo "Connecting to: $DLC_USER@$DLC_HOST"
echo "Port forwarding: localhost:$LOCAL_PORT -> localhost:$REMOTE_PORT"
echo ""
echo "After the tunnel is established:"
echo "1. Keep this terminal window open"
echo "2. Open your browser to: http://localhost:$LOCAL_PORT"
echo "3. Paste the token from the Jupyter output on DLC"
echo ""
echo "Press Ctrl+C to close the tunnel when done."
echo ""
echo "=========================================="
echo ""

# Establish SSH tunnel with port forwarding
ssh -N -L $LOCAL_PORT:dgx05:$REMOTE_PORT $DLC_USER@$DLC_HOST
