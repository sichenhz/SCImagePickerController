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

@end

@implementation SCImagePickerController

- (BOOL)prefersStatusBarHidden {
    UIViewController *lastController = self.childViewControllers.lastObject;
    if ([lastController isKindOfClass:[SCImageClipViewController class]] ||
        [lastController isKindOfClass:[SCCameraViewController class]]) {
        return YES;
    } else if (([lastController isKindOfClass:[UINavigationController class]] &&
                [[(UINavigationController *)lastController topViewController] isKindOfClass:[SCImageClipViewController class]])) {
        return YES;
    } else {
        return NO;
    }
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
        
        SCCameraViewController *camera = [[SCCameraViewController alloc] initWithPicker:self];
        [camera willMoveToParentViewController:self];
        [camera.view setFrame:self.view.frame];
        [self.view addSubview:camera.view];
        [self addChildViewController:camera];
        [camera didMoveToParentViewController:self];

    } else {
        
        [self.navigationController willMoveToParentViewController:self];
        [self.navigationController.view setFrame:self.view.frame];
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
        if (self.allowsEditing) {
            SCImageClipViewController *controller = [[SCImageClipViewController alloc] initWithImage:nil picker:self];
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            [self finishPickingAssets];
        }
    }
}

- (void)deselectAsset:(PHAsset *)asset {
    [self.selectedAssets removeObjectAtIndex:[self.selectedAssets indexOfObject:asset]];
    [self updateDoneButton];
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
    UINavigationController *nav = (UINavigationController *)self.childViewControllers[0];
    for (UIViewController *viewController in nav.viewControllers) {
        viewController.navigationItem.rightBarButtonItem.enabled = self.selectedAssets.count > 0;
        if (viewController.navigationItem.rightBarButtonItems.count > 1) {
            UIBarButtonItem *badgeButtonItem = viewController.navigationItem.rightBarButtonItems[1];
            SCBadgeView *badgeView = badgeButtonItem.customView;
            badgeView.number = self.selectedAssets.count;
        }
    }
}

@end
