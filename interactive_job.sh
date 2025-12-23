#!/bin/bash
# Script to start an interactive session on Haifa DLC for Jupyter notebook work
# Run this after connecting to login01.dlc.cs.haifa.ac.il

echo "Starting interactive Jupyter session on DLC..."
echo ""
echo "This will:"
echo "1. Allocate 1 GPU for 4 hours"
echo "2. Mount your fish_tracker directory"
echo "3. Start Jupyter Lab"
echo ""

# Start interactive job with Jupyter
srun --gpus=1 \
     --time=04:00:00 \
     --container-image=~/pytorch:23.12-py3.sqsh \
     --container-save=~/pytorch:23.12-py3.sqsh \
     --container-mounts=$HOME/fish_tracker:/workspace \
     --pty /bin/bash -c "
         cd /workspace && \
         pip install -q jupyterlab && \
         jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root
     "

# After running this, you'll see a URL with a token
# Use SSH port forwarding from your local machine:
# ssh -L 8888:localhost:8888 YOUR_USERNAME@login01.dlc.cs.haifa.ac.il
# Then open http://localhost:8888 in your browser
