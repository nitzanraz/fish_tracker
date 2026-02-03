"""
Fish Tracker Module
Implements fish detection and tracking in video using computer vision.
"""

import cv2
import numpy as np
from collections import OrderedDict
from scipy.spatial import distance as dist


class CentroidTracker:
    """
    Tracker that uses centroid-based approach to track objects across frames.
    """
    
    def __init__(self, max_disappeared=50):
        """
        Initialize the centroid tracker.
        
        Args:
            max_disappeared: Maximum number of frames an object can disappear before being deregistered
        """
        self.next_object_id = 0
        self.objects = OrderedDict()
        self.disappeared = OrderedDict()
        self.max_disappeared = max_disappeared
        
    def register(self, centroid):
        """Register a new object with the next available ID."""
        self.objects[self.next_object_id] = centroid
        self.disappeared[self.next_object_id] = 0
        self.next_object_id += 1
        
    def deregister(self, object_id):
        """Deregister an object ID."""
        del self.objects[object_id]
        del self.disappeared[object_id]
        
    def update(self, rects):
        """
        Update tracker with new bounding boxes.
        
        Args:
            rects: List of bounding boxes in format (x, y, w, h)
            
        Returns:
            OrderedDict of tracked objects {id: centroid}
        """
        # If no detections, mark all as disappeared
        if len(rects) == 0:
            for object_id in list(self.disappeared.keys()):
                self.disappeared[object_id] += 1
                
                if self.disappeared[object_id] > self.max_disappeared:
                    self.deregister(object_id)
                    
            return self.objects
        
        # Initialize array of centroids for current frame
        input_centroids = np.zeros((len(rects), 2), dtype="int")
        
        # Calculate centroids from bounding boxes
        for (i, (x, y, w, h)) in enumerate(rects):
            cx = int(x + w / 2.0)
            cy = int(y + h / 2.0)
            input_centroids[i] = (cx, cy)
            
        # If no objects being tracked, register all
        if len(self.objects) == 0:
            for i in range(len(input_centroids)):
                self.register(input_centroids[i])
        else:
            # Match existing objects to new centroids
            object_ids = list(self.objects.keys())
            object_centroids = list(self.objects.values())
            
            # Compute distance between each pair of object centroids and input centroids
            D = dist.cdist(np.array(object_centroids), input_centroids)
            
            # Find smallest value in each row and sort by row indices
            rows = D.min(axis=1).argsort()
            
            # Find smallest value in each column and sort by column indices
            cols = D.argmin(axis=1)[rows]
            
            # Track which rows and columns we've examined
            used_rows = set()
            used_cols = set()
            
            # Loop over the combination of (row, column) index tuples
            for (row, col) in zip(rows, cols):
                if row in used_rows or col in used_cols:
                    continue
                    
                # Update centroid and reset disappeared counter
                object_id = object_ids[row]
                self.objects[object_id] = input_centroids[col]
                self.disappeared[object_id] = 0
                
                used_rows.add(row)
                used_cols.add(col)
                
            # Determine which centroids haven't been examined
            unused_rows = set(range(D.shape[0])).difference(used_rows)
            unused_cols = set(range(D.shape[1])).difference(used_cols)
            
            # Handle disappeared objects
            if D.shape[0] >= D.shape[1]:
                for row in unused_rows:
                    object_id = object_ids[row]
                    self.disappeared[object_id] += 1
                    
                    if self.disappeared[object_id] > self.max_disappeared:
                        self.deregister(object_id)
            else:
                # Register new objects
                for col in unused_cols:
                    self.register(input_centroids[col])
                    
        return self.objects


