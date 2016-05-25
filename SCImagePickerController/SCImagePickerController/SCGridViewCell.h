//
//  SCGridViewCell.h
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/20.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

@import UIKit;

@interface SCGridViewCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView *thumbnailView;
@property (nonatomic, copy) NSString *representedAssetIdentifier;

//Selection overlay
@property (nonatomic) BOOL shouldShowSelection;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIButton *selectedButton;

@end
