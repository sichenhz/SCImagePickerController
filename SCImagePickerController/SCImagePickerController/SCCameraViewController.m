//
//  SCCameraViewController.m
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/23.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCCameraViewController.h"

@implementation SCCameraViewController

- (instancetype)init {
    if (self = [super init]) {
        self.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];    
}

@end
