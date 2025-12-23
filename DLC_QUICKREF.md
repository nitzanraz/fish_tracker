# Haifa University DLC Quick Reference Guide

## Connection

```bash
ssh YOUR_USERNAME@login01.dlc.cs.haifa.ac.il
# or
ssh YOUR_USERNAME@132.75.245.170
```

## Container Management

### Pull NGC Container
```bash
/dlc/sw/bin/pull_container_to_file.sh nvcr.io/nvidia/pytorch:23.12-py3
```

This saves container to: `~/pytorch:23.12-py3.sqsh`

## Interactive Jobs

### Basic Interactive Session
```bash
srun --gpus=1 --pty /bin/bash
```

### Interactive Session with Container
```bash
srun --gpus=1 \
     --container-image=~/pytorch:23.12-py3.sqsh \
     --container-save=~/pytorch:23.12-py3.sqsh \
     --container-mounts=$HOME/fish_tracker:/workspace \
     --pty /bin/bash
```

### Common SRUN Options
- `--gpus=N` or `-G N`: Number of GPUs (max 8 per node)
- `--time=HH:MM:SS` or `-t`: Time limit (default: unlimited)
- `--nodes=N` or `-N`: Number of nodes
- `--pty`: Allocate pseudo-terminal (for interactive)
- `--container-image=PATH`: Container to use
- `--container-save=PATH`: Save container changes
- `--container-mounts=SRC:DST`: Bind mount directories

## Batch Jobs

### Submit Batch Job
```bash
sbatch job_script.sh
```

### Batch Script Template
```bash
#!/bin/bash
#SBATCH -J job-name
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err
#SBATCH --time=04:00:00
#SBATCH -G 1
#SBATCH --nodes 1

srun --container-image=~/pytorch:23.12-py3.sqsh \
     --container-mounts=$HOME/project:/workspace \
     python /workspace/script.py
```

### Common SBATCH Options
- `-J NAME` or `--job-name=NAME`: Job name
- `-o FILE`: Output file (use %x for job name, %j for job ID)
- `-e FILE`: Error file
- `-G N` or `--gpus=N`: Number of GPUs
- `-N N` or `--nodes=N`: Number of nodes
- `-t TIME` or `--time=TIME`: Time limit
- `--ntasks=N`: Number of tasks
- `--ntasks-per-node=N`: Tasks per node
- `--cpus-per-task=N`: CPUs per task

## Job Management

### Check Queue
```bash
squeue              # All jobs
squeue -u USERNAME  # Your jobs only
squeue -l           # Long format with more details
```

### Check Cluster Status
```bash
sinfo              # Basic info
sinfo -l           # Long format
```

### Cancel Job
```bash
scancel JOB_ID              # Cancel specific job
scancel -u USERNAME         # Cancel all your jobs
scancel --name=JOB_NAME     # Cancel by job name
```

### Job Information
```bash
scontrol show job JOB_ID    # Detailed job info
sacct -j JOB_ID             # Job accounting info
```

## Cluster Information

### Nodes
- **dgx01 - dgx06**: Compute nodes
- Each node: 8x NVIDIA A100 40GB GPUs
- Interconnect: 200Gb/s HDR InfiniBand

### Partitions
- **batch** (default): Main partition

## Container Best Practices

### Mounting Directories
Mount your project directory for access inside container:
```bash
--container-mounts=$HOME/fish_tracker:/workspace
```

Multiple mounts:
```bash
--container-mounts=$HOME/data:/data,$HOME/project:/workspace
```

### Saving Container State
To persist installed packages:
```bash
--container-save=~/pytorch:23.12-py3.sqsh
```

### Installing Packages in Container
```bash
# Inside container
pip install package-name

# Save changes by including --container-save when running srun
```

## File Transfer

### From Local to DLC
```bash
# Single file
scp file.txt USERNAME@login01.dlc.cs.haifa.ac.il:~/

# Directory
scp -r folder/ USERNAME@login01.dlc.cs.haifa.ac.il:~/

# Using rsync (better for large transfers)
rsync -avz folder/ USERNAME@login01.dlc.cs.haifa.ac.il:~/folder/
```

### From DLC to Local
```bash
scp USERNAME@login01.dlc.cs.haifa.ac.il:~/file.txt .
scp -r USERNAME@login01.dlc.cs.haifa.ac.il:~/folder/ .
```

## Jupyter on DLC

### Start Jupyter in Interactive Job
```bash
srun --gpus=1 \
     --container-image=~/pytorch:23.12-py3.sqsh \
     --container-mounts=$HOME/fish_tracker:/workspace \
     --pty /bin/bash -c "
         pip install jupyterlab && \
         jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root
     "
```

### Access from Local Machine
On local machine, create SSH tunnel:
```bash
ssh -L 8888:localhost:8888 USERNAME@login01.dlc.cs.haifa.ac.il
```

Then open: http://localhost:8888

## Useful Commands Inside Container

### Check GPU Status
```bash
nvidia-smi
```

### Check Python/CUDA
```bash
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA: {torch.cuda.is_available()}')"
```

### Monitor GPU Usage
```bash
watch -n 1 nvidia-smi  # Update every 1 second
```

## Tips and Tricks

### Save Time with Aliases
Add to `~/.bashrc`:
```bash
alias gpu1='srun --gpus=1 --pty /bin/bash'
alias gpu2='srun --gpus=2 --pty /bin/bash'
alias myq='squeue -u $USER'
```

### Check Available Resources
```bash
sinfo -o "%20N %10c %10m %25f %10G"
```

### Multi-GPU Job
```bash
srun --gpus=2 \
     --container-image=~/pytorch:23.12-py3.sqsh \
     python multi_gpu_script.py
```

### Background Job Output
Monitor running job output:
```bash
tail -f job-name.JOB_ID.out
```

## Common Issues

### Container Not Found
Re-pull the container:
```bash
/dlc/sw/bin/pull_container_to_file.sh nvcr.io/nvidia/pytorch:23.12-py3
```

### Out of Memory
- Reduce batch size
- Use fewer GPUs
- Use smaller model

### Job Pending
Check why job is pending:
```bash
squeue -j JOB_ID --start
```

## Resources

- Login node: login01.dlc.cs.haifa.ac.il
- IP: 132.75.245.170
- NGC Catalog: https://catalog.ngc.nvidia.com/

## Support

Contact Haifa University IT support for DLC access and issues.
