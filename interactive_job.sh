#!/bin/bash
# Script to start an interactive session on Haifa DLC for Jupyter notebook work
# Run this after connecting to login01.dlc.cs.haifa.ac.il
#
# Usage:
#   ./interactive_job.sh         # Start Jupyter Lab
#   ./interactive_job.sh bash    # Start interactive bash shell

WRITABLE_CONTAINER="$HOME/pytorch-writable.sqsh"

if [ ! -f "$WRITABLE_CONTAINER" ]; then
    echo "❌ Writable container not found: $WRITABLE_CONTAINER"
    echo "Please run setup_on_dlc.sh first to create it."
    exit 1
fi

# Check if bash mode requested
MODE=${1:-jupyter}

if [[ "$MODE" == "bash" ]]; then
    echo "Starting interactive bash session on DLC..."
    echo ""
    echo "This will:"
    echo "1. Allocate 1 GPU for 4 hours"
    echo "2. Use pre-configured container with all dependencies"
    echo "3. Mount your fish_tracker directory"
    echo "4. Start interactive bash shell"
    echo ""
    
    # Start interactive bash shell
    srun --gpus=1 \
         --time=04:00:00 \
         --container-image=$WRITABLE_CONTAINER \
         --container-mounts=$HOME/fish_tracker:/workspace \
         --pty /bin/bash -c "cd /workspace && exec /bin/bash"
else
    echo "Starting interactive Jupyter session on DLC..."
    echo ""
    echo "This will:"
    echo "1. Allocate 1 GPU for 4 hours"
    echo "2. Use pre-configured container with all dependencies"
    echo "3. Mount your fish_tracker directory"
    echo "4. Start Jupyter Lab"
    echo ""
    
    # Start interactive job with Jupyter
    srun --gpus=1 \
         --time=04:00:00 \
         --container-image=$WRITABLE_CONTAINER \
         --container-mounts=$HOME/fish_tracker:/workspace \
         --pty /bin/bash -c "
             cd /workspace && \
             jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root
         "
fi

# After running this, you'll see a URL with a token
# Use SSH port forwarding from your local machine:
# ssh -L 8888:localhost:8888 YOUR_USERNAME@login01.dlc.cs.haifa.ac.il
# Then open http://localhost:8888 in your browser
