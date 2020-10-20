//
//  SCCameraEngine.m
//  SCImagePickerController
//
//  Created by sichenwang on 2017/3/14.
//  Copyright © 2017年 higo. All rights reserved.
//

#import "SCCameraEngine.h"
#import "WCLRecordEncoder.h"
#import <AVFoundation/AVFoundation.h>

#define kOriginVideoURL [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Origin_Video.mp4"]
#define kCompressedVideoURL [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Compressed_Video.mp4"]

@interface SCCameraEngine() <AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate, CAAnimationDelegate>
{
    CMTime _timeOffset; //录制的偏移CMTime
    CMTime _lastVideo; //记录上一次视频数据文件的CMTime
    CMTime _lastAudio; //记录上一次音频数据文件的CMTime
    
    NSInteger _cx; //视频分辨的宽
    NSInteger _cy; //视频分辨的高
    int _channels; //音频通道
    Float64 _samplerate; //音频采样率
}

@property (nonatomic, strong) WCLRecordEncoder           *recordEncoder;//录制编码
@property (nonatomic, strong) AVCaptureSession           *recordSession;//捕获视频的会话
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;//捕获到的视频呈现的layer
@property (nonatomic, strong) AVCaptureDeviceInput       *backCameraInput;//后置摄像头输入
@property (nonatomic, strong) AVCaptureDeviceInput       *frontCameraInput;//前置摄像头输入
@property (nonatomic, strong) AVCaptureDeviceInput       *audioMicInput;//麦克风输入
@property (nonatomic, copy) dispatch_queue_t           captureQueue;//录制的队列
@property (nonatomic, strong) AVCaptureConnection        *audioConnection;//音频录制连接
@property (nonatomic, strong) AVCaptureConnection        *videoConnection;//视频录制连接
@property (nonatomic, strong) AVCaptureVideoDataOutput   *videoOutput;//视频输出
@property (nonatomic, strong) AVCaptureAudioDataOutput   *audioOutput;//音频输出
@property (nonatomic, assign) BOOL isCapturing;//正在录制
@property (nonatomic, assign) BOOL isPaused;//是否暂停
@property (nonatomic, assign) BOOL discont;//是否中断
@property (nonatomic, assign) CGFloat currentRecordTime;//当前录制时间

@property (nonatomic, strong) NSMutableArray *videoPaths;//分段录制视频的路径集合
@property (nonatomic, copy) NSString *videoPath;//合成后视频的路径

@end

NSString *const SCCameraEngineErrorDomain = @"SCCameraEngineErrorDomain";

@implementation SCCameraEngine

- (void)dealloc {
    [_recordSession stopRunning];
    _captureQueue     = nil;
    _recordSession    = nil;
    _previewLayer     = nil;
    _backCameraInput  = nil;
    _frontCameraInput = nil;
    _audioOutput      = nil;
    _videoOutput      = nil;
    _audioConnection  = nil;
    _videoConnection  = nil;
    _recordEncoder    = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxRecordTime = 5;
        _videoPaths = [NSMutableArray array];
        _videoPath = kOriginVideoURL;
    }
    return self;
}

#pragma mark - Public Method
//启动相机
- (void)startUp {
    [self.class requestCameraPermission:^(BOOL granted) {
        if (granted) {
            // request microphone permission if video is enabled
            [self.class requestMicrophonePermission:^(BOOL granted) {
                if (!granted) {
                    NSError *error = [NSError errorWithDomain:SCCameraEngineErrorDomain
                                                         code:SCCameraEngineErrorCodeMicrophonePermission
                                                     userInfo:nil];
                    [self passError:error];
                }
            }];
            
            NSLog(@"启动录制功能");
            self.startTime = CMTimeMake(0, 0);
            self.isCapturing = NO;
            self.isPaused = NO;
            self.discont = NO;
            [self.recordSession startRunning];
            
        } else {
            NSError *error = [NSError errorWithDomain:SCCameraEngineErrorDomain
                                                 code:SCCameraEngineErrorCodeCameraPermission
                                             userInfo:nil];
            [self passError:error];
        }
    }];
}
//关闭相机
- (void)shutdown {
    _startTime = CMTimeMake(0, 0);
    if (_recordSession) {
        [_recordSession stopRunning];
    }
    [_recordEncoder finishWithCompletionHandler:^{
        NSLog(@"关闭录制功能");
    }];
}

