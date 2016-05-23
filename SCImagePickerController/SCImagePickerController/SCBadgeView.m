//
//  SCBadgeView.m
//  Higo
//
//  Created by sichenwang on 16/3/25.
//  Copyright © 2016年 Ryan. All rights reserved.
//

#import "SCBadgeView.h"

@interface UIView(easy)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGSize size;

@end

@implementation UIView(easy)

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

@end

static CGSize const SCBadgeViewSize = {17, 17};

@implementation SCBadgeView
{
    UIButton *_button;
}

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame alignment:SCBadgeViewAlignmentLeft type:SCBadgeViewTypeDefault];
}

- (instancetype)initWithFrame:(CGRect)frame alignment:(SCBadgeViewAlignment)alignment type:(SCBadgeViewType)type {
    _alignment = alignment;
    _type = type;
    if (self = [super initWithFrame:frame]) {
        [self initializeSubViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializeSubViews];
    }
    return self;
}

- (void)initializeSubViews {
    self.hidden = YES;
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.adjustsImageWhenHighlighted = NO;
    _button.titleLabel.font = [UIFont systemFontOfSize:10];
    [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_button setBackgroundColor:[UIColor colorWithRed:255 / 255.0 green:102 / 255.0 blue:102 / 255.0 alpha:1]];
    _button.layer.cornerRadius = SCBadgeViewSize.height / 2;
    _button.clipsToBounds = YES;
    [self addSubview:_button];
    
    switch (self.type) {
        case SCBadgeViewTypeDefault:
            
            break;
        case SCBadgeViewTypeWhiteBorder:
            [_button setImage:[UIImage imageNamed:@"shop_users"] forState:UIControlStateNormal];
            [_button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -1)];
            _button.layer.borderColor = [[UIColor whiteColor] CGColor];
            _button.layer.borderWidth = 1;
            break;
    }
}

#pragma mark Setter

- (void)setNumber:(NSInteger)number {
    if (_number != number) {
        _number = number;
        NSString *text;
        if (number > 0) {
            self.hidden = NO;
            if (number < 1000) {
                text = [NSString stringWithFormat:@"%zd", number];
            } else {
                text = [NSString stringWithFormat:@"%.1fk", number / 1000.0];
            }
            [_button setTitle:text forState:UIControlStateNormal];
            [_button.titleLabel sizeToFit];
            CGFloat width = _button.titleLabel.frame.size.width;
            
            switch (self.type) {
                case SCBadgeViewTypeDefault:
                    if (SCBadgeViewSize.height >= width) {
                        width = SCBadgeViewSize.height;
                    } else {
                        width += 6;
                    }
                    break;
                case SCBadgeViewTypeWhiteBorder:
                    width += _button.currentImage.size.width + 7;
                    break;
            }
            
            switch (_alignment) {
                case SCBadgeViewAlignmentLeft:
                    // do nothing
                    break;
                case SCBadgeViewAlignmentCenter:
                    self.x -= (width - SCBadgeViewSize.width) / 2;
                    break;
                case SCBadgeViewAlignmentRight:
                    self.x -= width - SCBadgeViewSize.width;
                    break;
            }
            self.size = CGSizeMake(width, SCBadgeViewSize.height);
            _button.size = self.size;
        } else {
            self.hidden = YES;
            text = @"";
        }
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    if (_backgroundColor != backgroundColor) {
        _backgroundColor = backgroundColor;
        [_button setBackgroundImage:[self backgroundImageWithColor:backgroundColor] forState:UIControlStateNormal];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    if (_textColor != textColor) {
        _textColor = textColor;
        [_button setTitleColor:textColor forState:UIControlStateNormal];
    }
}

#pragma mark - Private Method

- (UIImage *)backgroundImageWithColor:(UIColor *)color {
    CGSize size = SCBadgeViewSize;
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [color CGColor]);
    CGContextFillRect(ctx, CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO , 0);
    ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, CGRectMake(0, 0, image.size.width, image.size.height));
    CGContextClip(ctx);
    CGContextStrokePath(ctx);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    UIImage *circleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [circleImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, image.size.width / 2 - 0.5, 0, image.size.width / 2 - 0.5) resizingMode:UIImageResizingModeStretch];
}

@end
