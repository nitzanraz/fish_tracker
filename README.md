# Fish Tracker with SAM2

A fish tracking and annotation tool using Meta's Segment Anything Model 2 (SAM2), designed to run on Haifa University's Deep Learning Cluster (DLC).

## Project Overview

This project provides an interactive Jupyter notebook-based workflow for:
- Tracking fish in video sequences
- Semi-automatic annotation with SAM2
- Exporting annotations in COCO format
- Running on GPU-accelerated infrastructure

## Directory Structure

```
fish_tracker/
├── data/                  # Video frames and raw data
│   └── frames/           # Extracted video frames
├── models/               # SAM2 model checkpoints
├── outputs/              # Tracking results and annotations
│   ├── masks_*/         # Segmentation masks
│   ├── overlays_*/      # Visualization overlays
│   └── *.json           # Annotation files
├── notebooks/            # Jupyter notebooks
│   └── fish_tracking_sam2.ipynb
├── scripts/              # Python scripts (optional)
├── dlc_config.yaml       # DLC server configuration
├── dlc_setup.sh          # Helper script for DLC
├── job_template.sh       # SLURM batch job template
├── interactive_job.sh    # Interactive Jupyter session script
└── requirements.txt      # Python dependencies
```

## Setup on Haifa University DLC

### 1. Connect to DLC

```bash
ssh YOUR_USERNAME@login01.dlc.cs.haifa.ac.il
```

### 2. Clone/Upload Project

```bash
# Create project directory
mkdir -p ~/fish_tracker
cd ~/fish_tracker

# Upload your files using scp from local machine:
# scp -r /path/to/local/fish_tracker/* YOUR_USERNAME@login01.dlc.cs.haifa.ac.il:~/fish_tracker/
```

### 3. Pull NGC Container

```bash
# Pull PyTorch container with CUDA support
/dlc/sw/bin/pull_container_to_file.sh nvcr.io/nvidia/pytorch:23.12-py3
```

This creates `~/pytorch:23.12-py3.sqsh` container image.

### 4. Start Interactive Session with Jupyter

```bash
# Make script executable
chmod +x interactive_job.sh

# Start interactive job (allocates 1 GPU for 4 hours)
./interactive_job.sh
```

Or manually:

```bash
srun --gpus=1 --time=04:00:00 \
     --container-image=~/pytorch:23.12-py3.sqsh \
     --container-save=~/pytorch:23.12-py3.sqsh \
     --container-mounts=$HOME/fish_tracker:/workspace \
     --pty /bin/bash
```

### 5. Install Dependencies in Container

Once inside the container:

```bash
cd /workspace
pip install -r requirements.txt
```

### 6. Start Jupyter Lab

```bash
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root
```

### 7. Access Jupyter from Local Machine

From your **local machine**, create an SSH tunnel:

```bash
ssh -L 8888:localhost:8888 YOUR_USERNAME@login01.dlc.cs.haifa.ac.il
```

Then open `http://localhost:8888` in your browser and paste the token from Jupyter output.

## Usage

### Interactive Notebook Workflow

1. Open `notebooks/fish_tracking_sam2.ipynb`
2. Follow the sections:
   - Install/import dependencies
   - Configure SAM2 model
   - Load your fish video
   - Add tracking points
   - Propagate across frames
   - Visualize and export results

### Preparing Your Data

Place video frames in `data/frames/`:

```bash
# If you have a video file, extract frames using OpenCV:
# See the notebook for frame extraction code
```

Or upload frames directly:

```bash
scp video_frames/* YOUR_USERNAME@login01.dlc.cs.haifa.ac.il:~/fish_tracker/data/frames/
```

### Batch Job Submission

For longer jobs, use SLURM batch submission:

1. Edit `job_template.sh` with your username and paths
2. Submit job:

```bash
sbatch job_template.sh
```

3. Check job status:

```bash
squeue -u YOUR_USERNAME
```

4. View output:

```bash
cat fish-tracking-sam2.*.out
```

## DLC Useful Commands

### Check Cluster Status
```bash
sinfo -l
```

### Check Job Queue
```bash
squeue -l
```

### Cancel Job
```bash
scancel JOB_ID
```

### Interactive Session (Quick Start)
```bash
srun --gpus=1 --pty /bin/bash
```

## SAM2 Model Variants

The project uses `sam2_hiera_large` by default. Available variants:

- `sam2_hiera_tiny` - Fastest, less accurate
- `sam2_hiera_small` - Balanced
- `sam2_hiera_base_plus` - Good accuracy
- `sam2_hiera_large` - Best accuracy (default)

Modify in notebook configuration section.

## Output Formats

### COCO JSON
Annotations exported in COCO format:
```json
{
  "images": [...],
  "annotations": [
    {
      "id": 1,
      "image_id": 0,
      "category_id": 1,
      "bbox": [x, y, width, height],
      "track_id": 1
    }
  ],
  "categories": [{"id": 1, "name": "fish"}]
}
```

### Masks
Binary segmentation masks saved as PNG files in `outputs/masks_*/`.

### Overlays
Visualization images with masks overlaid on frames in `outputs/overlays_*/`.

## Troubleshooting

### Container Issues
If container fails to load:
```bash
# Re-pull container
/dlc/sw/bin/pull_container_to_file.sh nvcr.io/nvidia/pytorch:23.12-py3
```

### GPU Not Available
Check GPU allocation:
```bash
nvidia-smi  # Inside container
```

Make sure you requested GPUs with `--gpus=N`.

### Out of Memory
- Reduce batch size or number of frames
- Use smaller SAM2 model variant
- Request node with more GPU memory

### Jupyter Connection Issues
Ensure SSH tunnel is active and port 8888 is not in use.

## Resources

- **SAM2 Repository**: https://github.com/facebookresearch/segment-anything-2
- **DLC Documentation**: Contact Haifa University IT
- **SLURM Documentation**: https://slurm.schedmd.com/

## License

This project uses Meta's SAM2 model. See SAM2 license for model usage terms.

## Contact

For issues related to:
- DLC access: Contact Haifa University IT
- Project code: [Your contact information]
