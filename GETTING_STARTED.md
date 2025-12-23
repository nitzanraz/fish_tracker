# Getting Started with Fish Tracker on Haifa DLC

## Quick Start Guide

### 1. Upload Project to DLC

From your local machine:

```bash
# Connect and create directory
ssh YOUR_USERNAME@login01.dlc.cs.haifa.ac.il
mkdir -p ~/fish_tracker
exit

# Upload project files
cd /Users/raznitzan/vscode/fish_tracker
scp -r * YOUR_USERNAME@login01.dlc.cs.haifa.ac.il:~/fish_tracker/
```

### 2. Run Setup on DLC

Connect to DLC and run the setup script:

```bash
ssh YOUR_USERNAME@login01.dlc.cs.haifa.ac.il
cd ~/fish_tracker
bash setup_on_dlc.sh
```

This script will:
- Create necessary directories
- Pull the PyTorch NGC container
- Install Python dependencies
- Verify GPU access

### 3. Upload Your Fish Videos/Frames

```bash
# From local machine
scp your_video.mp4 YOUR_USERNAME@login01.dlc.cs.haifa.ac.il:~/fish_tracker/data/

# Or if you have frames already:
scp frame_*.jpg YOUR_USERNAME@login01.dlc.cs.haifa.ac.il:~/fish_tracker/data/frames/
```

### 4. Start Jupyter Session

```bash
# On DLC
cd ~/fish_tracker
./interactive_job.sh
```

This will:
- Request 1 GPU for 4 hours
- Start Jupyter Lab
- Show you a URL with token

### 5. Access Jupyter from Your Computer

On your **local machine**, open a new terminal:

```bash
ssh -L 8888:localhost:8888 YOUR_USERNAME@login01.dlc.cs.haifa.ac.il
```

Keep this terminal open, then open in browser:
```
http://localhost:8888
```

Paste the token from the Jupyter output.

### 6. Open the Notebook

In Jupyter Lab, navigate to:
```
notebooks/fish_tracking_sam2.ipynb
```

## Workflow Overview

```
┌─────────────────────────────────────────┐
│ 1. Upload video/frames to DLC          │
│    → data/frames/                       │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│ 2. Start Jupyter session                │
│    → Interactive GPU job                │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│ 3. Run notebook cells                   │
│    → Load SAM2 model                    │
│    → Load video frames                  │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│ 4. Annotate first frame                 │
│    → Click on fish (interactive)        │
│    → Or provide coordinates             │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│ 5. Track across frames                  │
│    → SAM2 propagates annotations        │
│    → Automatic tracking                 │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│ 6. Review and export                    │
│    → Visualize results                  │
│    → Export COCO annotations            │
│    → Save masks                         │
└─────────────────────────────────────────┘
```

## Example: Complete Session

```bash
# 1. Connect to DLC
ssh myusername@login01.dlc.cs.haifa.ac.il

# 2. Go to project
cd ~/fish_tracker

# 3. Start interactive session
./interactive_job.sh

# Inside the container, you'll see something like:
# [I 2025-12-23 10:30:00.000 ServerApp]
#     http://localhost:8888/lab?token=abc123...

# 4. In a NEW terminal on your local machine:
ssh -L 8888:localhost:8888 myusername@login01.dlc.cs.haifa.ac.il

# 5. Open browser to: http://localhost:8888
# 6. Open: notebooks/fish_tracking_sam2.ipynb
# 7. Run cells and annotate your fish!
```

## Checking Your Job

While working, you can check job status from another terminal:

```bash
# On DLC
squeue -u $USER

# Example output:
# JOBID  PARTITION  NAME  USER  STATE  TIME  NODES
# 1234   batch      bash  you   RUNNING 0:15  1
```

## After Your Session

When you close Jupyter or your session ends:
- Results are saved in `outputs/`
- Models remain in `models/`
- Frames stay in `data/frames/`

Download results to your local machine:

```bash
# From local machine
scp -r YOUR_USERNAME@login01.dlc.cs.haifa.ac.il:~/fish_tracker/outputs ./
```

## Troubleshooting

### Can't connect to Jupyter
1. Check that interactive job is still running: `squeue -u $USER`
2. Verify SSH tunnel is active
3. Try a different port if 8888 is in use

### Out of GPU memory
1. Restart the kernel in Jupyter
2. Request more GPUs: Edit `interactive_job.sh` and change `--gpus=1` to `--gpus=2`
3. Use a smaller SAM2 model in the notebook

### Container issues
```bash
cd ~/fish_tracker
bash setup_on_dlc.sh  # Re-run setup
```

## Need Help?

1. Check `README.md` for detailed documentation
2. Check `DLC_QUICKREF.md` for DLC commands
3. Contact Haifa University IT for DLC-specific issues

## Tips

- Start with a small subset of frames (10-20) to test
- Save your work frequently in Jupyter
- Use `Ctrl+C` in the terminal to stop Jupyter
- Use `scancel JOB_ID` to cancel jobs if needed

## Next Steps

After successful tracking:
- Use annotations for training detection models
- Analyze fish behavior patterns
- Create visualization videos
- Export to other annotation formats

Happy tracking! 🐟
