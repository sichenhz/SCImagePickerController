//
//  SCImageClipViewController.h
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/24.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCImagePickerController.h"

@interface SCImageClipViewController : UIViewController

- (instancetype)initWithPicker:(SCImagePickerController *)picker;

@property (nonatomic, strong) UIImage *image;

@end
