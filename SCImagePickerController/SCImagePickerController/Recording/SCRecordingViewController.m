//
//  SCRecordingViewController.m
//  SCImagePickerController
//
//  Created by sichenwang on 2016/11/23.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCRecordingViewController.h"
#import "SCCameraEngine.h"
#import "SCSnapButton.h"
#import "SCProgressView.h"
#import "SCProgressTagView.h"
#import "SCTimeFormat.h"
#import "SCAlertView.h"

@interface SCRecordingViewController () <SCCameraEngineDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) SCCameraEngine *camera; // 相机引擎
@property (nonatomic, strong) UILabel *errorLabel; // 错误提示
@property (nonatomic, strong) UILabel *timeLabel; // 当前录制时长
@property (nonatomic, strong) SCProgressView *progressView; // 录制进度条
@property (nonatomic, strong) SCSnapButton *snapButton; // 录制按钮
@property (nonatomic, strong) UIButton *switchButton; // 切换相机按钮
@property (nonatomic, strong) UIButton *deleteButton; // 删除一段视频
@property (nonatomic, strong) UIButton *cancelButton; // 取消录制
@property (nonatomic, strong) UIButton *nextButton; // 完成录制
@property (nonatomic, strong) UIView *redPoint; // 录制状态提示红点

// focus
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture; // 对焦手势
@property (nonatomic, strong) CALayer *focusBoxLayer; // 对焦图层
@property (nonatomic, strong) CAAnimation *focusBoxAnimation; // 对焦动画

// zoom
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture; // 变焦手势
@property (nonatomic) CGFloat beginGestureScale; // 变焦前比例
@property (nonatomic) CGFloat effectiveScale; // 变焦后比例

@end

@implementation SCRecordingViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    [self attachCamera];
    [self attachButtons];
    [self attachProgressView];
    [self attachTimeLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseCapture) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseCapture) name:AVAudioSessionInterruptionNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.camera shutdown];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.camera previewLayer].frame = CGRectMake(0, 50, self.view.bounds.size.width, self.view.bounds.size.width);
    [self.view.layer insertSublayer:self.camera.previewLayer atIndex:0];
    [self.camera startUp];
}

- (void)dealloc {
    self.camera = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Method

- (void)attachProgressView {
    self.progressView = [[SCProgressView alloc] initWithFrame:CGRectMake(0, 50 + self.view.bounds.size.width + 2 + 1, self.view.bounds.size.width, 4) type:SCProgressTypeLine];
    self.progressView.strokeColor = [UIColor blackColor].CGColor;
    self.progressView.lineWidth = 4;
    [self.view addSubview:self.progressView];
}

- (void)attachTimeLabel {
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 50) / 2, 0, 50, 50)];
    self.timeLabel.text = @"00:00";
    self.timeLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    self.timeLabel.textColor = [UIColor blackColor];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.timeLabel];
    
    self.redPoint = [[UIView alloc] initWithFrame:CGRectMake(self.timeLabel.frame.origin.x - 10, 22, 6, 6)];
    self.redPoint.backgroundColor = [UIColor redColor];
    self.redPoint.layer.cornerRadius = 3;
    [self.view addSubview:self.redPoint];
}

- (void)attachCamera {
    
    _camera = [[SCCameraEngine alloc] init];
    _camera.delegate = self;
    
    [self initFoucs];
    [self initZoom];
    
    // take the required actions on a device change
    __weak typeof(self) weakSelf = self;
    
    [self.camera setOnError:^(SCCameraEngine *camera, NSError *error) {
        
        NSLog(@"Camera error: %@", error);
        
        if ([error.domain isEqualToString:SCCameraEngineErrorDomain]) {
            if (error.code == SCCameraEngineErrorCodeCameraPermission) {
                [weakSelf attachLabel:@"We need permission for the camera.\nPlease go to your settings."];
            } else if (error.code == SCCameraEngineErrorCodeMicrophonePermission) {
                [weakSelf attachLabel:@"We need permission for the microphone.\nPlease go to your settings."];
            }
            
            if (error.code == SCCameraEngineErrorCodeCameraPermission) {
                weakSelf.switchButton.enabled = NO;
                weakSelf.snapButton.userInteractionEnabled = NO;
            }
        }
    }];
}

