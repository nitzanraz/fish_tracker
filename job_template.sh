#!/bin/bash
#SBATCH -J fish-tracking-sam2
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err
#SBATCH -D /users/YOUR_USERNAME/fish_tracker
#SBATCH --time=04:00:00
#SBATCH -G 1
#SBATCH --get-user-env
#SBATCH --nodes 1

# Haifa University DLC Batch Job Template for Fish Tracking with SAM2
# Replace YOUR_USERNAME with your actual DLC username

echo "=========================================="
echo "Fish Tracking with SAM2 - Batch Job"
echo "Job ID: $SLURM_JOB_ID"
echo "Node: $SLURM_NODELIST"
echo "=========================================="

# Run Jupyter notebook as a script (papermill can be used for this)
# Or run Python script directly
srun --ntasks=1 \
     --container-image=$HOME/pytorch:23.12-py3.sqsh \
     --container-mounts=$HOME/fish_tracker:/workspace \
     python /workspace/scripts/run_tracking.py

echo "Job completed!"
