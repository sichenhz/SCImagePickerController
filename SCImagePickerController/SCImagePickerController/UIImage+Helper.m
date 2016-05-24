//
//  UIImage+Helper.m
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/24.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "UIImage+Helper.h"

@implementation UIImage (Helper)

- (UIImage*)crop:(CGRect)rect scale:(CGFloat)scale {
    CGPoint origin = CGPointMake(-rect.origin.x, -rect.origin.y);
    UIImage *image = nil;
    UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.height));
    [self drawInRect:CGRectMake(origin.x, origin.y, self.size.width, self.size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
