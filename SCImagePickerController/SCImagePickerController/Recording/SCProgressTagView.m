//
//  SCProgressTagView.m
//  SCImagePickerController
//
//  Created by sichenwang on 2017/4/7.
//  Copyright © 2017年 higo. All rights reserved.
//

#import "SCProgressTagView.h"

@implementation SCProgressTagView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIView *breakView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width - 0.5, 0, 0.5, frame.size.height)];
        breakView.backgroundColor = [UIColor whiteColor];
        [self addSubview:breakView];
        
        self.selected = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    
    if (selected) {
        self.backgroundColor = [UIColor redColor];
    } else {
        self.backgroundColor = [UIColor blackColor];
    }
}

@end
