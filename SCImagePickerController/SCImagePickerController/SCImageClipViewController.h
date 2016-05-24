//
//  SCImageClipViewController.h
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/24.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCImagePickerController.h"
@import UIKit;
@import Photos;

NS_ASSUME_NONNULL_BEGIN

@interface SCImageClipViewController : UIViewController

- (instancetype)initWithPicker:(SCImagePickerController *)picker;

@property (nonatomic, strong, nonnull) PHAsset *asset;
@property (nonatomic) CGSize clibSize;

@end

NS_ASSUME_NONNULL_END