//
//  SCTimeFormat.m
//  SCImagePickerController
//
//  Created by sichenwang on 2017/3/1.
//  Copyright © 2017年 higo. All rights reserved.
//

#import "SCTimeFormat.h"

@implementation SCTimeFormat

+ (NSString *)formatSeconds:(NSInteger)seconds {
    
    NSInteger hours = 0;
    NSInteger days = 0;
    if (seconds >= 60) {
        hours = seconds / 60;
        seconds = seconds % 60;
        if (hours >= 24) {
            days = hours / 24;
        }
    }
    if (days) {
        return [NSString stringWithFormat:@"%02zd:%02zd:%02zd", days, hours, seconds];
    } else if (hours) {
        return [NSString stringWithFormat:@"%02zd:%02zd", hours, seconds];
    } else {
        return [NSString stringWithFormat:@"00:%02zd", seconds];
    }
}

@end
