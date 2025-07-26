# Magnifier Rotation Fix Documentation

## Problem
The magnifier in CameraColorPickerView.swift displayed rotated content (90° or 270°) in AR mode.

## Root Cause
The camera captures frames with `.right` orientation (UIImage.Orientation.right), and while the MagnifierView attempted to compensate by transforming coordinates, it still preserved the original image orientation when creating the cropped UIImage. This caused the magnified content to appear rotated.

## Solution
Changed line 232 in MagnifierView from:
```swift
let cropped = image.cgImage?.cropping(to: rect).map { UIImage(cgImage: $0, scale: image.scale, orientation: image.imageOrientation) } ?? image
```

To:
```swift
let cropped = image.cgImage?.cropping(to: rect).map { UIImage(cgImage: $0, scale: image.scale, orientation: .up) } ?? image
```

By forcing the orientation to `.up`, we normalize the cropped image regardless of the source image's orientation.

## Key Points to Remember
1. The camera always captures with `.right` orientation (see line 330)
2. The MagnifierView already handles coordinate transformation for AR mode (lines 220-227)
3. When creating cropped images for display, always normalize to `.up` orientation to avoid rotation issues
4. This fix was previously attempted in commit f95f129 but was later reverted

## Testing
- Test AR mode magnifier - should show content upright
- Test Photos mode magnifier - should maintain correct orientation
- Test with device in different physical orientations