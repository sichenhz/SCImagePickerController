//
//  SCGridViewController.h
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/20.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCImagePickerController.h"
@import UIKit;
@import Photos;

@interface SCGridViewController : UICollectionViewController

@property (strong) PHFetchResult *assetsFetchResults;

- (instancetype)initWithPicker:(SCImagePickerController *)picker;

@end