//开始录制
- (void)startCapture {
    @synchronized(self) {
        if (!self.isCapturing) {
            //设置录制路径
            [self configureVideoPath];
            self.isCapturing = YES;
            self.recordEncoder = nil;
            self.isPaused = NO;
            self.discont = NO;
            _timeOffset = CMTimeMake(0, 0);
            NSLog(@"开始录制");
            //清除缓存视频
            [self clearCache];
        }
    }
}
//暂停录制
- (void)pauseCapture {
    [self pauseCaptureWithCompletionHandler:nil];
}

- (void)pauseCaptureWithCompletionHandler:(void (^)(void))handler {
    @synchronized(self) {
        if (self.isCapturing) {
            self.isPaused = YES;
            self.discont = YES;
            dispatch_async(_captureQueue, ^{
                [self.recordEncoder finishWithCompletionHandler:^{
                    self.recordEncoder = nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (handler) {
                            handler();
                        }
                    });
                }];
            });
            NSLog(@"暂停录制");
        }
    }
}
//继续录制
- (void)resumeCapture {
    @synchronized(self) {
        if (self.isPaused) {
            //设置录制路径
            [self configureVideoPath];
            self.isPaused = NO;
            NSLog(@"继续录制");
        }
    }
}
//尝试停止录制
- (void)stopCaptureHandler:(void (^)(UIImage *movieImage, NSString *videoPath))handler {
    @synchronized(self) {
        if (self.isCapturing) {
            //已经暂停录制
            if (self.isPaused) {
                dispatch_async(_captureQueue, ^{
                    [self endCaptureHandler:handler];
                });
            }
            //还在录制中
            else {
                dispatch_async(_captureQueue, ^{
                    [self.recordEncoder finishWithCompletionHandler:^{
                        [self endCaptureHandler:handler];
                    }];
                });
                NSLog(@"暂停录制");
            }
        }
    }
}

//停止录制
- (void)endCaptureHandler:(void (^)(UIImage *movieImage, NSString *videoPath))handler {
    [self mergeAndExportVideos:self.videoPaths outputPath:self.videoPath completionHandler:^{
        //截取第一帧
        [self movieToImageHandler:handler];
    }];
    NSLog(@"停止录制");
}

// 清除缓存视频
- (void)clearCache {
    NSArray *videoNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"videos"] error:nil];
    for (NSString *videoName in videoNames) {
        NSString *videoPath = [[self getVideoCachePath] stringByAppendingPathComponent:videoName];
        [[NSFileManager defaultManager] removeItemAtPath:videoPath error:NULL];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:kOriginVideoURL]) {
        [[NSFileManager defaultManager] removeItemAtPath:kOriginVideoURL error:nil];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:kCompressedVideoURL]) {
        [[NSFileManager defaultManager] removeItemAtPath:kCompressedVideoURL error:nil];
    }
}

//设置新录制的路径
- (void)configureVideoPath {
    NSString *videoName = [self getUploadFile_type:@"video" fileType:@"mp4"];
    NSString *videoPath = [[self getVideoCachePath] stringByAppendingPathComponent:videoName];
    [self.videoPaths addObject:videoPath];
}

//获取视频第一帧的图片
- (void)movieToImageHandler:(void (^)(UIImage *movieImage, NSString *videoPath))handler {
    NSURL *url = [NSURL fileURLWithPath:self.videoPath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0, 60);
    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    AVAssetImageGeneratorCompletionHandler generatorHandler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *thumbImg = [UIImage imageWithCGImage:im];
            if (handler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(thumbImg, self.videoPath);
                });
            }
        }
    };
    [generator generateCGImagesAsynchronouslyForTimes:
    [NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:generatorHandler];
}

