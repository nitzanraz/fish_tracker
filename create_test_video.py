#!/usr/bin/env python3
"""
Create a synthetic test video with moving objects to demonstrate fish tracking.
"""

import cv2
import numpy as np


def create_test_video(output_path='test_video.mp4', duration=5, fps=30):
    """
    Create a test video with moving circles simulating fish.
    
    Args:
        output_path: Path to save the test video
        duration: Duration in seconds
        fps: Frames per second
    """
    width, height = 640, 480
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    writer = cv2.VideoWriter(output_path, fourcc, fps, (width, height))
    
    num_frames = duration * fps
    
    # Fish properties
    fish1_start = (100, 240)
    fish2_start = (320, 100)
    fish3_start = (500, 350)
    
    for frame_num in range(num_frames):
        # Create blue background
        frame = np.full((height, width, 3), (200, 150, 100), dtype=np.uint8)
        
        # Calculate fish positions (moving in different patterns)
        # Fish 1: Moving right
        x1 = int(fish1_start[0] + frame_num * 2) % width
        y1 = fish1_start[1]
        
        # Fish 2: Moving diagonally
        x2 = int(fish2_start[0] + frame_num * 1.5) % width
        y2 = int(fish2_start[1] + frame_num * 1) % height
        
        # Fish 3: Moving in circle
        angle = frame_num * 0.1
        x3 = int(width / 2 + 150 * np.cos(angle))
        y3 = int(height / 2 + 100 * np.sin(angle))
        
        # Draw fish as circles with different colors
        cv2.circle(frame, (x1, y1), 15, (0, 255, 0), -1)  # Green fish
        cv2.circle(frame, (x2, y2), 20, (255, 0, 0), -1)  # Blue fish
        cv2.circle(frame, (x3, y3), 18, (0, 0, 255), -1)  # Red fish
        
        writer.write(frame)
    
    writer.release()
    print(f"Test video created: {output_path}")
    print(f"Duration: {duration}s, FPS: {fps}, Total frames: {num_frames}")


if __name__ == '__main__':
    create_test_video()
