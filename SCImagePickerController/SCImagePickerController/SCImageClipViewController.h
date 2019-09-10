//
//  SCImageClipViewController.h
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/24.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCImagePickerController.h"
@protocol SCImageClipViewControllerDelegate;

@interface SCImageClipViewController : UIViewController

// If set this property to YES, clipping function would be disable.
@property (nonatomic, getter=isPreview) BOOL preview;

@property (nonatomic, getter=isAllowedWhiteEdges) BOOL allowWhiteEdges; // default is NO. If set this property to YES, the original image can be completely contained in the clipping area and export an image with white edges.

- (instancetype)initWithImage:(UIImage *)image picker:(SCImagePickerController *)picker;

// Call this method and set delegate if you want to use it as a stand-alone tool.
- (instancetype)initWithImage:(UIImage *)image cropSize:(CGSize)cropSize;
@property (nonatomic, weak) id <SCImageClipViewControllerDelegate>delegate;

@end

@protocol SCImageClipViewControllerDelegate <NSObject>

@optional

- (void)clipViewControllerDidCancel:(SCImageClipViewController *)picker;
- (void)clipViewController:(SCImageClipViewController *)picker didFinishClipImage:(UIImage *)image;

@end

