#!/usr/bin/env python3
"""
Example demonstrating programmatic usage of the fish tracker API.
"""

from fish_tracker import FishTracker
import cv2


def example_basic_tracking():
    """Example: Basic fish tracking with default parameters."""
    print("Example 1: Basic tracking")
    tracker = FishTracker()
    frame_count = tracker.process_video(
        'test_video.mp4',
        output_path='output_basic.mp4',
        display=False
    )
    print(f"Processed {frame_count} frames\n")


def example_custom_parameters():
    """Example: Custom detection parameters."""
    print("Example 2: Custom parameters")
    tracker = FishTracker(
        min_area=200,       # Smaller fish detection
        history=300,        # Shorter background history
        var_threshold=25    # Higher variance threshold
    )
    frame_count = tracker.process_video(
        'test_video.mp4',
        output_path='output_custom.mp4',
        display=False
    )
    print(f"Processed {frame_count} frames\n")


def example_frame_by_frame():
    """Example: Frame-by-frame processing with custom logic."""
    print("Example 3: Frame-by-frame processing")
    tracker = FishTracker(min_area=200)
    cap = cv2.VideoCapture('test_video.mp4')
    
    frame_count = 0
    total_fish = 0
    
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        
        # Track fish in frame
        objects, rects = tracker.track(frame)
        
        # Custom logic: count total unique fish
        if len(objects) > total_fish:
            total_fish = len(objects)
        
        frame_count += 1
    
    cap.release()
    print(f"Processed {frame_count} frames")
    print(f"Maximum fish detected simultaneously: {total_fish}\n")


def example_with_visualization():
    """Example: Custom visualization."""
    print("Example 4: Custom visualization")
    tracker = FishTracker(min_area=200)
    cap = cv2.VideoCapture('test_video.mp4')
    
    frame_count = 0
    
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        
        # Track fish
        objects, rects = tracker.track(frame)
        
        # Custom visualization
        output = tracker.draw_tracks(frame, objects, rects)
        
        # Add custom text
        text = f"Frame: {frame_count} | Fish: {len(objects)}"
        cv2.putText(output, text, (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 
                   1, (255, 255, 255), 2)
        
        frame_count += 1
    
    cap.release()
    print(f"Processed {frame_count} frames with custom visualization\n")


if __name__ == '__main__':
    print("Fish Tracker API Examples\n" + "=" * 50 + "\n")
    
    example_basic_tracking()
    example_custom_parameters()
    example_frame_by_frame()
    example_with_visualization()
    
    print("=" * 50)
    print("All examples completed successfully!")
