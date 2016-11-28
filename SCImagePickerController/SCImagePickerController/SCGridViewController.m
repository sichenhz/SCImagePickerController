//
//  SCGridViewController.m
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/20.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCGridViewController.h"
#import "SCImagePickerController.h"
#import "SCCameraViewController.h"
#import "SCGridViewCell.h"
#import "SCCameraViewCell.h"
#import "SCBadgeView.h"

// Helper methods
@implementation NSIndexSet (Convenience)

- (NSArray *)aapl_indexPathsFromIndexesWithSection:(NSUInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    return indexPaths;
}

@end

@implementation UICollectionView (Convenience)

- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect {
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}

@end

@interface SCGridViewController()

@property (nonatomic, weak) SCImagePickerController *picker;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) SCBadgeView *badgeView;
@property (nonatomic) CGRect previousPreheatRect;

@end

static CGSize AssetGridThumbnailSize;
static NSInteger const NumberOfColumns = 3;
static CGFloat const InteritemSpacing = 1.0;
static NSString * const SCGridViewCellIdentifier = @"SCGridViewCellIdentifier";
static NSString * const SCCameraViewCellIdentifier = @"SCCameraViewCellIdentifier";

@implementation SCGridViewController
{
    CGFloat screenWidth;
    CGFloat screenHeight;
}

#pragma mark - Life Cycle

- (instancetype)initWithPicker:(SCImagePickerController *)picker {
    //Custom init. The picker contains custom information to create the FlowLayout
    self.picker = picker;
    
    screenWidth = CGRectGetWidth(picker.view.bounds);
    screenHeight = CGRectGetHeight(picker.view.bounds);
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = InteritemSpacing;
    NSInteger cellTotalUsableWidth = screenWidth - (NumberOfColumns - 1) * InteritemSpacing;
    layout.itemSize = CGSizeMake(cellTotalUsableWidth / NumberOfColumns, cellTotalUsableWidth / NumberOfColumns);
    CGFloat cellTotalUsedWidth = layout.itemSize.width * NumberOfColumns;
    CGFloat spaceTotalWidth = screenWidth - cellTotalUsedWidth;
    CGFloat spaceWidth = spaceTotalWidth / (NumberOfColumns - 1);
    layout.minimumLineSpacing = spaceWidth;

    if (self = [super initWithCollectionViewLayout:layout]) {
        CGFloat scale = [UIScreen mainScreen].scale;
        AssetGridThumbnailSize = CGSizeMake(layout.itemSize.width * scale, layout.itemSize.height * scale);
        self.collectionView.allowsMultipleSelection = picker.allowsMultipleSelection;
        [self.collectionView registerClass:SCGridViewCell.class
                forCellWithReuseIdentifier:SCGridViewCellIdentifier];
        [self.collectionView registerClass:SCCameraViewCell.class
                forCellWithReuseIdentifier:SCCameraViewCellIdentifier];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageManager = [[PHCachingImageManager alloc] init];
    [self resetCachedAssets];

    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(1, 0, 1, 0);

    if (self.picker.allowsMultipleSelection) {
        UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                                           style:UIBarButtonItemStyleDone
                                                                          target:self.picker
                                                                          action:@selector(finishPickingAssets)];
        doneButtonItem.enabled = self.picker.selectedAssets.count > 0;
        
        self.badgeView = [[SCBadgeView alloc] init];
        self.badgeView.number = self.picker.selectedAssets.count;
        UIBarButtonItem *badgeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.badgeView];
        
        self.navigationItem.rightBarButtonItems = @[doneButtonItem, badgeButtonItem];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Begin caching assets in and around collection view's visible rect.
    [self updateCachedAssets];
}

#pragma mark - Private Method

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        if (indexPath.item == 0) {
            continue;
        }
        PHAsset *asset = self.assets[indexPath.item - 1];
        [assets addObject:asset];
    }
    
    return assets;
}

#pragma mark - Asset Caching

- (void)resetCachedAssets {
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets {
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:AssetGridThumbnailSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:AssetGridThumbnailSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        self.previousPreheatRect = preheatRect;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1 + self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item == 0) {
        
        SCCameraViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SCCameraViewCellIdentifier forIndexPath:indexPath];
        
        return cell;
        
    } else {
        
        PHAsset *asset = self.assets[indexPath.item - 1];
        
        // Dequeue an SCGridViewCell.
        SCGridViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SCGridViewCellIdentifier forIndexPath:indexPath];
        cell.representedAssetIdentifier = asset.localIdentifier;
        
        // Request an image for the asset from the PHCachingImageManager.
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        [self.imageManager requestImageForAsset:asset
                                     targetSize:AssetGridThumbnailSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:options
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      // Set the cell's thumbnail image if it's still showing the same asset.
                                      if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                          cell.thumbnailView.image = result;
                                      }
                                  }];
        
        cell.allowsSelection = self.picker.allowsMultipleSelection;
        if ([self.picker.selectedAssets containsObject:asset]) {
            cell.selected = YES;
            [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        } else {
            cell.selected = NO;
        }
        
        return cell;
        
    }
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {
        
        return YES;
        
    } else {
        
        if (self.picker.maxMultipleCount > 0 && self.picker.maxMultipleCount == self.picker.selectedAssets.count) {
            if ([self.picker.delegate respondsToSelector:@selector(assetsPickerControllerDidOverrunMaxMultipleCount:)]) {
                [self.picker.delegate assetsPickerControllerDidOverrunMaxMultipleCount:self.picker];
            }
            return NO;
        } else {
            return YES;
        }
        
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {

        if (self.picker.childViewControllers.count == 2) {
            SCCameraViewController *camera = self.picker.childViewControllers.lastObject;
            [camera removeFromParentViewController];
            [self.picker setNeedsStatusBarAppearanceUpdate];
            [UIView animateWithDuration:0.3 animations:^{
                CGRect frame = camera.view.frame;
                frame.origin.y = frame.size.height;
                camera.view.frame = frame;
            } completion:^(BOOL finished) {
                [camera.view removeFromSuperview];
            }];
        } else {
            SCCameraViewController *camera = [[SCCameraViewController alloc] initWithPicker:self.picker];
            [camera willMoveToParentViewController:self.picker];
            [camera.view setFrame:self.picker.view.frame];
            __block CGRect frame = camera.view.frame;
            frame.origin.y = frame.size.height;
            camera.view.frame = frame;
            [UIView animateWithDuration:0.3 animations:^{
                frame.origin.y = 0;
                camera.view.frame = frame;
            } completion:^(BOOL finished) {
                [self.picker setNeedsStatusBarAppearanceUpdate];
            }];
            [self.picker.view addSubview:camera.view];
            [self.picker addChildViewController:camera];
            [camera didMoveToParentViewController:self];
        }
        
    } else {
        
        PHAsset *asset = self.assets[indexPath.item - 1];
        [self.picker selectAsset:asset];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {
        
    } else {
        
        PHAsset *asset = self.assets[indexPath.item - 1];
        [self.picker deselectAsset:asset];
        
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update cached assets for the new visible area.
    [self updateCachedAssets];
}

@end
