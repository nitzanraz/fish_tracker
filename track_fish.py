#!/usr/bin/env python3
"""
Example script demonstrating fish tracking in video.
"""

import argparse
import sys
from fish_tracker import FishTracker


def main():
    """Main function to run fish tracking demo."""
    parser = argparse.ArgumentParser(description='Track fish in video')
    parser.add_argument('video', help='Path to input video file')
    parser.add_argument('--output', '-o', help='Path to output video file')
    parser.add_argument('--min-area', type=int, default=500,
                       help='Minimum area for fish detection (default: 500)')
    parser.add_argument('--no-display', action='store_true',
                       help='Do not display video during processing')
    parser.add_argument('--history', type=int, default=500,
                       help='Background subtractor history length (default: 500)')
    parser.add_argument('--var-threshold', type=int, default=16,
                       help='Background subtractor variance threshold (default: 16)')
    
    args = parser.parse_args()
    
    # Create tracker
    tracker = FishTracker(
        min_area=args.min_area,
        history=args.history,
        var_threshold=args.var_threshold
    )
    
    # Process video
    print(f"Processing video: {args.video}")
    try:
        frame_count = tracker.process_video(
            args.video,
            output_path=args.output,
            display=not args.no_display
        )
        print(f"Processed {frame_count} frames")
        if args.output:
            print(f"Output saved to: {args.output}")
    except Exception as e:
        print(f"Error processing video: {e}", file=sys.stderr)
        return 1
    
    return 0


if __name__ == '__main__':
    sys.exit(main())
