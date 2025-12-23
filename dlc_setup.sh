#!/bin/bash
# Haifa University DLC (Deep Learning Cluster) Setup Script
# This script helps you set up and run jobs on the DLC servers

# DLC Server Configuration
DLC_USERNAME="rnitzan1"
DLC_LOGIN="login01.dlc.cs.haifa.ac.il"
DLC_IP="132.75.245.170"

echo "=========================================="
echo "Haifa University DLC Setup"
echo "=========================================="
echo ""

# Function to pull NGC container
pull_container() {
    echo "Pulling PyTorch NGC container..."
    /dlc/sw/bin/pull_container_to_file.sh nvcr.io/nvidia/pytorch:23.12-py3
    echo "Container pulled successfully!"
}

# Function to submit interactive job
submit_interactive_job() {
    echo "Submitting interactive job with 1 GPU..."
    srun --gpus=1 \
         --container-image=~/pytorch:23.12-py3.sqsh \
         --container-save=~/pytorch:23.12-py3.sqsh \
         --container-mounts=$PWD:/workspace \
         --pty /bin/bash
}

# Function to check job queue
check_queue() {
    echo "Checking job queue..."
    squeue -l
}

# Function to check cluster info
check_cluster() {
    echo "Cluster information:"
    sinfo -l
}

# Display menu
echo "Available commands:"
echo "1. Pull container:         bash dlc_setup.sh pull"
echo "2. Interactive job:        bash dlc_setup.sh interactive"
echo "3. Check queue:            bash dlc_setup.sh queue"
echo "4. Check cluster:          bash dlc_setup.sh cluster"
echo ""
echo "To connect to DLC:"
echo "  ssh $DLC_USERNAME@$DLC_LOGIN"
echo ""

# Execute command based on argument
case "$1" in
    pull)
        pull_container
        ;;
    interactive)
        submit_interactive_job
        ;;
    queue)
        check_queue
        ;;
    cluster)
        check_cluster
        ;;
    *)
        echo "Usage: bash dlc_setup.sh {pull|interactive|queue|cluster}"
        ;;
esac
