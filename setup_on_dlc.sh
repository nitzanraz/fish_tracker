#!/bin/bash
# First-time setup script for Fish Tracker on Haifa DLC
# Run this script after uploading the project to DLC

set -e  # Exit on error

echo "=========================================="
echo "Fish Tracker - Initial Setup on DLC"
echo "=========================================="
echo ""

# Check if running on DLC
HOSTNAME=$(hostname)
if [[ ! $HOSTNAME =~ (dlc\.cs\.haifa\.ac\.il|^login[0-9]+$) ]]; then
    echo "⚠️  Warning: This doesn't appear to be a DLC server"
    echo "Current hostname: $HOSTNAME"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

PROJECT_DIR="$HOME/fish_tracker"
CONTAINER_NAME="pytorch:23.12-py3.sqsh"
CONTAINER_PATH="$HOME/$CONTAINER_NAME"
WRITABLE_CONTAINER="$HOME/pytorch-writable.sqsh"

echo "Project directory: $PROJECT_DIR"
echo "Base container: $CONTAINER_PATH"
echo "Writable container: $WRITABLE_CONTAINER"
echo ""

# Step 1: Check if project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Project directory not found: $PROJECT_DIR"
    echo "Please upload the project files first:"
    echo "  scp -r fish_tracker/ YOUR_USERNAME@login01.dlc.cs.haifa.ac.il:~/"
    exit 1
fi
echo "✓ Project directory found"

# Step 2: Create necessary directories
echo ""
echo "Creating directories..."
mkdir -p "$PROJECT_DIR/data/frames"
mkdir -p "$PROJECT_DIR/models"
mkdir -p "$PROJECT_DIR/outputs"
mkdir -p "$PROJECT_DIR/scripts"
echo "✓ Directories created"

# Step 3: Check/pull container
echo ""
if [ -f "$CONTAINER_PATH" ]; then
    echo "✓ Container already exists: $CONTAINER_PATH"
else
    echo "Pulling PyTorch container from NGC..."
    echo "This may take several minutes..."
    /dlc/sw/bin/pull_container_to_file.sh nvcr.io/nvidia/pytorch:23.12-py3
    
    # Verify container was created
    if [ ! -f "$CONTAINER_PATH" ]; then
        echo "❌ Container not found after pull at: $CONTAINER_PATH"
        echo "Checking current directory..."
        ls -lh *.sqsh 2>/dev/null || echo "No .sqsh files found"
        exit 1
    fi
    echo "✓ Container pulled successfully"
fi

# Verify container path is correct
echo "Verifying container: $CONTAINER_PATH"
if [ ! -f "$CONTAINER_PATH" ]; then
    echo "❌ Container file not found: $CONTAINER_PATH"
    echo "Looking for container files..."
    find ~ -name "*.sqsh" -type f 2>/dev/null | head -5
    exit 1
fi

# Step 4: Make scripts executable
echo ""
echo "Making scripts executable..."
chmod +x "$PROJECT_DIR/dlc_setup.sh" 2>/dev/null || true
chmod +x "$PROJECT_DIR/interactive_job.sh" 2>/dev/null || true
chmod +x "$PROJECT_DIR/job_template.sh" 2>/dev/null || true
echo "✓ Scripts are executable"

# Step 5: Test container and install dependencies
echo ""
echo "Testing container and installing dependencies..."
echo "This will start a quick test job and create a writable container..."
echo "Dependencies will be saved for future use."
echo ""

srun --gpus=1 --time=15:00 \
     --container-image="$CONTAINER_PATH" \
     --container-save="$WRITABLE_CONTAINER" \
     --container-mounts="$PROJECT_DIR:/workspace" \
     /bin/bash -c "
         echo 'Testing Python and CUDA...'
         python -c 'import torch; print(f\"PyTorch: {torch.__version__}\"); print(f\"CUDA available: {torch.cuda.is_available()}\")'
         
         echo ''
         echo 'Installing ALL dependencies (including JupyterLab)...'
         echo 'This happens once and will be saved to the container.'
         cd /workspace
         if [ -f requirements.txt ]; then
             pip install -r requirements.txt
             echo '✓ Dependencies installed and saved'
         else
             echo '⚠️  requirements.txt not found'
         fi
         
         echo ''
         echo 'Verifying installation...'
         python -c 'import jupyterlab; print(f\"JupyterLab: {jupyterlab.__version__}\")'  
         echo ''
         echo 'Setup complete inside container!'
     "

if [ $? -eq 0 ] && [ -f "$WRITABLE_CONTAINER" ]; then
    echo ""
    echo "✓ Writable container created with all dependencies: $WRITABLE_CONTAINER"
else
    echo ""
    echo "⚠️  Warning: Container save may have failed"
    echo "Check if $WRITABLE_CONTAINER exists"
fi

echo ""
echo "=========================================="
echo "✓ Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Upload your fish video data:"
echo "   scp video_frames/* $USER@login01.dlc.cs.haifa.ac.il:~/fish_tracker/data/frames/"
echo ""
echo "2. Start an interactive Jupyter session:"
echo "   cd ~/fish_tracker"
echo "   ./interactive_job.sh"
echo ""
echo "3. Or submit a batch job:"
echo "   sbatch job_template.sh"
echo ""
echo "4. Check the README.md for detailed instructions"
echo ""
echo "Useful commands:"
echo "  squeue -u $USER        # Check your jobs"
echo "  sinfo -l               # Check cluster status"
echo "  scancel JOB_ID         # Cancel a job"
echo ""
