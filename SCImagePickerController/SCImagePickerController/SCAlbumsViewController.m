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

@interface SCAlbumsViewController() <PHPhotoLibraryChangeObserver>

@property (strong) NSArray *collectionsFetchResults;
@property (strong) NSArray *collectionsFetchResultsAssets;
@property (strong) NSArray *collectionsFetchResultsTitles;
@property (nonatomic, weak) SCImagePickerController *picker;
@property (strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) SCBadgeView *badgeView;

// cameraRollAlbum
@property (nonatomic, copy) NSString *cameraRollTitle;
@property (nonatomic, strong) PHFetchResult* cameraRollResult;

@end

@implementation SCAlbumsViewController

- (instancetype)init {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.title = @"相册";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];

    self.imageManager = [[PHCachingImageManager alloc] init];
    self.tableView.rowHeight = kAlbumThumbnailSize.height + 0.5;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self.picker
                                                                            action:@selector(dismiss:)];
    if (self.picker.allowsMultipleSelection) {
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

    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *userAlbums = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    self.collectionsFetchResults = @[smartAlbums, userAlbums];

    [self updateFetchResults];
    
    if (self.picker.sourceType == SCImagePickerControllerSourceTypeSavedPhotosAlbum) {
        [self pushCameraRollViewController];
    }
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)pushCameraRollViewController {
    if (self.cameraRollTitle && self.cameraRollResult) {
        SCGridViewController *cameraRollViewController = [[SCGridViewController alloc] initWithPicker:[self picker]];
        cameraRollViewController.assetsFetchResults = self.cameraRollResult;
        cameraRollViewController.title = self.cameraRollTitle;
        [self.navigationController pushViewController:cameraRollViewController animated:NO];
    }
}

- (void)updateFetchResults {
    
    self.collectionsFetchResultsAssets = nil;
    self.collectionsFetchResultsTitles = nil;
    
    PHFetchResult *smartAlbums = [self.collectionsFetchResults objectAtIndex:0];
    PHFetchResult *userAlbums = [self.collectionsFetchResults objectAtIndex:1];
    
    //Smart albums
    NSMutableArray *smartFetchResultArray = [[NSMutableArray alloc] init];
    NSMutableArray *smartFetchResultLabel = [[NSMutableArray alloc] init];
    for (PHAssetCollection *collection in smartAlbums) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@", self.picker.mediaTypes];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
        if (assetsFetchResult.count > 0) {
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                [smartFetchResultArray insertObject:assetsFetchResult atIndex:0];
                [smartFetchResultLabel insertObject:collection.localizedTitle atIndex:0];
                self.cameraRollResult = assetsFetchResult;
                self.cameraRollTitle = collection.localizedTitle;
            } else {
                [smartFetchResultArray addObject:assetsFetchResult];
                [smartFetchResultLabel addObject:collection.localizedTitle];
            }
        }
    }

    //User albums
    NSMutableArray *userFetchResultArray = [[NSMutableArray alloc] init];
    NSMutableArray *userFetchResultLabel = [[NSMutableArray alloc] init];
    for (PHCollection *collection in userAlbums) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType in %@", self.picker.mediaTypes];
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            [userFetchResultArray addObject:assetsFetchResult];
            [userFetchResultLabel addObject:collection.localizedTitle];
        }
    }
    
    self.collectionsFetchResultsAssets = @[smartFetchResultArray, userFetchResultArray];
    self.collectionsFetchResultsTitles = @[smartFetchResultLabel, userFetchResultLabel];
}

- (SCImagePickerController *)picker {
    return (SCImagePickerController *)self.navigationController.parentViewController;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.collectionsFetchResultsAssets.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PHFetchResult *fetchResult = self.collectionsFetchResultsAssets[section];
    return fetchResult.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    SCAlbumsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SCAlbumsViewCellReuseIdentifier];
    if (cell == nil) {
        cell = [[SCAlbumsViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SCAlbumsViewCellReuseIdentifier];
    }
    // Increment the cell's tag
    NSInteger currentTag = cell.tag + 1;
    cell.tag = currentTag;

    PHFetchResult *assetsFetchResult = (self.collectionsFetchResultsAssets[indexPath.section])[indexPath.row];
    NSString *text = (self.collectionsFetchResultsTitles[indexPath.section])[indexPath.row];
    NSMutableAttributedString *attrStrM = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:16]}];
    [attrStrM appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%ld)", (long)[assetsFetchResult count]] attributes:@{NSForegroundColorAttributeName : [UIColor grayColor]}]];
    cell.textLabel.attributedText = [attrStrM copy];
    
    if ([assetsFetchResult count] > 0) {
        CGFloat scale = [UIScreen mainScreen].scale;
        PHAsset *asset = assetsFetchResult.lastObject;
        [self.imageManager requestImageForAsset:asset
                                     targetSize:CGSizeMake(self.tableView.rowHeight * scale, self.tableView.rowHeight * scale)
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      if (cell.tag == currentTag) {
                                          cell.thumbnailView.image = result;
                                      }
                                  }];
    } else {
        cell.thumbnailView.image = [UIImage imageNamed:[@"SCImagePickerController.bundle" stringByAppendingPathComponent:@"emptyFolder.png"]];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SCGridViewController *gridViewController = [[SCGridViewController alloc] initWithPicker:[self picker]];
    gridViewController.title = (self.collectionsFetchResultsTitles[indexPath.section])[indexPath.row];
    gridViewController.assetsFetchResults = (self.collectionsFetchResultsAssets[indexPath.section])[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.navigationController pushViewController:gridViewController animated:YES];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // 更新相册
        NSMutableArray *updatedCollectionsFetchResults = nil;
        for (PHFetchResult *collectionsFetchResult in self.collectionsFetchResults) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
            if (changeDetails) {
                if (!updatedCollectionsFetchResults) {
                    updatedCollectionsFetchResults = [self.collectionsFetchResults mutableCopy];
                }
                [updatedCollectionsFetchResults replaceObjectAtIndex:[self.collectionsFetchResults indexOfObject:collectionsFetchResult] withObject:[changeDetails fetchResultAfterChanges]];
            }
        }
        if (updatedCollectionsFetchResults) {
            self.collectionsFetchResults = updatedCollectionsFetchResults;
        }
        
        // 更新图片
        [self updateFetchResults];
        [self.tableView reloadData];        
    });
}

@end
