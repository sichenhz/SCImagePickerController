//
//  SCCameraViewController.m
//  SCImagePickerController
//
//  Created by sichenwang on 2016/11/23.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCCameraViewController.h"
#import "SCCameraController.h"
#import "ViewUtils.h"
#import "SCImagePickerController.h"
#import "SCImageClipViewController.h"

@interface SCCameraViewController ()

@property (nonatomic, weak) SCImagePickerController *picker;

@property (strong, nonatomic) SCCameraController *camera;
@property (strong, nonatomic) UILabel *errorLabel;
@property (strong, nonatomic) UIButton *snapButton;
@property (strong, nonatomic) UIButton *switchButton;
@property (strong, nonatomic) UIButton *flashButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *albumsButton;

@end

@implementation SCCameraViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Life Cycle

- (instancetype)initWithPicker:(SCImagePickerController *)picker {
    self.picker = picker;
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
        
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // ----- initialize camera -------- //
    
    // create camera vc
    self.camera = [[SCCameraController alloc] initWithQuality:AVCaptureSessionPresetHigh
                                                 position:LLCameraPositionRear
                                             videoEnabled:YES];
    
    // attach to a view controller
    [self.camera attachToViewController:self withFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    
    // read: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
    // you probably will want to set this to YES, if you are going view the image outside iOS.
    self.camera.fixOrientationAfterCapture = NO;
    
    // take the required actions on a device change
    __weak typeof(self) weakSelf = self;
    [self.camera setOnDeviceChange:^(SCCameraController *camera, AVCaptureDevice * device) {
        
        NSLog(@"Device changed.");
        
        // device changed, check if flash is available
        if([camera isFlashAvailable]) {
            weakSelf.flashButton.hidden = NO;
            
            if(camera.flash == LLCameraFlashOff) {
                weakSelf.flashButton.selected = NO;
            }
            else {
                weakSelf.flashButton.selected = YES;
            }
        }
        else {
            weakSelf.flashButton.hidden = YES;
        }
    }];
    
    [self.camera setOnError:^(SCCameraController *camera, NSError *error) {
        NSLog(@"Camera error: %@", error);
        
        if([error.domain isEqualToString:SCCameraViewControllerErrorDomain]) {
            if(error.code == LLSimpleCameraErrorCodeCameraPermission ||
               error.code == LLSimpleCameraErrorCodeMicrophonePermission) {
                
                if(weakSelf.errorLabel) {
                    [weakSelf.errorLabel removeFromSuperview];
                }
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
                label.text = @"We need permission for the camera.\nPlease go to your settings.";
                label.numberOfLines = 2;
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
                label.textColor = [UIColor whiteColor];
                label.textAlignment = NSTextAlignmentCenter;
                [label sizeToFit];
                label.center = CGPointMake(screenRect.size.width / 2.0f, screenRect.size.height / 2.0f);
                weakSelf.errorLabel = label;
                [weakSelf.view addSubview:weakSelf.errorLabel];
            }
        }
    }];
    
    // ----- camera buttons -------- //
    
    // snap button to capture image
    self.snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.snapButton.frame = CGRectMake(0, 0, 70.0f, 70.0f);
    self.snapButton.clipsToBounds = YES;
    self.snapButton.layer.cornerRadius = self.snapButton.width / 2.0f;
    self.snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.snapButton.layer.borderWidth = 2.0f;
    self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.snapButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.snapButton.layer.shouldRasterize = YES;
    [self.snapButton addTarget:self action:@selector(snapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.snapButton];
    
    // button to toggle flash
    self.flashButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.flashButton.frame = CGRectMake(0, 0, 16.0f + 20.0f, 24.0f + 20.0f);
    self.flashButton.tintColor = [UIColor whiteColor];
    [self.flashButton setImage:[UIImage imageNamed:[@"SCImagePickerController.bundle" stringByAppendingPathComponent:@"camera-flash.png"]] forState:UIControlStateNormal];
    self.flashButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    [self.flashButton addTarget:self action:@selector(flashButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.flashButton];
    
    if([SCCameraController isFrontCameraAvailable] && [SCCameraController isRearCameraAvailable]) {
        // button to toggle camera positions
        self.switchButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.switchButton.frame = CGRectMake(0, 0, 29.0f + 20.0f, 22.0f + 20.0f);
        self.switchButton.tintColor = [UIColor whiteColor];
        [self.switchButton setImage:[UIImage imageNamed:[@"SCImagePickerController.bundle" stringByAppendingPathComponent:@"camera-switch.png"]] forState:UIControlStateNormal];
        self.switchButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
        [self.switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.switchButton];
    }
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.frame = CGRectMake(20.0f, screenRect.size.height - 80.0f, 60.0f, 60.0f);
    [self.cancelButton setImage:[UIImage imageNamed:[@"SCImagePickerController.bundle" stringByAppendingPathComponent:@"cancel.png"]] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self.picker action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelButton];
    
    self.albumsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.albumsButton.frame = CGRectMake(screenRect.size.width - 80.0f, screenRect.size.height - 80.0f, 60.0f, 60.0f);
    [self.albumsButton setImage:[UIImage imageNamed:[@"SCImagePickerController.bundle" stringByAppendingPathComponent:@"photo_pics.png"]] forState:UIControlStateNormal];
    [self.albumsButton addTarget:self action:@selector(albumsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.albumsButton];
}

- (void)albumsButtonPressed:(UIButton *)button {
    
    if (self.picker.childViewControllers.count == 2) {
        [self removeFromParentViewController];
        [self.picker setNeedsStatusBarAppearanceUpdate];
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.view.frame;
            frame.origin.y = frame.size.height;
            self.view.frame = frame;
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
        }];
    } else {
        [self.picker.navigationController willMoveToParentViewController:self.picker];
        [self.picker.navigationController.view setFrame:self.picker.view.frame];
        __block CGRect frame = self.picker.navigationController.view.frame;
        frame.origin.y = frame.size.height;
        self.picker.navigationController.view.frame = frame;
        [UIView animateWithDuration:0.3 animations:^{
            frame.origin.y = 0;
            self.picker.navigationController.view.frame = frame;
        }];
        [self.picker.view addSubview:self.picker.navigationController.view];
        [self.picker addChildViewController:self.picker.navigationController];
        [self.picker setNeedsStatusBarAppearanceUpdate];
        [self.picker.navigationController didMoveToParentViewController:self];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // start the camera
    [self.camera start];
}

/* camera button methods */

- (void)switchButtonPressed:(UIButton *)button
{
    [self.camera togglePosition];
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)flashButtonPressed:(UIButton *)button
{
    if(self.camera.flash == LLCameraFlashOff) {
        BOOL done = [self.camera updateFlashMode:LLCameraFlashOn];
        if(done) {
            self.flashButton.selected = YES;
            self.flashButton.tintColor = [UIColor yellowColor];
        }
    }
    else {
        BOOL done = [self.camera updateFlashMode:LLCameraFlashOff];
        if(done) {
            self.flashButton.selected = NO;
            self.flashButton.tintColor = [UIColor whiteColor];
        }
    }
}

- (void)snapButtonPressed:(UIButton *)button
{
    __weak typeof(self) weakSelf = self;
    
    [self.camera capture:^(SCCameraController *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
        if (!error) {
            if (self.picker.allowsEditing) {
                SCImageClipViewController *controller = [[SCImageClipViewController alloc] initWithImage:image picker:self.picker];
                [controller willMoveToParentViewController:self.picker];
                [controller.view setFrame:self.picker.view.frame];
                [self.picker.view addSubview:controller.view];
                [self.picker addChildViewController:controller];
                [self.picker setNeedsStatusBarAppearanceUpdate];
                [camera didMoveToParentViewController:self];
            } else {
                if ([weakSelf.picker.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingImage:)]) {
                    [weakSelf.picker.delegate assetsPickerController:self.picker didFinishPickingImage:image];
                }
            }
        }
        else {
            NSLog(@"An error has occured: %@", error);
        }
    } exactSeenImage:YES];
}

/* other lifecycle methods */

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.camera.view.frame = self.view.contentBounds;
    
    self.snapButton.center = self.view.contentCenter;
    self.snapButton.bottom = self.view.height - 15.0f;
    
    self.flashButton.center = self.view.contentCenter;
    self.flashButton.top = 5.0f;
    
    self.switchButton.top = 5.0f;
    self.switchButton.right = self.view.width - 5.0f;
}

@end
