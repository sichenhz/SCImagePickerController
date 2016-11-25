//
//  SCImagePickerController.h
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/20.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

@import Photos;

@protocol SCImagePickerControllerDelegate;

typedef NS_ENUM(NSInteger, SCImagePickerControllerSourceType) {
    SCImagePickerControllerSourceTypePhotoLibrary,
    SCImagePickerControllerSourceTypeSavedPhotosAlbum,
    SCImagePickerControllerSourceTypeCamera
};

@interface SCImagePickerController : UIViewController

@property (nonatomic, strong) NSMutableArray <PHAsset *>*selectedAssets;

@property (nonatomic) SCImagePickerControllerSourceType sourceType;

@property (nonatomic, strong) NSArray *mediaTypes; // default value is an array containing PHAssetMediaTypeImage.

@property (nonatomic) BOOL allowsMultipleSelection; // default value is NO.
@property (nonatomic) NSInteger maxMultipleCount; // default is unlimited and value is 0.

// These two properties are available when allowsMultipleSelection value is NO.
@property (nonatomic) BOOL allowsEditing; // default value is NO.
@property (nonatomic) CGSize cropSize; // default value is {[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width}

@property (nonatomic, strong) UINavigationController *navigationController;

// Managing Asset Selection
- (void)selectAsset:(PHAsset *)asset;
- (void)deselectAsset:(PHAsset *)asset;

// User finish Actions
- (void)finishPickingAssets:(id)sender;
- (void)dismiss:(id)sender;

@property (nonatomic, weak) id <SCImagePickerControllerDelegate> delegate;

@end

@protocol SCImagePickerControllerDelegate <NSObject>

@optional

- (void)assetsPickerController:(SCImagePickerController *)picker didFinishPickingAssets:(NSArray <PHAsset *>*)assets;

- (void)assetsPickerControllerDidCancel:(SCImagePickerController *)picker;

- (void)assetsPickerVontrollerDidOverrunMaxMultipleCount:(SCImagePickerController *)picker;

// This method is called when allowsMultipleSelection is NO and allowsEditing is YES.
- (void)assetsPickerController:(SCImagePickerController *)picker didFinishPickingImage:(UIImage *)image;

@end
