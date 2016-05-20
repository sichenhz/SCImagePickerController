//
//  SCImagePickerController.h
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/20.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

@import UIKit;
@import Photos;

@protocol SCImagePickerControllerDelegate;

@interface SCImagePickerController : UIViewController

@property (nonatomic, strong) NSMutableArray <PHAsset *>*selectedAssets;

@property (nonatomic, strong) NSArray *mediaTypes;

@property (nonatomic, assign) BOOL allowsMultipleSelection;

@property (nonatomic, strong) UINavigationController *navigationController;

- (void)selectAsset:(PHAsset *)asset;
- (void)deselectAsset:(PHAsset *)asset;

- (void)dismiss:(id)sender;
- (void)finishPickingAssets:(id)sender;

@property (nonatomic, weak) id <SCImagePickerControllerDelegate> delegate;

@end

@protocol SCImagePickerControllerDelegate <NSObject>

- (void)assetsPickerController:(SCImagePickerController *)picker didFinishPickingAssets:(NSArray *)assets;

@optional

- (void)assetsPickerControllerDidCancel:(SCImagePickerController *)picker;

@end