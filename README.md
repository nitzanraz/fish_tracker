# Fish Tracker

A Python-based fish tracking system for video analysis using computer vision techniques.

## Features

- Real-time fish detection using background subtraction
- Multi-object tracking with centroid-based algorithm
- Automatic ID assignment and tracking across frames
- Support for video file input and output
- Configurable detection parameters
- Visual tracking display with bounding boxes and IDs

## Installation

1. Clone the repository:
```bash
git clone https://github.com/nitzanraz/fish_tracker.git
cd fish_tracker
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

## Usage

### Basic Usage

Track fish in a video file:
```bash
python track_fish.py input_video.mp4
```

### Save Output Video

Track fish and save the output with tracking visualization:
```bash
python track_fish.py input_video.mp4 --output tracked_output.mp4
```

### Advanced Options

```bash
python track_fish.py input_video.mp4 \
    --output tracked_output.mp4 \
    --min-area 500 \
    --history 500 \
    --var-threshold 16 \
    --no-display
```

**Options:**
- `--output, -o`: Path to save output video with tracking visualization
- `--min-area`: Minimum pixel area for fish detection (default: 500)
- `--history`: Number of frames for background model history (default: 500)
- `--var-threshold`: Variance threshold for background subtraction (default: 16)
- `--no-display`: Process without displaying video (useful for batch processing)

### Using as a Python Module

```python
from fish_tracker import FishTracker

# Create tracker instance
tracker = FishTracker(min_area=500)

# Process a video
frame_count = tracker.process_video(
    'input_video.mp4',
    output_path='output_video.mp4',
    display=True
)

print(f"Processed {frame_count} frames")
```

## How It Works

The fish tracker uses a two-stage approach:

1. **Detection**: Background subtraction (MOG2 algorithm) identifies moving objects in each frame
2. **Tracking**: A centroid-based tracker associates detections across frames, maintaining consistent IDs

### Detection Stage

- Uses Mixture of Gaussians (MOG2) background subtraction
- Applies morphological operations to reduce noise
- Filters detections by minimum area threshold
- Extracts bounding boxes for detected objects

### Tracking Stage

- Calculates centroids of detected objects
- Matches centroids across frames using distance minimization
- Maintains object IDs across frames
- Handles object disappearance and reappearance

## Testing

Run the test suite:
```bash
python -m pytest test_fish_tracker.py
```

Or using unittest:
```bash
python test_fish_tracker.py
```

## Requirements

- Python 3.6+
- OpenCV (opencv-python >= 4.5.0)
- NumPy (>= 1.19.0)
- SciPy (>= 1.5.0)

## Algorithm Details

### Centroid Tracking

The tracker maintains a registry of object IDs and their centroids. For each frame:

1. Compute centroids of all detections
2. Calculate distances between existing tracked objects and new detections
3. Associate detections to existing tracks using minimum distance matching
4. Register new objects for unmatched detections
5. Mark objects as disappeared if they have no matching detection
6. Deregister objects that have disappeared for too many consecutive frames

### Background Subtraction

The MOG2 background subtractor adapts to:
- Gradual lighting changes
- Small movements in the background
- Shadows (can be optionally detected)

## Limitations

- Works best with static camera setups
- Requires sufficient contrast between fish and background
- Performance depends on video quality and fish size
- May struggle with overlapping fish
- Requires GPU for real-time processing of high-resolution video

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the MIT License.