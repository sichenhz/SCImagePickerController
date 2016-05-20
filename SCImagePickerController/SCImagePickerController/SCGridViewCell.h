//
//  SCGridViewCell.h
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/20.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

@import UIKit;
@import Photos;

@interface SCGridViewCell : UICollectionViewCell

@property (nonatomic, strong) PHAsset *asset;

@property (nonatomic, strong) UIImageView *imageView;

//Selection overlay
@property (nonatomic) BOOL shouldShowSelection;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIButton *selectedButton;

@end
