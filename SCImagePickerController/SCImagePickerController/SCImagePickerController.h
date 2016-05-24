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

typedef NS_ENUM(NSInteger, SCImagePickerControllerSourceType) {
    SCImagePickerControllerSourceTypePhotoLibrary,
    SCImagePickerControllerSourceTypeSavedPhotosAlbum
};

@interface SCImagePickerController : UIViewController

@property (nonatomic, strong) NSMutableArray <PHAsset *>*selectedAssets;

@property (nonatomic) SCImagePickerControllerSourceType sourceType; // default value is SCImagePickerControllerSourceTypePhotoLibrary.

@property (nonatomic, strong) NSArray *mediaTypes; //PHAssetMediaType

@property (nonatomic) BOOL allowsEditing; // default value is NO.
@property (nonatomic) CGSize clibSize;

@property (nonatomic) BOOL allowsMultipleSelection; //default value is NO
@property (nonatomic) NSInteger maxMultipleCount;

@property (nonatomic, strong) UINavigationController *navigationController;

- (void)selectAsset:(PHAsset *)asset;
- (void)deselectAsset:(PHAsset *)asset;

- (void)dismiss:(id)sender;
- (void)finishPickingAssets:(id)sender;

@property (nonatomic, weak) id <SCImagePickerControllerDelegate> delegate;

@end

@protocol SCImagePickerControllerDelegate <NSObject>

@optional

- (void)assetsPickerController:(SCImagePickerController *)picker didFinishPickingAssets:(NSArray <PHAsset *>*)assets;
- (void)assetsPickerController:(SCImagePickerController *)picker didEditPickingImage:(UIImage *)image;

- (void)assetsPickerControllerDidCancel:(SCImagePickerController *)picker;
- (void)assetsPickerVontrollerDidOverrunMaxMultipleCount:(SCImagePickerController *)picker;

@end