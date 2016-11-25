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

@implementation SCImagePickerController

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
        [self.view addSubview:camera.view];
        [self addChildViewController:camera];

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
            SCImageClipViewController *controller = [[SCImageClipViewController alloc] initWithPicker:self];
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            [self finishPickingAssets:self];
        }
    }
}

- (void)deselectAsset:(PHAsset *)asset {
    [self.selectedAssets removeObjectAtIndex:[self.selectedAssets indexOfObject:asset]];
    [self updateDoneButton];
}

- (void)finishPickingAssets:(id)sender {
    if ([self.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)]) {
        [self.delegate assetsPickerController:self didFinishPickingAssets:self.selectedAssets];
    }
}

- (void)dismiss:(id)sender {
    if ([self.delegate respondsToSelector:@selector(assetsPickerControllerDidCancel:)]) {
        [self.delegate assetsPickerControllerDidCancel:self];
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Method

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
