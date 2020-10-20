//
//  KKProgressCircleView.h
//  KKShopping
//
//  Created by nice on 16/7/18.
//  Copyright © 2016年 nice. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SCProgressType) {
    SCProgressTypeCircle = 0,
    SCProgressTypeLine
};

@interface SCProgressView : UIView

- (instancetype)initWithFrame:(CGRect)frame type:(SCProgressType)type;

// 起点位置,默认为0
@property (nonatomic, assign) CGFloat defaultStokenStart;
// 进度的颜色,默认black
@property (nonatomic, assign) CGColorRef strokeColor;
// 进度宽度
@property (nonatomic, assign) CGFloat lineWidth;
// 进度值
@property (nonatomic, assign) CGFloat progress;

// 以下属性仅支持Circle
// 圆环内部填充色，默认clear
@property (nonatomic, assign) CGColorRef fillColor;
// 圆环的直径
@property (nonatomic, assign) CGFloat circleWidth;

@end
