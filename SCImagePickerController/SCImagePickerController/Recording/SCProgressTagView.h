//
//  SCProgressTagView.h
//  SCImagePickerController
//
//  Created by sichenwang on 2017/4/7.
//  Copyright © 2017年 higo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCProgressTagView : UIView

@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic) CGFloat progress;
@property (nonatomic, copy) NSString *time;
@property (nonatomic) CGFloat duration;

@end
