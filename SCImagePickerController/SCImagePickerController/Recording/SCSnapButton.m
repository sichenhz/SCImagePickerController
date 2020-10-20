//
//  SCSnapButton.m
//  SCImagePickerController
//
//  Created by sichenwang on 2017/1/24.
//  Copyright © 2017年 higo. All rights reserved.
//

#import "SCSnapButton.h"
#import "SCProgressView.h"

@interface SCSnapButton()

@property (nonatomic, strong) UIView *insideView;
@property (nonatomic, strong) SCProgressView *outsideView;

@end

@implementation SCSnapButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        _insideView = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - 62)/2, (frame.size.height - 62)/2, 62, 62)];
        _insideView.layer.cornerRadius = 31;
        _insideView.layer.backgroundColor = [UIColor redColor].CGColor;
        [self addSubview:_insideView];
        
        _outsideView = [[SCProgressView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _outsideView.strokeColor = [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1].CGColor;
        _outsideView.lineWidth = 4;
        _outsideView.progress = 1;
        [self addSubview:_outsideView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    if (_selected != selected) {
        _selected = selected;
        
        if (selected) {
            CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            scaleAnimation.fromValue = @(1);
            scaleAnimation.toValue = @(0.5887);
            scaleAnimation.duration = 0.3;
            scaleAnimation.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            scaleAnimation.removedOnCompletion = NO;
            scaleAnimation.fillMode = kCAFillModeForwards;
            [self.insideView.layer addAnimation:scaleAnimation forKey:@"scale"];
            
            CABasicAnimation *radiusAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
            radiusAnimation.fromValue = @(31);
            radiusAnimation.toValue = @(7.5);
            radiusAnimation.duration = 0.3;
            radiusAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            radiusAnimation.removedOnCompletion = NO;
            radiusAnimation.fillMode = kCAFillModeForwards;
            [self.insideView.layer addAnimation:radiusAnimation forKey:@"radius"];
            
        } else {
            CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            scaleAnimation.fromValue = @(0.5887);
            scaleAnimation.toValue = @(1);
            scaleAnimation.duration = 0.3;
            scaleAnimation.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            scaleAnimation.removedOnCompletion = NO;
            scaleAnimation.fillMode = kCAFillModeForwards;
            [self.insideView.layer addAnimation:scaleAnimation forKey:@"scale"];
            
            CABasicAnimation *radiusAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
            radiusAnimation.fromValue = @(7.5);
            radiusAnimation.toValue = @(31);
            radiusAnimation.duration = 0.3;
            radiusAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            radiusAnimation.removedOnCompletion = NO;
            radiusAnimation.fillMode = kCAFillModeForwards;
            [self.insideView.layer addAnimation:radiusAnimation forKey:@"radius"];
        }
    }
}

@end