#pragma mark - set、get方法
//捕获视频的会话
- (AVCaptureSession *)recordSession {
    if (_recordSession == nil) {
        _recordSession = [[AVCaptureSession alloc] init];
        //添加后置摄像头的输出
        if ([_recordSession canAddInput:self.backCameraInput]) {
            [_recordSession addInput:self.backCameraInput];
        }
        //添加后置麦克风的输出
        if ([_recordSession canAddInput:self.audioMicInput]) {
            [_recordSession addInput:self.audioMicInput];
        }
        //添加视频输出
        if ([_recordSession canAddOutput:self.videoOutput]) {
            [_recordSession addOutput:self.videoOutput];
            //设置视频的分辨率
            _cx = 720;
            _cy = 1280;
        }
        //添加音频输出
        if ([_recordSession canAddOutput:self.audioOutput]) {
            [_recordSession addOutput:self.audioOutput];
        }
        //设置视频录制的方向
        self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    return _recordSession;
}

//后置摄像头输入
- (AVCaptureDeviceInput *)backCameraInput {
    if (_backCameraInput == nil) {
        NSError *error;
        _backCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
        if (error) {
            [self passError:error];
            NSLog(@"获取后置摄像头失败~");
        }
    }
    return _backCameraInput;
}

//前置摄像头输入
- (AVCaptureDeviceInput *)frontCameraInput {
    if (_frontCameraInput == nil) {
        NSError *error;
        _frontCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
        if (error) {
            [self passError:error];
            NSLog(@"获取前置摄像头失败~");
        }
    }
    return _frontCameraInput;
}

//麦克风输入
- (AVCaptureDeviceInput *)audioMicInput {
    if (_audioMicInput == nil) {
        AVCaptureDevice *mic = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        NSError *error;
        _audioMicInput = [AVCaptureDeviceInput deviceInputWithDevice:mic error:&error];
        if (error) {
            [self passError:error];
            NSLog(@"获取麦克风失败~");
        }
    }
    return _audioMicInput;
}

//视频输出
- (AVCaptureVideoDataOutput *)videoOutput {
    if (_videoOutput == nil) {
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_videoOutput setSampleBufferDelegate:self queue:self.captureQueue];
        NSDictionary* setcapSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                                        nil];
        _videoOutput.videoSettings = setcapSettings;
    }
    return _videoOutput;
}

//音频输出
- (AVCaptureAudioDataOutput *)audioOutput {
    if (_audioOutput == nil) {
        _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
        [_audioOutput setSampleBufferDelegate:self queue:self.captureQueue];
    }
    return _audioOutput;
}

//视频连接
- (AVCaptureConnection *)videoConnection {
    _videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    return _videoConnection;
}

//音频连接
- (AVCaptureConnection *)audioConnection {
    if (_audioConnection == nil) {
        _audioConnection = [self.audioOutput connectionWithMediaType:AVMediaTypeAudio];
    }
    return _audioConnection;
}

//捕获到的视频呈现的layer
- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (_previewLayer == nil) {
        //通过AVCaptureSession初始化
        AVCaptureVideoPreviewLayer *preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.recordSession];
        //设置比例为铺满全屏
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer = preview;
    }
    return _previewLayer;
}

//录制的队列
- (dispatch_queue_t)captureQueue {
    if (_captureQueue == nil) {
        _captureQueue = dispatch_queue_create("com.sichen.camera.capture", DISPATCH_QUEUE_SERIAL);
    }
    return _captureQueue;
}

- (CGFloat)videoMaxZoomFactor {
    return [self captureDevice].activeFormat.videoMaxZoomFactor;
}

#pragma mark - 切换动画
- (void)changeCameraAnimation {
    CATransition *changeAnimation = [CATransition animation];
    changeAnimation.delegate = self;
    changeAnimation.duration = 0.3;
    changeAnimation.type = @"oglFlip";
    changeAnimation.subtype = kCATransitionFromRight;
    changeAnimation.timingFunction = UIViewAnimationCurveEaseInOut;
    [self.previewLayer addAnimation:changeAnimation forKey:@"changeAnimation"];
}

- (void)animationDidStart:(CAAnimation *)anim {
    self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [self.recordSession startRunning];
}

#pragma mark - 视频相关

//对焦
- (void)focus:(CGPoint)point {
    if (self.isFront) {
        point = CGPointMake(point.y / self.previewLayer.bounds.size.height, point.x / self.previewLayer.bounds.size.width);
    } else {
        point = CGPointMake(point.y / self.previewLayer.bounds.size.height, 1 - point.x / self.previewLayer.bounds.size.width);
    }

    AVCaptureDevice *device = self.isFront ? [self frontCamera] : [self backCamera];
    // focus
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            [device unlockForConfiguration];
        } else {
            [self passError:error];
            NSLog(@"对焦失败");
        }
    }
    // exposure
    if (device.isExposurePointOfInterestSupported && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.exposurePointOfInterest = point;
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            [device unlockForConfiguration];
        } else {
            [self passError:error];
            NSLog(@"曝光失败");
        }
    }
}