- (void)attachLabel:(NSString *)text {
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    if (self.errorLabel) {
        [self.errorLabel removeFromSuperview];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = text;
    label.numberOfLines = 2;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
    label.textColor = [UIColor redColor];
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    label.center = CGPointMake(screenRect.size.width / 2.0f, screenRect.size.height / 2.0f);
    self.errorLabel = label;
    [self.view addSubview:self.errorLabel];
}

- (void)attachButtons {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    // cancel button
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.cancelButton.tintColor = [UIColor blackColor];
    self.cancelButton.frame = CGRectMake(0.0f, 0.0f, 56.5f, 50.0f);
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [self.cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelButton];
    
    // next button
    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.nextButton.tintColor = [UIColor blackColor];
    self.nextButton.frame = CGRectMake(self.view.bounds.size.width - 56.5f, 0.0f, 56.5f, 50.0f);
    [self.nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [self.nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.nextButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [self.nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextButton];
    
    // snap button
    CGFloat y = (screenRect.size.height - 50.0f - self.view.frame.size.width - 75.0f) / 2 + (50.0f + self.view.frame.size.width);
    self.snapButton = [[SCSnapButton alloc] initWithFrame:CGRectMake((screenRect.size.width - 75.0f) / 2, y, 75.0f, 75.0f)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(snapButtonTap:)];
    [self.snapButton addGestureRecognizer:tap];
    [self.view addSubview:self.snapButton];
    
    // switch button
    CGFloat averageGap = (((screenRect.size.width - self.snapButton.frame.size.width) / 2) - 60) / 2;
    CGFloat x = CGRectGetMaxX(self.snapButton.frame) + averageGap + 8;
    self.switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.switchButton.frame = CGRectMake(x, CGRectGetMidY(self.snapButton.frame) - 30.0f, 60.0f, 60.0f);
    [self.switchButton setImage:[UIImage imageNamed:[@"SCImagePickerController.bundle" stringByAppendingPathComponent:@"camera-switch.png"]] forState:UIControlStateNormal];
    self.switchButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    [self.switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.switchButton];
    
    // delete button
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deleteButton.frame = CGRectMake(0, screenRect.size.height, 60.0f, 30.0f);
    self.deleteButton.center = CGPointMake(screenRect.size.width / 2, self.deleteButton.center.y);
    [self.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    self.deleteButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    [self.deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.deleteButton];
}

- (CABasicAnimation *)opacityForever_Animation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];
    animation.autoreverses = YES;
    animation.duration = 0.5;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

#pragma mark - Action

// 删除上一段视频
- (void)deleteButtonPressed:(UIButton *)button {
    if (!self.progressView.subviews.count) {
        return;
    }
    SCProgressTagView *tagView = self.progressView.subviews.lastObject;
    // 二次确认是否删除
    if (!tagView.isSelected) {
        tagView.selected = YES;
    }
    // 删除一段视频
    else {
        [self.camera removeVideo];
        self.camera.startTime = CMTimeAdd(self.camera.startTime, CMTimeMake(60 * tagView.duration, 60));
        [tagView removeFromSuperview];
        CGFloat progress = 0;
        if (self.progressView.subviews.count) {
            SCProgressTagView *preTagView = self.progressView.subviews.lastObject;
            progress = preTagView.progress;
            self.timeLabel.text = preTagView.time;
        } else {
            // 隐藏删除按钮
            [self deleteButtonHidden:YES];
            // 显示切换镜头按钮
            self.switchButton.hidden = NO;
            self.timeLabel.text = @"00:00";
        }
        self.progressView.progress = progress;
    }
    button.selected = !button.isSelected;
}

// 切换摄像头
- (void)switchButtonPressed:(UIButton *)button {
    button.selected = !button.isSelected;
    [self.camera changeCameraInputDeviceisFront:button.isSelected];
}

// 取消按钮点击事件
- (void)cancel {
    SCAlertView *alertView = [SCAlertView alertViewWithTitle:@"放弃拍摄？" message:@"如果现在退出视频拍摄，你的视频将不会被保存。" style:SCAlertViewStyleAlert];
    [alertView addAction:[SCAlertAction actionWithTitle:@"保留" style:SCAlertActionStyleCancel handler:nil]];
    [alertView addAction:[SCAlertAction actionWithTitle:@"放弃" style:SCAlertActionStyleConfirm handler:^(SCAlertAction * _Nonnull action) {
        if ([self.delegate respondsToSelector:@selector(assetsPickerControllerDidCancel:)]) {
            [self.delegate assetsPickerControllerDidCancel:self];
        }
    }]];
    [alertView show];
}

// 下一步按钮点击事件
- (void)next {
    [self stopCapture];
}

// 录制按钮点击事件
- (void)snapButtonTap:(UITapGestureRecognizer *)tap {
    [self recordAction:(SCSnapButton *)tap.view];
}

// 开始、暂停、继续录制点击事件
- (void)recordAction:(SCSnapButton *)sender {
    // 已录至最大长度
    if (self.progressView.progress >= 1) {
        [self resetTagView];
        return;
    }
    
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        if (self.camera.isCapturing) {
            [self resumeCapture];
        } else {
            [self startCapture];
        }
    } else {
        [self pauseCapture];
    }
}

// 开始录制
- (void)startCapture {
    // 开始录制
    [self.camera startCapture];
    // 开启闪烁红点动画
    [self.redPoint.layer addAnimation:[self opacityForever_Animation] forKey:nil];
    // 隐藏切换镜头按钮
    self.switchButton.hidden = YES;
}

// 暂停录制，包括（手动点击暂停、点击下一步、录满最大时长、接入电话、切换到后台）
- (void)pauseCapture {
    [self pauseCaptureWithCompletionHandler:nil];
}

- (void)pauseCaptureWithCompletionHandler:(void (^)(void))handler {
    // 暂停录制
    [self.camera pauseCaptureWithCompletionHandler:handler];
    // 暂停闪烁红点动画
    [self.redPoint.layer removeAllAnimations];
    
    // 添加tagView
    CGFloat x = 0;
    if (self.progressView.subviews.count) {
        x = CGRectGetMaxX(self.progressView.subviews.lastObject.frame);
    }
    SCProgressTagView *tagView = [[SCProgressTagView alloc] initWithFrame:CGRectMake(x, -2, [UIScreen mainScreen].bounds.size.width * self.progressView.progress + 0.5 - x, self.progressView.frame.size.height)];
    tagView.progress = self.progressView.progress;
    tagView.time = self.timeLabel.text;
    tagView.duration = (tagView.frame.size.width / self.progressView.frame.size.width) * self.camera.maxRecordTime;
    [self.progressView addSubview:tagView];
    
    // 显示删除按钮
    [self deleteButtonHidden:NO];
    // 重置删除按钮状态
    self.deleteButton.selected = NO;
    // 重置录制按钮状态
    self.snapButton.selected = NO;
}

// 继续录制
- (void)resumeCapture {
    // 继续录制
    [self.camera resumeCapture];
    // 开启闪烁红点动画
    [self.redPoint.layer addAnimation:[self opacityForever_Animation] forKey:nil];
    // 重置上一段视频状态
    [self resetTagView];
    // 隐藏删除按钮
    [self deleteButtonHidden:YES];
    // 隐藏切换镜头按钮
    if (!self.progressView.subviews.count) {
        self.switchButton.hidden = YES;
    }
}

// 录制成功，包括暂停录制+合成视频+回调
- (void)stopCapture {
    if (!self.camera.isCapturing) {
        return;
    }
    if (!self.camera.isPaused) {
        // 暂停录制
        [self pauseCaptureWithCompletionHandler:^{
            [self exportVideo];
        }];
    } else {
        [self exportVideo];
    }
}

// 导出视频
- (void)exportVideo {
    [self.camera stopCaptureHandler:^(UIImage *movieImage, NSString *videoPath) {
        if ([self.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingVideoUrl:)]) {
            [self.delegate assetsPickerController:self didFinishPickingVideoUrl:[NSURL fileURLWithPath:videoPath]];
        }

        // 保存视频至相册
        UISaveVideoAtPathToSavedPhotosAlbum(videoPath, nil, nil, nil);
    }];
}

// 重置上一段视频tagView状态
- (void)resetTagView {
    if (self.progressView.subviews.count) {
        SCProgressTagView *tagView = self.progressView.subviews.lastObject;
        tagView.selected = NO;
        self.deleteButton.selected = NO;
    }
}

- (void)deleteButtonHidden:(BOOL)hidden {
    if (hidden) {
        __block CGRect frame = self.deleteButton.frame;
        [UIView animateWithDuration:0.3 animations:^{
            frame.origin.y = [UIScreen mainScreen].bounds.size.height;
            self.deleteButton.frame = frame;
        }];
    } else {
        __block CGRect frame = self.deleteButton.frame;
        [UIView animateWithDuration:0.3 animations:^{
            frame.origin.y = [UIScreen mainScreen].bounds.size.height - 40.0f;
            self.deleteButton.frame = frame;
        }];
    }
}

#pragma mark - Focus

- (void)initFoucs {
    CALayer *focusBox = [[CALayer alloc] init];
    focusBox.cornerRadius = 5.0f;
    focusBox.bounds = CGRectMake(0.0f, 0.0f, 70, 60);
    focusBox.borderWidth = 3.0f;
    focusBox.borderColor = [[UIColor yellowColor] CGColor];
    focusBox.opacity = 0.0f;
    [self.camera.previewLayer addSublayer:focusBox];
    
    CABasicAnimation *focusBoxAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    focusBoxAnimation.duration = 0.75;
    focusBoxAnimation.autoreverses = NO;
    focusBoxAnimation.repeatCount = 0.0;
    focusBoxAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    focusBoxAnimation.toValue = [NSNumber numberWithFloat:0.0];
    
    self.focusBoxLayer = focusBox;
    self.focusBoxAnimation = focusBoxAnimation;
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTapped:)];
    self.tapGesture.numberOfTapsRequired = 1;
    [self.tapGesture setDelaysTouchesEnded:NO];
    [self.view addGestureRecognizer:self.tapGesture];
}

