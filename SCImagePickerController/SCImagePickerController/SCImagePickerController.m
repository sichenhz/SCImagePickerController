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
#import "SCBadgeView.h"
@import Photos;

@interface SCImagePickerController() <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation SCImagePickerController

- (instancetype)init {
    if (self = [super init]) {
        _selectedAssets = [[NSMutableArray alloc] init];
        _mediaTypes = @[@(PHAssetMediaTypeImage)];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationController];
}

- (void)setupNavigationController {
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:[[SCAlbumsViewController alloc] init]];
    [self.navigationController willMoveToParentViewController:self];
    [self.navigationController.view setFrame:self.view.frame];
    [self.view addSubview:self.navigationController.view];
    [self addChildViewController:self.navigationController];
    [self.navigationController didMoveToParentViewController:self];
}

- (void)selectAsset:(PHAsset *)asset {
    [self.selectedAssets insertObject:asset atIndex:self.selectedAssets.count];
    if (self.allowsMultipleSelection) {
        [self updateDoneButton];
    } else {
        if (self.allowsEditing) {
            CGSize screenSize = [UIScreen mainScreen].bounds.size;
            SCImageClipViewController *controller = [[SCImageClipViewController alloc] initWithPicker:self];
            controller.asset = asset;
            controller.clibSize = CGSizeEqualToSize(self.clibSize, CGSizeZero) ? CGSizeMake(screenSize.width, screenSize.width) : self.clibSize;
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
    if ([self.delegate respondsToSelector:@selector(assetsPickerController:didEditPickingImage:)]) {
        if (self.selectedAssets.count > 0) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.resizeMode = PHImageRequestOptionsResizeModeExact;
            [[PHCachingImageManager defaultManager] requestImageForAsset:self.selectedAssets[0]
                                                              targetSize:self.clibSize
                                                             contentMode:PHImageContentModeAspectFill
                                                                 options:options
                                                           resultHandler:^(UIImage *result, NSDictionary *info) {
                                                               BOOL isDegradedKey = [info[PHImageResultIsDegradedKey] integerValue];
                                                               if (!isDegradedKey) {
                                                                   [self.delegate assetsPickerController:self didEditPickingImage:result];
                                                               }
                                                           }];
        }
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

#pragma UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"当前照片信息 -> %@", info);
}

@end
