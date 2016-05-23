//
//  SCBadgeView.h
//  Higo
//
//  Created by sichenwang on 16/3/25.
//  Copyright © 2016年 Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SCBadgeViewAlignment) {
    SCBadgeViewAlignmentLeft = 0,
    SCBadgeViewAlignmentCenter,
    SCBadgeViewAlignmentRight
};

@interface SCBadgeView : UIView

- (instancetype)initWithFrame:(CGRect)frame alignment:(SCBadgeViewAlignment)alignment NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

#if TARGET_INTERFACE_BUILDER
@property (nonatomic, assign) IBInspectable NSInteger alignment;
#else
@property (nonatomic, assign, readonly) SCBadgeViewAlignment alignment;
#endif

@property (nonatomic, assign) NSInteger number;

@property (nonatomic, strong) IBInspectable UIColor *backgroundColor;
@property (nonatomic, strong) IBInspectable UIColor *textColor;

@end