//变焦
- (void)zoomChangeValue:(CGFloat)value {
    AVCaptureDevice *device = [self captureDevice];
    NSLog(@"正在变焦->%f", value);

    if (device) {
        NSError *error = nil;
        [device lockForConfiguration:&error];
        if (!error)
        {
            device.videoZoomFactor = value;
        } else
        {
            [self passError:error];
        }
        [device unlockForConfiguration];
    }
}

//返回前置摄像头
- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

//返回后置摄像头
- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}


//切换前后置摄像头
- (void)changeCameraInputDeviceisFront:(BOOL)isFront {
    _isFront = isFront;
    if (isFront) {
        [self.recordSession stopRunning];
        [self.recordSession removeInput:self.backCameraInput];
        if ([self.recordSession canAddInput:self.frontCameraInput]) {
            [self changeCameraAnimation];
            [self.recordSession addInput:self.frontCameraInput];
        }
    }else {
        [self.recordSession stopRunning];
        [self.recordSession removeInput:self.frontCameraInput];
        if ([self.recordSession canAddInput:self.backCameraInput]) {
            [self changeCameraAnimation];
            [self.recordSession addInput:self.backCameraInput];
        }
    }
}

- (BOOL)removeVideo {
    if (self.videoPaths.count) {
        BOOL result = [[NSFileManager defaultManager] removeItemAtPath:self.videoPaths.lastObject error:NULL];
        if (result) {
            [self.videoPaths removeLastObject];
        }
        return result;
    } else {
        return NO;
    }
}

//返回当前摄像头
- (AVCaptureDevice *)captureDevice {
    return [self cameraWithPosition:self.isFront ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack];
}

//用来返回是前置摄像头还是后置摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    //返回和视频录制相关的所有默认设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //遍历这些设备返回跟position相关的设备
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

//获得视频存放地址
- (NSString *)getVideoCachePath {
    NSString *videoCache = [NSTemporaryDirectory() stringByAppendingPathComponent:@"videos"] ;
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:videoCache isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:videoCache withIntermediateDirectories:YES attributes:nil error:nil];
    };
    return videoCache;
}

- (NSString *)getUploadFile_type:(NSString *)type fileType:(NSString *)fileType {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HHmmss"];
    NSDate * NowDate = [NSDate dateWithTimeIntervalSince1970:now];
    ;
    NSString * timeStr = [formatter stringFromDate:NowDate];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.%@",type,timeStr,fileType];
    return fileName;
}

- (void)passError:(NSError *)error {
    if (self.onError) {
        __weak typeof(self) weakSelf = self;
        self.onError(weakSelf, error);
    }
}

+ (void)requestCameraPermission:(void (^)(BOOL granted))completionBlock {
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            // return to main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(granted);
                }
            });
        }];
    } else {
        completionBlock(YES);
    }
}

+ (void)requestMicrophonePermission:(void (^)(BOOL granted))completionBlock {
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            // return to main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(granted);
                }
            });
        }];
    }
}

