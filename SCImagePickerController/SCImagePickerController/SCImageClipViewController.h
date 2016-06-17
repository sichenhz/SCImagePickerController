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

- (instancetype)initWithPicker:(SCImagePickerController *)picker;

// 作为单独的工具使用
- (instancetype)initWithImage:(UIImage *)image cropSize:(CGSize)cropSize;
@property (nonatomic, weak) id <SCImageClipViewControllerDelegate>delegate;

@end

@protocol SCImageClipViewControllerDelegate <NSObject>

@optional

- (void)clipViewControllerDidCancel:(SCImageClipViewController *)picker;
- (void)clipViewController:(SCImageClipViewController *)picker didFinishClipImage:(UIImage *)image;

@end

