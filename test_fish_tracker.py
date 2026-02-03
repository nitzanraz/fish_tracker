"""
Tests for fish tracker module.
"""

import unittest
import numpy as np
import cv2
from fish_tracker import CentroidTracker, FishTracker


class TestCentroidTracker(unittest.TestCase):
    """Test cases for CentroidTracker class."""
    
    def test_initialization(self):
        """Test tracker initialization."""
        tracker = CentroidTracker()
        self.assertEqual(tracker.next_object_id, 0)
        self.assertEqual(len(tracker.objects), 0)
        
    def test_register_object(self):
        """Test registering a new object."""
        tracker = CentroidTracker()
        centroid = (100, 100)
        tracker.register(centroid)
        self.assertEqual(len(tracker.objects), 1)
        self.assertEqual(tracker.objects[0], centroid)
        
    def test_update_with_no_detections(self):
        """Test update with no detections."""
        tracker = CentroidTracker(max_disappeared=2)
        tracker.register((100, 100))
        
        # First update with no detections
        objects = tracker.update([])
        self.assertEqual(len(objects), 1)
        
        # Second update with no detections
        objects = tracker.update([])
        self.assertEqual(len(objects), 1)
        
        # Third update should deregister
        objects = tracker.update([])
        self.assertEqual(len(objects), 0)
        
    def test_update_with_new_detection(self):
        """Test update with new detection."""
        tracker = CentroidTracker()
        rect = [(10, 10, 20, 20)]
        objects = tracker.update(rect)
        self.assertEqual(len(objects), 1)


class TestFishTracker(unittest.TestCase):
    """Test cases for FishTracker class."""
    
    def test_initialization(self):
        """Test tracker initialization."""
        tracker = FishTracker(min_area=500)
        self.assertEqual(tracker.min_area, 500)
        self.assertIsNotNone(tracker.bg_subtractor)
        self.assertIsNotNone(tracker.tracker)
        
    def test_detect_fish_empty_frame(self):
        """Test detection on empty frame."""
        tracker = FishTracker()
        # Create a blank frame
        frame = np.zeros((480, 640, 3), dtype=np.uint8)
        rects = tracker.detect_fish(frame)
        # First few frames might not detect anything due to background learning
        self.assertIsInstance(rects, list)
        
    def test_detect_fish_with_object(self):
        """Test detection with moving object."""
        tracker = FishTracker(min_area=100)
        
        # Train background with black frames
        for _ in range(10):
            frame = np.zeros((480, 640, 3), dtype=np.uint8)
            tracker.detect_fish(frame)
        
        # Create frame with white rectangle (simulating fish)
        frame = np.zeros((480, 640, 3), dtype=np.uint8)
        cv2.rectangle(frame, (200, 200), (300, 250), (255, 255, 255), -1)
        
        rects = tracker.detect_fish(frame)
        # Should detect the rectangle as foreground
        self.assertGreater(len(rects), 0)
        
    def test_track(self):
        """Test tracking function."""
        tracker = FishTracker()
        frame = np.zeros((480, 640, 3), dtype=np.uint8)
        objects, rects = tracker.track(frame)
        self.assertIsInstance(objects, dict)
        self.assertIsInstance(rects, list)
        
    def test_draw_tracks(self):
        """Test drawing tracks on frame."""
        tracker = FishTracker()
        frame = np.zeros((480, 640, 3), dtype=np.uint8)
        objects = {0: (100, 100), 1: (200, 200)}
        rects = [(90, 90, 20, 20), (190, 190, 20, 20)]
        
        output = tracker.draw_tracks(frame, objects, rects)
        self.assertEqual(output.shape, frame.shape)
        # Output should be different from input (since we drew on it)
        self.assertFalse(np.array_equal(output, frame))


if __name__ == '__main__':
    unittest.main()
