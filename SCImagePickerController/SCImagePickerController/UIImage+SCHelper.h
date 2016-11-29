//
//  UIImage+SCHelper.h
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/24.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SCHelper)

+ (CGSize)sc_resizeForSend:(CGSize)size;

- (UIImage *)sc_crop:(CGRect)rect scale:(CGFloat)scale;

- (UIImage *)sc_fixOrientation;

@end
