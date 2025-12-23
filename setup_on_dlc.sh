#!/bin/bash
# First-time setup script for Fish Tracker on Haifa DLC
# Run this script after uploading the project to DLC

set -e  # Exit on error

echo "=========================================="
echo "Fish Tracker - Initial Setup on DLC"
echo "=========================================="
echo ""

# Check if running on DLC
if [[ ! $(hostname) =~ dlc\.cs\.haifa\.ac\.il ]]; then
    echo "⚠️  Warning: This doesn't appear to be a DLC server"
    echo "Current hostname: $(hostname)"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

PROJECT_DIR="$HOME/fish_tracker"
CONTAINER_NAME="pytorch:23.12-py3.sqsh"
CONTAINER_PATH="$HOME/$CONTAINER_NAME"

echo "Project directory: $PROJECT_DIR"
echo "Container path: $CONTAINER_PATH"
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
    echo "✓ Container pulled successfully"
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
echo "This will start a quick test job..."

srun --gpus=1 --time=10:00 \
     --container-image="$CONTAINER_PATH" \
     --container-save="$CONTAINER_PATH" \
     --container-mounts="$PROJECT_DIR:/workspace" \
     /bin/bash -c "
         echo 'Testing Python and CUDA...'
         python -c 'import torch; print(f\"PyTorch: {torch.__version__}\"); print(f\"CUDA available: {torch.cuda.is_available()}\")'
         
         echo ''
         echo 'Installing dependencies from requirements.txt...'
         cd /workspace
         if [ -f requirements.txt ]; then
             pip install -q -r requirements.txt
             echo '✓ Dependencies installed'
         else
             echo '⚠️  requirements.txt not found'
         fi
         
         echo ''
         echo 'Setup complete inside container!'
     "

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
