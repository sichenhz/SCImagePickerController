//
//  SCImageClipViewController.m
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/24.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCImageClipViewController.h"
#import "UIImage+SCHelper.h"

@interface SCImageClipViewController() <UIScrollViewDelegate>

@property (nonatomic, weak) SCImagePickerController *picker;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic) CGRect clibRect;

@end

@implementation SCImageClipViewController

- (instancetype)initWithPicker:(SCImagePickerController *)picker {
    self.picker = picker;
    if (self = [super init]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.clibRect.origin.x, self.clibRect.origin.y, self.clibRect.size.width, self.clibRect.size.height)];
    self.scrollView.maximumZoomScale = 5;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.scrollView addSubview:self.imageView];
    [[PHCachingImageManager defaultManager] requestImageForAsset:self.asset
                                                      targetSize:self.clibSize
                                                     contentMode:PHImageContentModeAspectFill
                                                         options:nil
                                                   resultHandler:^(UIImage *result, NSDictionary *info) {
                                                       BOOL isDegradedKey = [info[PHImageResultIsDegradedKey] integerValue];
                                                       if (!isDegradedKey) {
                                                           self.imageView.image = result;
                                                           self.imageView.frame = [self centerRectWithSize:result.size containerSize:self.scrollView.frame.size];
                                                           if (self.imageView.frame.size.width < self.clibRect.size.width) {
                                                               self.scrollView.minimumZoomScale = self.clibRect.size.width / self.imageView.frame.size.width;
                                                           } else if (self.imageView.frame.size.height < self.clibSize.height) {
                                                               self.scrollView.minimumZoomScale = self.clibRect.size.height / self.imageView.frame.size.height;
                                                           } else {
                                                               self.scrollView.minimumZoomScale = 1;
                                                           }
                                                           self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
                                                       }
                                                   }];
    
    // mask
    UIImageView *mask = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[@"SCImagePickerController.bundle" stringByAppendingPathComponent:@"photo_rule.png"]]];
    mask.frame = self.scrollView.frame;
    [self.view addSubview:mask];
    UIView *topMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, self.clibRect.origin.y)];
    UIView *bottomMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.clibRect), screenSize.width, topMaskView.frame.size.height)];
    topMaskView.backgroundColor = [UIColor blackColor];
    bottomMaskView.backgroundColor = [UIColor blackColor];
    topMaskView.alpha = 0.7;
    bottomMaskView.alpha = 0.7;
    [self.view addSubview:topMaskView];
    [self.view addSubview:bottomMaskView];

    // button
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.frame = CGRectMake(0, screenSize.height - 120, screenSize.width / 2, 120);
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.view addSubview:cancelButton];
    
    UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectButton addTarget:self action:@selector(selectButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    selectButton.frame = CGRectMake(screenSize.width / 2, screenSize.height - 120, screenSize.width / 2, 120);
    [selectButton setTitle:@"选取" forState:UIControlStateNormal];
    [self.view addSubview:selectButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];    
}

- (void)setClibSize:(CGSize)clibSize {
    _clibSize = clibSize;
    _clibRect = [self centerRectWithSize:clibSize containerSize:[UIScreen mainScreen].bounds.size];
}

#pragma mark - Action

- (void)cancelButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectButtonPressed:(id)sender {
    if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didEditPickingImage:)]) {
        if (self.picker.selectedAssets.count > 0) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHCachingImageManager defaultManager] requestImageForAsset:self.picker.selectedAssets[0]
                                                              targetSize:self.picker.clibSize
                                                             contentMode:PHImageContentModeAspectFill
                                                                 options:options
                                                           resultHandler:^(UIImage *result, NSDictionary *info) {
                                                               BOOL isDegradedKey = [info[PHImageResultIsDegradedKey] integerValue];
                                                               if (!isDegradedKey) {
                                                                   [self.picker.delegate assetsPickerController:self.picker didEditPickingImage:[self clibImage:result]];
                                                               }
                                                           }];
        }
    }
}

#pragma mark - Private Method

- (UIImage *)clibImage:(UIImage *)image {
    CGFloat scale  = self.scrollView.zoomScale;
    CGPoint offset = self.scrollView.contentOffset;
    CGFloat orignalScale = scale * [[UIScreen mainScreen] scale];
    CGPoint orignalOffset = CGPointMake(offset.x * [[UIScreen mainScreen] scale],
                                        offset.y * [[UIScreen mainScreen] scale]);
    CGRect cropRect = CGRectMake(orignalOffset.x, orignalOffset.y, self.clibSize.width, self.clibSize.height);
    UIImage *resultImage = [image crop:cropRect scale:orignalScale];
    return resultImage;
}

- (CGSize)ratioSize:(CGSize)originSize ratio:(CGFloat)ratio {
    return CGSizeMake(originSize.width / ratio, originSize.height / ratio);
}

- (CGRect)centerRectWithSize:(CGSize)imageSize containerSize:(CGSize)containerSize {
    CGFloat heightRatio = imageSize.height / containerSize.height;
    CGFloat widthRatio = imageSize.width / containerSize.width;
    CGSize size = CGSizeZero;
    if (heightRatio > 1 && widthRatio <= 1) {
        size = [self ratioSize:imageSize ratio:heightRatio];
    }
    if (heightRatio <= 1 && widthRatio > 1) {
        size = [self ratioSize:imageSize ratio:widthRatio];
    }
    size = [self ratioSize:imageSize ratio:MAX(heightRatio, widthRatio)];
    CGFloat x = (containerSize.width - size.width) / 2;
    CGFloat y = (containerSize.height - size.height) / 2;
    return CGRectMake(x, y, size.width, size.height);
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
    
    self.imageView.center = actualCenter;
}

@end
