//
//  SCCameraController.h
//  SCImagePickerController
//
//  Created by sichenwang on 2016/11/24.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

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


// Triggered on device change.
@property (nonatomic, copy) void (^onDeviceChange)(SCCameraController *camera, AVCaptureDevice *device);

// Triggered on any kind of error.
@property (nonatomic, copy) void (^onError)(SCCameraController *camera, NSError *error);

// Camera quality, set a constants prefixed with AVCaptureSessionPreset.
// Make sure to call before calling -(void)initialize method, otherwise it would be late.
@property (nonatomic, copy) NSString *cameraQuality;

// Camera flash mode.
@property (nonatomic, readonly) SCCameraFlash flash;

// Position of the camera.
@property (nonatomic) SCCameraPosition position;

// White balance mode. Default is: AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance
@property (nonatomic) AVCaptureWhiteBalanceMode whiteBalanceMode;

/**
 * Boolean value to indicate if zooming is enabled.
 */
@property (nonatomic, getter=isZoomingEnabled) BOOL zoomingEnabled;

/**
 * Float value to set maximum scaling factor
 */
@property (nonatomic, assign) CGFloat maxScale;

/**
 * Fixess the orientation after the image is captured is set to Yes.
 * see: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
 */
@property (nonatomic) BOOL fixOrientationAfterCapture;

/**
 * Set NO if you don't want ot enable user triggered focusing. Enabled by default.
 */
@property (nonatomic) BOOL tapToFocus;

/**
 * Set YES if you your view controller does not allow autorotation,
 * however you want to take the device rotation into account no matter what. Disabled by default.
 */
@property (nonatomic) BOOL useDeviceOrientation;

/**
 * Returns an instance of LLSimpleCamera with the given quality.
 * Quality parameter could be any variable starting with AVCaptureSessionPreset.
 */
- (instancetype)initWithQuality:(NSString *)quality position:(SCCameraPosition)position;

// Attaches the camera to another view controller with a frame.
- (void)attachToViewController:(UIViewController *)vc frame:(CGRect)frame;

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

// Checks if torch (flash for video) is avilable for the currently active device.
- (BOOL)isTorchAvailable;

/**
 * Alter the layer and the animation displayed when the user taps on screen.
 * @param layer Layer to be displayed
 * @param animation to be applied after the layer is shown
 */
- (void)alterFocusBox:(CALayer *)layer animation:(CAAnimation *)animation;

/**
 * Checks is the front camera is available.
 */
+ (BOOL)isFrontCameraAvailable;

/**
 * Checks is the rear camera is available.
 */
+ (BOOL)isRearCameraAvailable;

@end
