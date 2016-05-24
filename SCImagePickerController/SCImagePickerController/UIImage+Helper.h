//
//  UIImage+Helper.h
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/24.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Helper)

+ (CGSize)resizeForSend:(CGSize)size;

- (UIImage *)crop:(CGRect)rect scale:(CGFloat)scale;

@end
