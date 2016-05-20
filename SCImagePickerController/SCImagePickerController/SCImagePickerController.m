//
//  SCImagePickerController.m
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/20.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCImagePickerController.h"
#import "SCAlbumsViewController.h"
@import Photos;

@interface SCImagePickerController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>

@end

@implementation SCImagePickerController

- (instancetype)init {
    if (self = [super init]) {
        _selectedAssets = [[NSMutableArray alloc] init];
        _allowsMultipleSelection = YES;
        _mediaTypes = @[@(PHAssetMediaTypeImage)];

        [self setupNavigationController];
    }
    return self;
}

- (void)setupNavigationController {
    _navigationController = [[UINavigationController alloc] initWithRootViewController:[[SCAlbumsViewController alloc] init]];
    _navigationController.delegate = self;
    
    [_navigationController willMoveToParentViewController:self];
    [_navigationController.view setFrame:self.view.frame];
    [self.view addSubview:_navigationController.view];
    [self addChildViewController:_navigationController];
    [_navigationController didMoveToParentViewController:self];
}

- (void)selectAsset:(PHAsset *)asset {
    [self.selectedAssets insertObject:asset atIndex:self.selectedAssets.count];
    if (self.allowsMultipleSelection) {
        [self updateDoneButton];
    } else {
        [self finishPickingAssets:self];
    }
}

- (void)deselectAsset:(PHAsset *)asset {
    [self.selectedAssets removeObjectAtIndex:[self.selectedAssets indexOfObject:asset]];
    [self updateDoneButton];
}

- (void)dismiss:(id)sender {
    if ([self.delegate respondsToSelector:@selector(assetsPickerControllerDidCancel:)]) {
        [self.delegate assetsPickerControllerDidCancel:self];
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)finishPickingAssets:(id)sender {
    if ([self.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)]) {
        [self.delegate assetsPickerController:self didFinishPickingAssets:self.selectedAssets];
    }
}

- (void)updateDoneButton {
    UINavigationController *nav = (UINavigationController *)self.childViewControllers[0];
    for (UIViewController *viewController in nav.viewControllers) {
        viewController.navigationItem.rightBarButtonItem.enabled = self.selectedAssets.count > 0;
    }
}

@end
