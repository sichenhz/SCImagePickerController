//
//  SCGridViewFlowLayout.m
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/20.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCGridViewFlowLayout.h"

@implementation SCGridViewFlowLayout

- (CGSize)collectionViewContentSize {
    CGSize size = [super collectionViewContentSize];
    NSLog(@"%@", NSStringFromCGSize([super collectionViewContentSize]));
    return size;
}

@end
