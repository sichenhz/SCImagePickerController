//
//  SCAlbumsViewCell.m
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/20.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCAlbumsViewCell.h"
#import "SCAlbumsViewController.h"

@implementation SCAlbumsViewCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.thumbnailView.image = nil;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        // thumbnailView
        _thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAlbumThumbnailSize.width, kAlbumThumbnailSize.height)];
        _thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailView.clipsToBounds = YES;
        [self.contentView addSubview:_thumbnailView];
        
        self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView]-(offset)-[textLabel]-|"
                                                                                 options:0
                                                                                 metrics:@{@"offset": @(5)}
                                                                                   views:@{@"textLabel": self.textLabel,
                                                                                           @"imageView": self.thumbnailView}]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[textLabel]-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:@{@"textLabel": self.textLabel}]];
    }
    return self;
}

@end
