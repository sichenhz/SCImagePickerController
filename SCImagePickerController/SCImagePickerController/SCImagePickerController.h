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

@property (nonatomic, weak) id <SCImagePickerControllerDelegate> delegate;

@property (nonatomic) SCImagePickerControllerSourceType sourceType;
@property (nonatomic, strong) NSArray *mediaTypes; // default value is an array containing PHAssetMediaTypeImage.

@property (nonatomic) BOOL allowsMultipleSelection; // default value is NO.
@property (nonatomic) NSInteger maxMultipleCount; // default is unlimited and value is 0.

// These two properties are available when allowsMultipleSelection value is NO.
@property (nonatomic) BOOL allowsEditing; // default value is NO.
@property (nonatomic) CGSize cropSize; // default value is {[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width}
@property (nonatomic, getter=isAllowedWhiteEdges) BOOL allowWhiteEdges; // default is NO. If set this property to YES, the original image can be completely contained in the clipping area and export an image with white edges.

@property (nonatomic, strong) NSMutableArray <PHAsset *>*selectedAssets;
// Managing Asset Selection
- (void)selectAsset:(PHAsset *)asset;
- (void)deselectAsset:(PHAsset *)asset;

// User finish Actions
- (void)finishPickingAssets;
- (void)finishPickingImage:(UIImage *)image;
- (void)cancel;

- (void)presentAlbums;
- (void)presentCamera;
- (void)updateStatusBarHidden:(BOOL)hidden animation:(BOOL)animation;

@end

@protocol SCImagePickerControllerDelegate <NSObject>

@optional

- (void)assetsPickerControllerDidCancel:(SCImagePickerController *)picker;

- (void)assetsPickerControllerDidOverrunMaxMultipleCount:(SCImagePickerController *)picker;

// This method is called when photos are from albums.
- (void)assetsPickerController:(SCImagePickerController *)picker didFinishPickingAssets:(NSArray <PHAsset *>*)assets;
// This method is called when image is from camera or cliping.
- (void)assetsPickerController:(SCImagePickerController *)picker didFinishPickingImage:(UIImage *)image;

@end
