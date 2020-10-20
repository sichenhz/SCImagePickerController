//
//  SCCameraEngine.h
//  SCImagePickerController
//
//  Created by sichenwang on 2017/3/14.
//  Copyright © 2017年 higo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVCaptureVideoPreviewLayer.h>

@protocol SCCameraEngineDelegate <NSObject>

- (void)recordProgress:(CGFloat)progress;

@end

extern NSString *const SCCameraEngineErrorDomain;
typedef NS_ENUM(NSInteger, SCCameraEngineErrorCode) {
    SCCameraEngineErrorCodeCameraPermission = 10,
    SCCameraEngineErrorCodeMicrophonePermission = 11,
};

@interface SCCameraEngine : NSObject

@property (nonatomic, assign) CMTime startTime;//开始录制的时间
@property (nonatomic, assign, readonly) BOOL isCapturing; //正在录制
@property (nonatomic, assign, readonly) BOOL isPaused; //是否暂停
@property (nonatomic, assign, readonly) CGFloat currentRecordTime; //当前录制时间
@property (nonatomic, assign, readonly) BOOL isFront; //是否前置摄像头
@property (nonatomic, assign) CGFloat maxRecordTime; //录制最长时间
@property (nonatomic, assign) CGFloat videoMaxZoomFactor; //最大变焦倍数
@property (nonatomic, weak) id<SCCameraEngineDelegate>delegate;

// Triggered on any kind of error.
@property (nonatomic, copy) void (^onError)(SCCameraEngine *camera, NSError *error);

//捕获到的视频呈现的layer
- (AVCaptureVideoPreviewLayer *)previewLayer;

//启动相机
- (void)startUp;
//关闭相机
- (void)shutdown;

//开始录制
- (void)startCapture;
//暂停录制（每暂停一次就写成一个视频，用handler回调）
- (void)pauseCapture;
- (void)pauseCaptureWithCompletionHandler:(void (^)(void))handler;
//继续录制
- (void)resumeCapture;
//停止录制
- (void)stopCaptureHandler:(void (^)(UIImage *movieImage, NSString *videoPath))handler;
//对焦
- (void)focus:(CGPoint)point;
//变焦
- (void)zoomChangeValue:(CGFloat)value;

//切换前后置摄像头
- (void)changeCameraInputDeviceisFront:(BOOL)isFront;

//删除一段视频
- (BOOL)removeVideo;

@end