class FishTracker:
    """
    Main fish tracking class that combines detection and tracking.
    """
    
    def __init__(self, min_area=500, history=500, var_threshold=16, detect_shadows=False):
        """
        Initialize the fish tracker.
        
        Args:
            min_area: Minimum area for a detected object to be considered a fish
            history: Number of frames for background subtractor history
            var_threshold: Threshold for background subtractor
            detect_shadows: Whether to detect shadows
        """
        self.min_area = min_area
        self.bg_subtractor = cv2.createBackgroundSubtractorMOG2(
            history=history,
            varThreshold=var_threshold,
            detectShadows=detect_shadows
        )
        self.tracker = CentroidTracker(max_disappeared=50)
        
    def detect_fish(self, frame):
        """
        Detect fish in a frame using background subtraction.
        
        Args:
            frame: Input frame
            
        Returns:
            List of bounding boxes (x, y, w, h)
        """
        # Apply background subtraction
        fg_mask = self.bg_subtractor.apply(frame)
        
        # Apply morphological operations to reduce noise
        kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
        fg_mask = cv2.morphologyEx(fg_mask, cv2.MORPH_OPEN, kernel)
        fg_mask = cv2.morphologyEx(fg_mask, cv2.MORPH_CLOSE, kernel)
        
        # Find contours
        contours, _ = cv2.findContours(fg_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        # Filter contours by area and get bounding boxes
        rects = []
        for contour in contours:
            if cv2.contourArea(contour) < self.min_area:
                continue
            (x, y, w, h) = cv2.boundingRect(contour)
            rects.append((x, y, w, h))
            
        return rects
    
    def track(self, frame):
        """
        Track fish in a frame.
        
        Args:
            frame: Input frame
            
        Returns:
            Tuple of (objects, rects) where objects is a dictionary of tracked objects {id: centroid}
            and rects is a list of bounding boxes (x, y, w, h)
        """
        # Detect fish
        rects = self.detect_fish(frame)
        
        # Update tracker
        objects = self.tracker.update(rects)
        
        return objects, rects
    
    def draw_tracks(self, frame, objects, rects=None):
        """
        Draw tracking information on frame.
        
        Args:
            frame: Frame to draw on
            objects: Dictionary of tracked objects {id: centroid}
            rects: Optional list of bounding boxes to draw
            
        Returns:
            Frame with tracking visualization
        """
        output = frame.copy()
        
        # Draw bounding boxes if provided
        if rects is not None:
            for (x, y, w, h) in rects:
                cv2.rectangle(output, (x, y), (x + w, y + h), (0, 255, 0), 2)
        
        # Draw centroids and IDs
        for (object_id, centroid) in objects.items():
            text = f"Fish {object_id}"
            cv2.putText(output, text, (centroid[0] - 10, centroid[1] - 10),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
            cv2.circle(output, (centroid[0], centroid[1]), 4, (0, 255, 0), -1)
            
        return output
    
    def process_video(self, video_path, output_path=None, display=True):
        """
        Process a video file and track fish.
        
        Args:
            video_path: Path to input video
            output_path: Optional path to save output video
            display: Whether to display frames during processing
            
        Returns:
            Number of frames processed
        """
        cap = cv2.VideoCapture(video_path)
        
        if not cap.isOpened():
            raise ValueError(f"Could not open video file: {video_path}")
        
        # Get video properties
        fps = int(cap.get(cv2.CAP_PROP_FPS))
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        
        # Setup video writer if output path specified
        writer = None
        if output_path:
            fourcc = cv2.VideoWriter_fourcc(*'mp4v')
            writer = cv2.VideoWriter(output_path, fourcc, fps, (width, height))
        
        frame_count = 0
        
        try:
            while True:
                ret, frame = cap.read()
                if not ret:
                    break
                
                # Track fish
                objects, rects = self.track(frame)
                
                # Draw tracks
                output_frame = self.draw_tracks(frame, objects, rects)
                
                # Write frame if output specified
                if writer:
                    writer.write(output_frame)
                
                # Display frame if requested
                if display:
                    cv2.imshow('Fish Tracker', output_frame)
                    if cv2.waitKey(1) & 0xFF == ord('q'):
                        break
                
                frame_count += 1
                
        finally:
            cap.release()
            if writer:
                writer.release()
            if display:
                cv2.destroyAllWindows()
        
        return frame_count
