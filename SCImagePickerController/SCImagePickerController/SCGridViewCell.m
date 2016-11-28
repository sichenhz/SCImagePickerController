//
//  SCGridViewCell.m
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/20.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCGridViewCell.h"

@interface SCGridViewCell()

@property (nonatomic, weak) UIView *selectedCoverView;
@property (nonatomic, weak) UIButton *selectionButton;

@end

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
        _thumbnailView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_thumbnailView];
        
    }
    return self;
}

- (void)setAllowsSelection:(BOOL)allowsSelection {
    if (_allowsSelection != allowsSelection) {
        _allowsSelection = allowsSelection;
        
        if (_allowsSelection) {
            
            UIView *selectedCoverView = [[UIView alloc] initWithFrame:self.bounds];
            selectedCoverView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            selectedCoverView.backgroundColor = [UIColor colorWithRed:0.24 green:0.47 blue:0.85 alpha:0.6];
            selectedCoverView.hidden = YES;
            [self.contentView addSubview:selectedCoverView];
            _selectedCoverView = selectedCoverView;
            
            UIButton *selectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            selectionButton.frame = CGRectMake(2*self.bounds.size.width/3, 0*self.bounds.size.width/3, self.bounds.size.width/3, self.bounds.size.width/3);
            selectionButton.contentMode = UIViewContentModeTopRight;
            selectionButton.adjustsImageWhenHighlighted = NO;
            [selectionButton setImage:nil forState:UIControlStateNormal];
            selectionButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            [selectionButton setImage:[UIImage imageNamed:[@"SCImagePickerController.bundle" stringByAppendingPathComponent:@"tickw.png"]] forState:UIControlStateNormal];
            [selectionButton setImage:[UIImage imageNamed:[@"SCImagePickerController.bundle" stringByAppendingPathComponent:@"tickH.png"]] forState:UIControlStateSelected];
            selectionButton.hidden = NO;
            selectionButton.userInteractionEnabled = NO;
            [self.contentView addSubview:selectionButton];
            _selectionButton = selectionButton;
            
        } else {
            
            [_selectedCoverView removeFromSuperview];
            [_selectionButton removeFromSuperview];
        }
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    if (self.allowsSelection) {
        _selectedCoverView.hidden = !selected;
        _selectionButton.selected = selected;
    }
}

@end
