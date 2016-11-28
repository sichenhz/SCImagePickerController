//
//  SCAlbumsViewCell.h
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/20.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

@import UIKit;

static CGSize const kAlbumThumbnailSize = {57.0f, 57.0f};

@interface SCAlbumsViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *thumbnailView;
@property (nonatomic, copy) NSString *representedAlbumIdentifier;

@end