- (void)previewTapped:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.view];
    point = CGPointMake(point.x, point.y - self.camera.previewLayer.frame.origin.y);
    [self showFocusBox:point];
    [self.camera focus:point];
}

- (void)showFocusBox:(CGPoint)point {
    if (self.focusBoxLayer) {
        // clear animations
        [self.focusBoxLayer removeAllAnimations];
        
        // move layer to the touch point
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        self.focusBoxLayer.position = point;
        [CATransaction commit];
    }
    
    if (self.focusBoxAnimation) {
        // run the animation
        [self.focusBoxLayer addAnimation:self.focusBoxAnimation forKey:@"animateOpacity"];
    }
}

#pragma mark - Zoom

- (void)initZoom {
    self.effectiveScale = 1.0f;
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    self.pinchGesture.delegate = self;
    [self.view addGestureRecognizer:self.pinchGesture];
}


- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer {
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for (i = 0; i < numTouches; ++i) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.view];
        CGPoint convertedLocation = [self.camera.previewLayer convertPoint:location fromLayer:self.camera.previewLayer];
        if (![self.camera.previewLayer containsPoint:convertedLocation]) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if (allTouchesAreOnThePreviewLayer) {
        self.effectiveScale = self.beginGestureScale * recognizer.scale;
        if (self.effectiveScale < 1.0f) {
            self.effectiveScale = 1.0f;
        }
        if (self.effectiveScale > self.camera.videoMaxZoomFactor) {
            self.effectiveScale = self.camera.videoMaxZoomFactor;
        }
        [self.camera zoomChangeValue:self.effectiveScale];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        self.beginGestureScale = self.effectiveScale;
    }
    return YES;
}

#pragma mark - SCCameraEngineDelegate

- (void)recordProgress:(CGFloat)progress {
    self.progressView.progress = progress;
    NSLog(@"当前录制进度%f", progress);
    // 更新当前录制时间
    self.timeLabel.text = [SCTimeFormat formatSeconds:floor(self.progressView.progress * self.camera.maxRecordTime)];
    
    // 录制到最大长度，结束录制
    if (self.progressView.progress >= 1) {
        [self pauseCapture];
    }
}

@end
