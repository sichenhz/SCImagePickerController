//
//  SCAlbumsViewController.m
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/20.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCAlbumsViewController.h"
#import "SCImagePickerController.h"
#import "SCGridViewController.h"
#import "SCAlbumsViewCell.h"
#import "SCBadgeView.h"

static NSString * const SCAlbumsViewCellReuseIdentifier = @"SCAlbumsViewCellReuseIdentifier";

@interface SCAlbumsViewController()

@property (nonatomic, weak) SCImagePickerController *picker;
@property (nonatomic, strong) NSArray <PHFetchResult *>*fetchResults;
@property (nonatomic, strong) NSArray <PHAssetCollection *>*assetCollections;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) SCBadgeView *badgeView;

@end

@implementation SCAlbumsViewController

#pragma mark - Life Cycle

- (instancetype)initWithPicker:(SCImagePickerController *)picker {
    self.picker = picker;
    return [self init];
}

- (instancetype)init {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.title = @"相册";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = kAlbumThumbnailSize.height + 0.5;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self.picker
                                                                            action:@selector(dismiss:)];

    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    [self showAlbums];
                    [self.tableView reloadData];
                } else {
                    [self showNoAuthority];
                }
            });
        }];
    } else if (status == PHAuthorizationStatusAuthorized) {
        [self showAlbums];
    } else {
        [self showNoAuthority];
    }
}

#pragma mark - Setter

- (void)setFetchResults:(NSArray<PHFetchResult *> *)fetchResults {
    _fetchResults = fetchResults;
    
    NSMutableArray *assetCollections = [NSMutableArray array];
    
    for (PHFetchResult *fetchResult in fetchResults) {
        for (PHCollection *collection in fetchResult) {
            if ([collection isKindOfClass:[PHAssetCollection class]]) {
                PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                PHFetchResult *assets = [self assetsInAssetCollection:assetCollection];
                if (assets.count > 0) {
                    if (assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                        [assetCollections insertObject:assetCollection atIndex:0];
                    } else if (assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeAlbumMyPhotoStream) {
                        if (assetCollections.count > 0 && [assetCollections[0] assetCollectionSubtype] == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                            [assetCollections insertObject:assetCollection atIndex:1];
                        } else {
                            [assetCollections insertObject:assetCollection atIndex:0];
                        }
                    } else {
                        [assetCollections addObject:assetCollection];
                    }
                }
            }
        }
    }
    
    self.assetCollections = [assetCollections copy];
}

#pragma mark - Private Method

- (void)showNoAuthority {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 150)];
    label.textColor = [UIColor darkTextColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16.0];
    label.text = @"请在\"设置\"->\"隐私\"->\"相册\"开启访问权限";
    self.tableView.tableHeaderView = label;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.bounces = NO;
}

- (void)showAlbums {
    self.imageManager = [[PHCachingImageManager alloc] init];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    self.fetchResults = @[smartAlbums, albums];
    
    if (self.picker.allowsMultipleSelection) {
        [self attachRightBarButton];
    }
    
    if (self.picker.sourceType == SCImagePickerControllerSourceTypeSavedPhotosAlbum ||
        self.picker.sourceType == SCImagePickerControllerSourceTypeCamera) {
        [self pushCameraRollViewController];
    }
}

- (void)attachRightBarButton {
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self.picker
                                                                      action:@selector(finishPickingAssets:)];
    doneButtonItem.enabled = self.picker.selectedAssets.count > 0;
    
    self.badgeView = [[SCBadgeView alloc] init];
    self.badgeView.number = self.picker.selectedAssets.count;
    UIBarButtonItem *badgeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.badgeView];
    
    self.navigationItem.rightBarButtonItems = @[doneButtonItem, badgeButtonItem];
}

- (void)pushCameraRollViewController {
    PHFetchResult *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    
    if (collections.count > 0) {
        PHAssetCollection *collection = collections[0];
        
        SCGridViewController *cameraRollViewController = [[SCGridViewController alloc] initWithPicker:self.picker];
        cameraRollViewController.assets = [self assetsInAssetCollection:collection];
        cameraRollViewController.title = collection.localizedTitle;
        
        [self.navigationController pushViewController:cameraRollViewController animated:NO];
    }
}

- (PHFetchResult *)assetsInAssetCollection:(PHAssetCollection *)collection {
    if (self.picker.mediaTypes.count) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@", self.picker.mediaTypes];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        return [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:options];
    } else {
        return nil;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.assetCollections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PHAssetCollection *assetCollection = self.assetCollections[indexPath.row];
    PHFetchResult *assets = [self assetsInAssetCollection:assetCollection];

    // Dequeue an SCAlbumsViewCell.
    SCAlbumsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SCAlbumsViewCellReuseIdentifier];
    if (cell == nil) {
        cell = [[SCAlbumsViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SCAlbumsViewCellReuseIdentifier];
    }
    NSString *currentAlbumIdentifier = [NSString stringWithFormat:@"section -> %zd, row -> %zd", indexPath.section, indexPath.row];
    cell.representedAlbumIdentifier = currentAlbumIdentifier;

    // Set the cell's title.
    NSString *text = assetCollection.localizedTitle;
    NSMutableAttributedString *attrStrM = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:16]}];
    [attrStrM appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)", assets.count] attributes:@{NSForegroundColorAttributeName : [UIColor grayColor]}]];
    cell.textLabel.attributedText = [attrStrM copy];

    // Request an image for the collection from the PHCachingImageManager.
    CGFloat scale = [UIScreen mainScreen].scale;
    PHAsset *asset = assets.firstObject;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    [self.imageManager requestImageForAsset:asset
                                 targetSize:CGSizeMake(self.tableView.rowHeight * scale, self.tableView.rowHeight * scale)
                                contentMode:PHImageContentModeAspectFill
                                    options:options
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  // Set the cell's thumbnail image if it's still showing the same album.
                                  if ([cell.representedAlbumIdentifier isEqualToString:currentAlbumIdentifier]) {
                                      cell.thumbnailView.image = result;
                                  }
                              }];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PHAssetCollection *assetCollection = self.assetCollections[indexPath.row];

    SCGridViewController *gridViewController = [[SCGridViewController alloc] initWithPicker:self.picker];
    gridViewController.assets = [self assetsInAssetCollection:assetCollection];
    gridViewController.title = assetCollection.localizedTitle;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:gridViewController animated:YES];
}

@end