#pragma mark - 写入数据
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    BOOL isVideo = YES;
    @synchronized(self) {
        if (!self.isCapturing  || self.isPaused) {
            return;
        }
        if (captureOutput != self.videoOutput) {
            isVideo = NO;
        }
        //初始化编码器，当有音频和视频参数时创建编码器
        if ((self.recordEncoder == nil) && !isVideo) {
            CMFormatDescriptionRef fmt = CMSampleBufferGetFormatDescription(sampleBuffer);
            [self setAudioFormat:fmt];
            NSString *videoPath = self.videoPaths.lastObject;
            self.recordEncoder = [WCLRecordEncoder encoderForPath:videoPath Height:_cy width:_cx channels:_channels samples:_samplerate];
        }
        //判断是否中断录制过
        if (self.discont) {
            if (isVideo) {
                return;
            }
            self.discont = NO;
            // 计算暂停的时间
            CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            CMTime last = isVideo ? _lastVideo : _lastAudio;
            if (last.flags & kCMTimeFlags_Valid) {
                if (_timeOffset.flags & kCMTimeFlags_Valid) {
                    pts = CMTimeSubtract(pts, _timeOffset);
                }
                CMTime offset = CMTimeSubtract(pts, last);
                if (_timeOffset.value == 0) {
                    _timeOffset = offset;
                }else {
                    _timeOffset = CMTimeAdd(_timeOffset, offset);
                }
            }
            _lastVideo.flags = 0;
            _lastAudio.flags = 0;
        }
        // 增加sampleBuffer的引用计时,这样我们可以释放这个或修改这个数据，防止在修改时被释放
        CFRetain(sampleBuffer);
        if (_timeOffset.value > 0) {
            CFRelease(sampleBuffer);
            //根据得到的timeOffset调整
            sampleBuffer = [self adjustTime:sampleBuffer by:_timeOffset];
        }
        // 记录暂停上一次录制的时间
        CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        CMTime dur = CMSampleBufferGetDuration(sampleBuffer);
        if (dur.value > 0) {
            pts = CMTimeAdd(pts, dur);
        }
        if (isVideo) {
            _lastVideo = pts;
        }else {
            _lastAudio = pts;
        }
    }
    CMTime dur = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    if (self.startTime.value == 0) {
        self.startTime = dur;
    }
    CMTime sub = CMTimeSubtract(dur, self.startTime);
    self.currentRecordTime = CMTimeGetSeconds(sub);
    if (self.currentRecordTime > self.maxRecordTime) {
        if (self.currentRecordTime - self.maxRecordTime < 0.1) {
            if ([self.delegate respondsToSelector:@selector(recordProgress:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate recordProgress:self.currentRecordTime/self.maxRecordTime];
                });
            }
        }
        return;
    }
    if ([self.delegate respondsToSelector:@selector(recordProgress:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate recordProgress:self.currentRecordTime/self.maxRecordTime];
        });
    }
    // 进行数据编码
    [self.recordEncoder encodeFrame:sampleBuffer isVideo:isVideo];
    CFRelease(sampleBuffer);
}

//设置音频格式
- (void)setAudioFormat:(CMFormatDescriptionRef)fmt {
    const AudioStreamBasicDescription *asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fmt);
    _samplerate = asbd->mSampleRate;
    _channels = asbd->mChannelsPerFrame;
    
}

//调整媒体数据的时间
- (CMSampleBufferRef)adjustTime:(CMSampleBufferRef)sample by:(CMTime)offset {
    CMItemCount count;
    CMSampleBufferGetSampleTimingInfoArray(sample, 0, nil, &count);
    CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
    CMSampleBufferGetSampleTimingInfoArray(sample, count, pInfo, &count);
    for (CMItemCount i = 0; i < count; i++) {
        pInfo[i].decodeTimeStamp = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset);
        pInfo[i].presentationTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
    }
    CMSampleBufferRef sout;
    CMSampleBufferCreateCopyWithNewTiming(nil, sample, count, pInfo, &sout);
    free(pInfo);
    return sout;
}

//合并多个视频
- (void)mergeAndExportVideos:(NSArray <NSString *>*)videosPathArray outputPath:(NSString *)outputPath completionHandler:(void (^)(void))handler {
    if (videosPathArray.count == 0) {
        return;
    }
    NSLog(@"开始合成视频");
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime totalDuration = kCMTimeZero;
    for (int i = 0; i < videosPathArray.count; i++) {
        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:videosPathArray[i]]];
        NSError *erroraudio = nil;
        //获取AVAsset中的音频 或者视频
        AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        //向通道内加入音频或者视频
        BOOL ba = [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                      ofTrack:assetAudioTrack
                                       atTime:totalDuration
                                        error:&erroraudio];
        
        NSLog(@"erroraudio:%@%d", erroraudio, ba);
        NSError *errorVideo = nil;
        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
        BOOL bl = [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                      ofTrack:assetVideoTrack
                                       atTime:totalDuration
                                        error:&errorVideo];
        
        NSLog(@"errorVideo:%@%d",errorVideo,bl);
        totalDuration = CMTimeAdd(totalDuration, asset.duration);
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:outputPath error:NULL];
    }
    NSURL *mergeFileURL = [NSURL fileURLWithPath:outputPath];
    AVAssetExportSession *exporter = [AVAssetExportSession exportSessionWithAsset:mixComposition presetName:AVAssetExportPreset1280x720];
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"合成视频结束");
        if (handler) {
            handler();
        }
    }];
}

@end
