//
//  SCImagePickerController.m
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/20.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCImagePickerController.h"
#import "SCAlbumsViewController.h"
#import "SCImageClipViewController.h"
#import "SCCameraViewController.h"
#import "SCBadgeView.h"

@interface SCImagePickerController()

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, weak) SCCameraViewController *camera;
@property (nonatomic) BOOL statusBarHidden;

@end

@implementation SCImagePickerController
{
    BOOL _isPresenting;
}

- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Life Cycle

- (instancetype)init {
    if (self = [super init]) {
        _selectedAssets = [[NSMutableArray alloc] init];
        _mediaTypes = @[@(PHAssetMediaTypeImage)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.sourceType == SCImagePickerControllerSourceTypeCamera) {
        
        self.statusBarHidden = YES;
        
        SCCameraViewController *camera = [[SCCameraViewController alloc] initWithPicker:self];
        [camera willMoveToParentViewController:self];
        camera.view.frame = self.view.frame;
        [self.view addSubview:camera.view];
        [self addChildViewController:camera];
        [camera didMoveToParentViewController:self];

    } else {
        
        self.statusBarHidden = NO;

        [self.navigationController willMoveToParentViewController:self];
        self.navigationController.view.frame = self.view.frame;
        [self.view addSubview:self.navigationController.view];
        [self addChildViewController:self.navigationController];
        [self.navigationController didMoveToParentViewController:self];
        
    }
}

#pragma mark - Getter

- (UINavigationController *)navigationController {
    if (!_navigationController) {
        _navigationController = [[UINavigationController alloc] initWithRootViewController:[[SCAlbumsViewController alloc] initWithPicker:self]];
        _navigationController.navigationBar.barTintColor = [UIColor colorWithRed:71/255.0f green:71/255.0f blue:89/255.0f alpha:1.0f];
        _navigationController.navigationBar.tintColor = [UIColor whiteColor];
        _navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSForegroundColorAttributeName  :   [UIColor whiteColor],
                                                                    NSFontAttributeName             :   [UIFont systemFontOfSize:18]
                                                                    };
    }
    return _navigationController;
}

#pragma mark - Public Method

- (void)selectAsset:(PHAsset *)asset {
    [self.selectedAssets insertObject:asset atIndex:self.selectedAssets.count];
    if (self.allowsMultipleSelection) {
        [self updateDoneButton];
    } else {
        SCImageClipViewController *clip = [[SCImageClipViewController alloc] initWithImage:nil picker:self];
        if (!self.allowsEditing) clip.preview = YES;
        [self.navigationController pushViewController:clip animated:YES];
        [self updateStatusBarHidden:YES animation:YES];
    }
}

- (void)deselectAsset:(PHAsset *)asset {
    [self.selectedAssets removeObjectAtIndex:[self.selectedAssets indexOfObject:asset]];
    [self updateDoneButton];
}

- (void)presentAlbums {
    if (_isPresenting) {
        return;
    }
    _isPresenting = YES;
    if (self.childViewControllers.count == 2) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.camera.view.frame;
            frame.origin.y = frame.size.height;
            self.camera.view.frame = frame;
        } completion:^( BOOL finished) {
            [self.camera removeFromParentViewController];
            _isPresenting = NO;
        }];
        [self updateStatusBarHidden:NO animation:NO];
    } else {
        [self.navigationController willMoveToParentViewController:self];
        self.navigationController.view.frame = self.view.frame;
        CGRect frame = self.navigationController.view.frame;
        frame.origin.y = frame.size.height;
        self.navigationController.view.frame = frame;
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.navigationController.view.frame;
            frame.origin.y = 0;
            self.navigationController.view.frame = frame;
        } completion:^(BOOL finished) {
            _isPresenting = NO;
        }];
        [self.view addSubview:self.navigationController.view];
        [self addChildViewController:self.navigationController];
        [self.navigationController didMoveToParentViewController:self];
        [self updateStatusBarHidden:NO animation:NO];
    }
}

- (void)presentCamera {
    if (_isPresenting) {
        return;
    }
    _isPresenting = YES;
    if (self.childViewControllers.count == 2) {
        UINavigationController *nav = self.navigationController;
        [nav removeFromParentViewController];
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = nav.view.frame;
            frame.origin.y = frame.size.height;
            nav.view.frame = frame;
        } completion:^(BOOL finished) {
            [nav.view removeFromSuperview];
            _isPresenting = NO;
        }];
        [self updateStatusBarHidden:YES animation:NO];
    } else {
        SCCameraViewController *camera = [[SCCameraViewController alloc] initWithPicker:self];
        _camera = camera;
        [camera willMoveToParentViewController:self];
        camera.view.frame = self.view.frame;
        CGRect frame = camera.view.frame;
        frame.origin.y = frame.size.height;
        camera.view.frame = frame;
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = camera.view.frame;
            frame.origin.y = 0;
            camera.view.frame = frame;
        } completion:^(BOOL finished) {
            [self updateStatusBarHidden:YES animation:NO];
            _isPresenting = NO;
        }];
        [self.view addSubview:camera.view];
        [self addChildViewController:camera];
        [camera didMoveToParentViewController:self];
    }
}


- (void)updateStatusBarHidden:(BOOL)hidden animation:(BOOL)animation {
    self.statusBarHidden = hidden;
    if (animation) {
        [UIView animateWithDuration:0.3f animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    } else {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

#pragma mark - Private Method

- (void)finishPickingAssets {
    if ([self.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)]) {
        [self.delegate assetsPickerController:self didFinishPickingAssets:self.selectedAssets];
    }
}

- (void)finishPickingImage:(UIImage *)image {
    if ([self.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingImage:)]) {
        [self.delegate assetsPickerController:self didFinishPickingImage:image];
    }
}

- (void)cancel {
    if ([self.delegate respondsToSelector:@selector(assetsPickerControllerDidCancel:)]) {
        [self.delegate assetsPickerControllerDidCancel:self];
    }
}

- (void)updateDoneButton {
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        viewController.navigationItem.rightBarButtonItem.enabled = self.selectedAssets.count > 0;
        if (viewController.navigationItem.rightBarButtonItems.count > 1) {
            UIBarButtonItem *badgeButtonItem = viewController.navigationItem.rightBarButtonItems[1];
            SCBadgeView *badgeView = badgeButtonItem.customView;
            badgeView.number = self.selectedAssets.count;
        }
    }
}

@end
