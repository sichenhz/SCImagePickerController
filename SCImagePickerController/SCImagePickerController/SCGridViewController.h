//
//  SCGridViewController.h
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/20.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCImagePickerController.h"

@interface SCGridViewController : UICollectionViewController

@property (nonatomic, strong) PHFetchResult *assets;

- (instancetype)initWithPicker:(SCImagePickerController *)picker;

@end
