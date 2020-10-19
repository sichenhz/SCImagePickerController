//
//  SCBadgeView.h
//  Higo
//
//  Created by sichenwang on 16/3/25.
//  Copyright © 2016年 Ryan. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSInteger, SCBadgeViewAlignment) {
    SCBadgeViewAlignmentLeft = 0,
    SCBadgeViewAlignmentCenter,
    SCBadgeViewAlignmentRight
};

typedef NS_ENUM(NSInteger, SCBadgeViewType) {
    SCBadgeViewTypeDefault = 0,
    SCBadgeViewTypeWhiteBorder
};

@interface SCBadgeView : UIView

/**
 *  A rectangle defining the frame of the SCBadgeView object. The size components of this rectangle are ignored.
 */
- (instancetype)initWithFrame:(CGRect)frame alignment:(SCBadgeViewAlignment)alignment type:(SCBadgeViewType)type NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

#if TARGET_INTERFACE_BUILDER
@property (nonatomic, assign) IBInspectable NSInteger alignment;
@property (nonatomic, assign) IBInspectable NSInteger type;
#else
@property (nonatomic, assign, readonly) SCBadgeViewAlignment alignment;
@property (nonatomic, assign, readonly) SCBadgeViewType type;
#endif

@property (nonatomic, assign) IBInspectable NSInteger number;
@property (nonatomic, strong) IBInspectable UIColor *backgroundColor;
@property (nonatomic, strong) IBInspectable UIColor *textColor;

@end
