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

@property (nonatomic, strong) UIImage *image;
@property (nonatomic) CGSize cropSize;

@end

@implementation SCImageClipViewController

#pragma mark - Life Cycle

- (instancetype)initWithImage:(UIImage *)image picker:(SCImagePickerController *)picker {
    self.picker = picker;
    self.image = image;
    self.cropSize = picker.cropSize;
    self.allowWhiteEdges = picker.isAllowedWhiteEdges;
    if (self = [super init]) {
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image cropSize:(CGSize)cropSize {
    self.image = image;
    self.cropSize = cropSize;
    if (self = [super init]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;

    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.clipsToBounds = NO;
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
    
    if (self.picker && !self.image) {
        PHAsset *asset = self.picker.selectedAssets.firstObject;
        [[PHCachingImageManager defaultManager] requestImageForAsset:asset
                                                          targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)
                                                         contentMode:PHImageContentModeDefault
                                                             options:nil
                                                       resultHandler:^(UIImage *result, NSDictionary *info) {
                                                           if (result) {
                                                               // 这里会调多次，需重置transform得出正确的frame
                                                               self.imageView.transform = CGAffineTransformIdentity;
                                                               [self configureImage:result];
                                                           }
                                                       }];
    } else {
        [self configureImage:self.image];
    }
    
    // mask
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (!self.isPreview) {
        UIImageView *mask = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[@"SCImagePickerController.bundle" stringByAppendingPathComponent:@"photo_rule.png"]]];
        mask.frame = self.scrollView.frame;
        [self.view addSubview:mask];
        
        UIView *topMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, self.scrollView.frame.origin.y)];
        UIView *bottomMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scrollView.frame), screenSize.width, topMaskView.frame.size.height)];
        topMaskView.backgroundColor = [UIColor blackColor];
        bottomMaskView.backgroundColor = [UIColor blackColor];
        topMaskView.alpha = 0.7;
        bottomMaskView.alpha = 0.7;
        [self.view addSubview:topMaskView];
        [self.view addSubview:bottomMaskView];
    }

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

#pragma mark - Action

- (void)cancelButtonPressed:(UIButton *)button {
    if (self.picker) {
        if (self.image) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        } else {
            [self.picker.selectedAssets removeObjectAtIndex:0];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(clipViewControllerDidCancel:)]) {
            [self.delegate clipViewControllerDidCancel:self];
        }
    }
}

- (void)selectButtonPressed:(UIButton *)button {
    UIImage *image = self.isPreview ? self.imageView.image : [self clibImage:self.imageView.image];
    if (self.picker) {
        if ([self.picker.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingImage:)]) {
            [self.picker.delegate assetsPickerController:self.picker didFinishPickingImage:image];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(clipViewController:didFinishClipImage:)]) {
            [self.delegate clipViewController:self didFinishClipImage:image];
        }
    }
}

#pragma mark - Private Method

- (void)configureImage:(UIImage *)image {
    
    CGSize contentSize = self.isPreview ? image.size : self.cropSize;
    self.scrollView.frame = [self centerFitRectWithContentSize:contentSize containerSize:[UIScreen mainScreen].bounds.size];
    
    self.imageView.image = image;
    [self.imageView sizeToFit];
    CGFloat scaleWidth = self.scrollView.frame.size.width / self.imageView.frame.size.width;
    CGFloat scaleHeight = self.scrollView.frame.size.height / self.imageView.frame.size.height;
    if (self.imageView.frame.size.width <= self.scrollView.frame.size.width ||
        self.imageView.frame.size.height <= self.scrollView.frame.size.height) {
        self.scrollView.maximumZoomScale = MAX(scaleWidth, scaleHeight);
    } else {
        self.scrollView.maximumZoomScale = 1;
    }

    if (self.isAllowedWhiteEdges) {
        self.scrollView.minimumZoomScale = MIN(scaleWidth, scaleHeight);
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    } else {
        self.scrollView.minimumZoomScale = MAX(scaleWidth, scaleHeight);
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        
        if ((image.size.height / image.size.width) > (self.cropSize.height / self.cropSize.width)) {
            self.scrollView.contentOffset = CGPointMake(0, (image.size.height * self.scrollView.zoomScale - self.scrollView.frame.size.height) / 2);
        } else {
            self.scrollView.contentOffset = CGPointMake((image.size.width * self.scrollView.zoomScale - self.scrollView.frame.size.width) / 2, 0);
        }
    }
}

- (void)setCropSize:(CGSize)cropSize {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (CGSizeEqualToSize(cropSize, CGSizeZero)) {
        _cropSize = CGSizeMake(screenSize.width, screenSize.width);
    } else {
        _cropSize = cropSize;
    }
}

- (UIImage *)clibImage:(UIImage *)image {
    CGFloat scale  = self.scrollView.zoomScale;

    // offset
    CGFloat offsetX = -self.scrollView.contentOffset.x;
    CGFloat offsetY = -self.scrollView.contentOffset.y;
    // distance from edge to content
    if (self.scrollView.bounds.size.width - self.scrollView.contentSize.width > 0) {
        offsetX = (self.scrollView.bounds.size.width - self.scrollView.contentSize.width) / 2;
    }
    if (self.scrollView.bounds.size.height - self.scrollView.contentSize.height > 0) {
        offsetY = (self.scrollView.bounds.size.height - self.scrollView.contentSize.height) / 2;
    }
    
    CGFloat scrollViewScale;
    if (self.cropSize.height / self.cropSize.width <= self.scrollView.frame.size.height / self.scrollView.frame.size.width) {
        scrollViewScale = self.cropSize.width / (self.scrollView.frame.size.width * [[UIScreen mainScreen] scale]);
    } else {
        scrollViewScale = self.cropSize.height / (self.scrollView.frame.size.height * [[UIScreen mainScreen] scale]);
    }
    CGFloat orignalScale = scale * [[UIScreen mainScreen] scale] * scrollViewScale;
    CGPoint orignalOffset = CGPointMake(offsetX * [[UIScreen mainScreen] scale] * scrollViewScale,
                                        offsetY * [[UIScreen mainScreen] scale] * scrollViewScale);
    CGRect cropRect = CGRectMake(orignalOffset.x, orignalOffset.y, self.cropSize.width, self.cropSize.height);
    UIImage *resultImage = [image sc_crop:cropRect scale:orignalScale];
    return resultImage;
}

- (CGRect)centerFitRectWithContentSize:(CGSize)contentSize containerSize:(CGSize)containerSize {
    CGFloat heightRatio = contentSize.height / containerSize.height;
    CGFloat widthRatio = contentSize.width / containerSize.width;
    CGSize size = CGSizeZero;
    if (heightRatio > 1 && widthRatio <= 1) {
        size = [self ratioSize:contentSize ratio:heightRatio];
    } else if (heightRatio <= 1 && widthRatio > 1) {
        size = [self ratioSize:contentSize ratio:widthRatio];
    } else {
        size = [self ratioSize:contentSize ratio:MAX(heightRatio, widthRatio)];
    }
    CGFloat x = (containerSize.width - size.width) / 2;
    CGFloat y = (containerSize.height - size.height) / 2;
    return CGRectMake(x, y, size.width, size.height);
}

- (CGSize)ratioSize:(CGSize)originSize ratio:(CGFloat)ratio {
    return CGSizeMake(originSize.width / ratio, originSize.height / ratio);
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
