//
//  SCGridViewCell.m
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/20.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCGridViewCell.h"

@implementation SCGridViewCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.thumbnailView.image = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        CGFloat cellSize = self.contentView.bounds.size.width;
        
        _thumbnailView = [UIImageView new];
        _thumbnailView.frame = CGRectMake(0, 0, cellSize, cellSize);
        _thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailView.clipsToBounds = YES;
        _thumbnailView.translatesAutoresizingMaskIntoConstraints = NO;
        _thumbnailView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_thumbnailView];
        
        // Selection overlay & icon
        _coverView = [[UIView alloc] initWithFrame:self.bounds];
        _coverView.translatesAutoresizingMaskIntoConstraints = NO;
        _coverView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _coverView.backgroundColor = [UIColor colorWithRed:0.24 green:0.47 blue:0.85 alpha:0.6];
        [self.contentView addSubview:_coverView];
        _coverView.hidden = YES;
        
        _selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectedButton.frame = CGRectMake(2*self.bounds.size.width/3, 0*self.bounds.size.width/3, self.bounds.size.width/3, self.bounds.size.width/3);
        _selectedButton.contentMode = UIViewContentModeTopRight;
        _selectedButton.adjustsImageWhenHighlighted = NO;
        [_selectedButton setImage:nil forState:UIControlStateNormal];
        _selectedButton.translatesAutoresizingMaskIntoConstraints = NO;
        _selectedButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_selectedButton setImage:[UIImage imageNamed:[@"SCImagePickerController.bundle" stringByAppendingPathComponent:@"tickH.png"]] forState:UIControlStateSelected];
        _selectedButton.hidden = NO;
        _selectedButton.userInteractionEnabled = NO;
        [self.contentView addSubview:_selectedButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    if (!self.shouldShowSelection) {
        return;
    }
    
    _coverView.hidden = !selected;
    _selectedButton.selected = selected;
}

@end
