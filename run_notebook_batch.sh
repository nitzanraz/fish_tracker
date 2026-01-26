#!/bin/bash
#SBATCH -J fish-tracking-notebook
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err
#SBATCH --time=04:00:00
#SBATCH -G 1
#SBATCH --nodes 1

# Run Jupyter notebook as a batch job on DLC
# This executes the notebook and saves output

NOTEBOOK="notebooks/fish_tracking_sam2.ipynb"
OUTPUT_NOTEBOOK="outputs/fish_tracking_executed_$(date +%Y%m%d_%H%M%S).ipynb"

echo "=========================================="
echo "Running Fish Tracking Notebook"
echo "Job ID: $SLURM_JOB_ID"
echo "Node: $SLURM_NODELIST"
echo "=========================================="

# Run notebook using papermill
srun --ntasks=1 \
     --container-image=$HOME/pytorch:23.12-py3.sqsh \
     --container-mounts=$HOME/fish_tracker:/workspace \
     /bin/bash -c "
         cd /workspace
         pip install -q papermill
         papermill $NOTEBOOK $OUTPUT_NOTEBOOK
     "

echo "Notebook execution complete!"
echo "Output saved to: $OUTPUT_NOTEBOOK"
