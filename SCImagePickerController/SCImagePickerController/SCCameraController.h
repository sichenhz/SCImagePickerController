//
//  SCCameraController.h
//  SCImagePickerController
//
//  Created by sichenwang on 2016/11/24.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

@import UIKit;
@import AVFoundation;

typedef NS_ENUM(NSInteger, SCCameraPosition) {
    SCCameraPositionRear,
    SCCameraPositionFront
};

typedef NS_ENUM(NSInteger, SCCameraFlash) {
    SCCameraFlashOff,
    SCCameraFlashOn,
    SCCameraFlashAuto
};

extern NSString *const SCCameraErrorDomain;
typedef NS_ENUM(NSInteger, SCCameraErrorCode) {
    SCCameraErrorCodeCameraPermission = 10,
    SCCameraErrorCodeMicrophonePermission = 11,
    SCCameraErrorCodeSession = 12,
    SCCameraErrorCodeVideoNotEnabled = 13
};

@interface SCCameraController : UIViewController

// Default is: SCCameraPositionFront
@property (nonatomic, readonly) SCCameraFlash flash;
// Default is: SCCameraFlashOff
@property (nonatomic, readonly) SCCameraPosition position;

// Call this method if you want to customize flash and position.
- (instancetype)initWithFlash:(SCCameraFlash)flash position:(SCCameraPosition)position;

// Default is: AVCaptureSessionPresetHigh.
// Make sure to call before calling - (void)start method, otherwise it would be late.
@property (nonatomic, copy) NSString *quality;
// Default is YES.
@property (nonatomic) BOOL tapToFocus;
// Default is YES.
@property (nonatomic, getter=isZoomingEnabled) BOOL zoomingEnabled;
// Fixess the orientation after the image is captured is set to Yes.
// see: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
@property (nonatomic) BOOL fixOrientationAfterCapture;

// Triggered on device change.
@property (nonatomic, copy) void (^onDeviceChange)(SCCameraController *camera, AVCaptureDevice *device);
// Triggered on any kind of error.
@property (nonatomic, copy) void (^onError)(SCCameraController *camera, NSError *error);

// Starts running the camera session.
- (void)start;
// Stops the running camera session. Needs to be called when the app doesn't show the view.
- (void)stop;

// Capture an image.
// exactSeenImage If set YES, then the image is cropped to the exact size as the preview. So you get exactly what you see.
// animationBlock you can create your own animation by playing with preview layer.
- (void)capture:(void (^)(SCCameraController *camera, UIImage *image, NSDictionary *metadata, NSError *error))onCapture exactSeenImage:(BOOL)exactSeenImage animationBlock:(void (^)(AVCaptureVideoPreviewLayer *))animationBlock;
- (void)capture:(void (^)(SCCameraController *camera, UIImage *image, NSDictionary *metadata, NSError *error))onCapture exactSeenImage:(BOOL)exactSeenImage;
- (void)capture:(void (^)(SCCameraController *camera, UIImage *image, NSDictionary *metadata, NSError *error))onCapture;

// Changes the posiition of the camera (either back or front) and returns the final position.
- (SCCameraPosition)togglePosition;
// Update the flash mode of the camera. Returns true if it is successful. Otherwise false.
- (BOOL)updateFlashMode:(SCCameraFlash)cameraFlash;

// Checks if flash is avilable for the currently active device.
- (BOOL)isFlashAvailable;
// Checks is the front camera is available.
+ (BOOL)isFrontCameraAvailable;
// Checks is the rear camera is available.
+ (BOOL)isRearCameraAvailable;

@end
