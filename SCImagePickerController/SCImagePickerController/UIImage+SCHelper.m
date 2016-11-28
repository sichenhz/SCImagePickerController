//
//  UIImage+SCHelper.m
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/24.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "UIImage+SCHelper.h"

@implementation UIImage (SCHelper)

+ (CGSize)resizeForSend:(CGSize)size {
    
    CGSize targetSize = size;
    
    CGFloat regularLength = 1280;
    CGFloat regularFactor = 2;
    CGFloat factor = size.width >= size.height ? size.width / size.height : size.height / size.width;
    
    // 1.宽小于等于regularLength，高小于等于regularLength
    // 2.宽小于等于regularLength，高大于regularLength，且factor大于regularFactor
    // 3.宽大于regularLength，高小于等于regularLength，且factor大于regularFactor
    if ((size.width <= regularLength && size.height <= regularLength) ||
        (size.width <= regularLength && size.height >  regularLength && factor > regularFactor) ||
        (size.width >  regularLength && size.height <= regularLength && factor > regularFactor)) {
        // 保持尺寸
    }
    else {
        // 等比缩小
        // 按宽=regularLength等比缩小
        // 1.宽大于regularLength，高小于等于regularLength，且factor小于等于regularFactor
        // 2.宽大于regularLength，高大于regularLength，且宽大于等于高
        if ((size.width > regularLength && size.height <= regularLength && factor <= regularFactor) ||
            (size.width > regularLength && size.height >  regularLength && size.width >= size.height)) {
            targetSize = CGSizeMake(regularLength, regularLength * size.height / size.width);
        }
        // 按高=regularLength等比缩小
        // 1.宽小于等于regularLength，高大于regularLength，且factor小于等于regularFactor
        // 2.宽大于regularLength，高大于regularLength，且宽小于高
        else {
            targetSize = CGSizeMake(regularLength * size.width / size.height, regularLength);
        }
    }
    NSLog(@"处理前size -> %@", NSStringFromCGSize(size));
    NSLog(@"处理后size -> %@", NSStringFromCGSize(targetSize));
    return targetSize;
}

- (UIImage *)crop:(CGRect)rect {
    return [self crop:rect scale:self.scale];
}

- (UIImage*)crop:(CGRect)rect scale:(CGFloat)scale {
    CGPoint origin = CGPointMake(-rect.origin.x, -rect.origin.y);
    UIImage *result = nil;
    UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.height));
    [self drawInRect:CGRectMake(origin.x, origin.y, self.size.width * scale, self.size.height * scale)];
    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

// http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
