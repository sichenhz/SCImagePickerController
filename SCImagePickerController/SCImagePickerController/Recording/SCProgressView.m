//
//  KKProgressCircleView.m
//  KKShopping
//
//  Created by nice on 16/7/18.
//  Copyright © 2016年 nice. All rights reserved.
//

#import "SCProgressView.h"

@interface SCProgressView()

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic) SCProgressType type;

@end

@implementation SCProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame type:SCProgressTypeCircle];
}

- (instancetype)initWithFrame:(CGRect)frame type:(SCProgressType)type {
    if (self = [super initWithFrame:frame]) {
        _type = type;
        self.userInteractionEnabled = NO;
        [self.layer addSublayer:[self shapeLayerWithType:type]];
    }
    return self;
}

- (CAShapeLayer *)shapeLayerWithType:(SCProgressType)type {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.frame = self.bounds;
        if (type == SCProgressTypeCircle) {
            [self configCircleFrame];
            _shapeLayer.fillColor = [UIColor clearColor].CGColor;
            _shapeLayer.strokeColor = [UIColor blackColor].CGColor;
            _shapeLayer.lineWidth = self.lineWidth;
            _shapeLayer.strokeStart = 0;
            _shapeLayer.strokeEnd = 0;
            _shapeLayer.transform = CATransform3DMakeRotation(-0.25 * 2 * M_PI, 0, 0, 1);
            _shapeLayer.lineCap = kCALineJoinMiter;
        } else {
            [self configLineFrame];
            _shapeLayer.fillColor = [UIColor clearColor].CGColor;
            _shapeLayer.strokeColor = [UIColor blackColor].CGColor;
            _shapeLayer.lineWidth = self.lineWidth;
            _shapeLayer.strokeStart = 0;
            _shapeLayer.strokeEnd = 0;
            _shapeLayer.lineCap = kCALineJoinMiter;
        }
    }
    return _shapeLayer;
}

- (void)configCircleFrame
{
    CGFloat width = [self widthHieght];
    CGFloat difference = self.shapeLayer.frame.size.width - width;
    CGFloat finally = difference > 0 ? difference : 0;
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(finally * 0.5, finally * 0.5, width, width)];
    _shapeLayer.path = path.CGPath;
}

- (void)configLineFrame
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width, 0)];
    _shapeLayer.path = path.CGPath;
}

- (CGFloat)widthHieght
{
    return self.circleWidth == 0 ? MIN(self.frame.size.width, self.frame.size.height) : self.circleWidth;
}

#pragma mark - set method

- (void)setFillColor:(CGColorRef)fillColor
{
    _fillColor = fillColor;
    self.shapeLayer.fillColor = fillColor;
}

- (void)setStrokeColor:(CGColorRef)strokeColor
{
    _strokeColor = strokeColor;
    self.shapeLayer.strokeColor = strokeColor;
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    self.shapeLayer.lineWidth = lineWidth;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    self.shapeLayer.strokeEnd = (progress + _shapeLayer.strokeStart);
}

- (void)setCircleWidth:(CGFloat)circleWidth
{
    _circleWidth = circleWidth;
    
    [self configCircleFrame];
}

- (void)setDefaultStokenStart:(CGFloat)defaultStokenStart
{
    _defaultStokenStart = defaultStokenStart;
    
    self.shapeLayer.transform = CATransform3DMakeRotation(_defaultStokenStart * 2 * M_PI, 0, 0, 1);
}

@end
