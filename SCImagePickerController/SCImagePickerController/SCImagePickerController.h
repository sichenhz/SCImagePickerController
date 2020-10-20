//
//  SCImagePickerController.h
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/20.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

@import Photos;
@import UIKit;
@class SCImagePickerController;

@protocol SCImagePickerControllerDelegate <NSObject>

@optional

/** This method is called when photos are from albums. */
- (void)assetsPickerController:(SCImagePickerController *)picker didFinishPickingAssets:(NSArray <PHAsset *>*)assets;
/** This method is called when an image is from camera or cliping. */
- (void)assetsPickerController:(SCImagePickerController *)picker didFinishPickingImage:(UIImage *)image;
/** This method is called when imagePicker has canceled. */
- (void)assetsPickerControllerDidCancel:(SCImagePickerController *)picker;
/** This method is called when selected photos have overran the maximum number. */
- (void)assetsPickerControllerDidOverrunMaxMultipleCount:(SCImagePickerController *)picker;

@end

typedef NS_ENUM(NSInteger, SCImagePickerControllerSourceType) {
    /** 所有相册列表，包括相机胶卷、智能相册、手动创建的相册等 */
    SCImagePickerControllerSourceTypePhotoLibrary,
    /** 相机胶卷 */
    SCImagePickerControllerSourceTypeSavedPhotosAlbum,
    /** 相机 */
    SCImagePickerControllerSourceTypeCamera
};

@interface SCImagePickerController : UIViewController

@property (nonatomic, weak) id <SCImagePickerControllerDelegate> delegate;

@property (nonatomic) SCImagePickerControllerSourceType sourceType;
@property (nonatomic, strong) NSArray *mediaTypes; // default value is an array containing PHAssetMediaTypeImage.

@property (nonatomic) BOOL allowsMultipleSelection; // default value is NO.
@property (nonatomic) NSInteger maxMultipleCount; // default is unlimited and value is 0.

// These three properties are available when allowsMultipleSelection value is NO.
@property (nonatomic) BOOL allowsEditing; // default value is NO.
@property (nonatomic) CGSize cropSize; // default value is {[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width}
@property (nonatomic, getter=isAllowedWhiteEdges) BOOL allowWhiteEdges; // default is NO. If set this property to YES, the original image can be completely contained in the clipping area and export an image with white edges.

// Managing Asset Selection
@property (nonatomic, strong) NSMutableArray <PHAsset *>*selectedAssets;
- (void)selectAsset:(PHAsset *)asset;
- (void)deselectAsset:(PHAsset *)asset;

// Switch between camera and albums
- (void)presentAlbums;
- (void)presentCamera;
- (void)updateStatusBarHidden:(BOOL)hidden animation:(BOOL)animation;

@end
