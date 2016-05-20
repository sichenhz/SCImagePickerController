//
//  SCAlbumsViewCell.h
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/20.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

@import UIKit;
@import Photos;

@interface SCAlbumsViewCell : UITableViewCell

@property (strong) PHFetchResult *assetsFetchResults;
@property (strong) PHAssetCollection *assetCollection;

@property (nonatomic, strong) UIImageView *thumbnailView;

@end
