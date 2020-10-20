//
//  ViewController.m
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/20.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "ViewController.h"
#import "SCImagePickerController.h"
#import "SCImageClipViewController.h"
#import "SCRecordingViewController.h"

@interface ViewController ()<SCImagePickerControllerDelegate, SCImageClipViewControllerDelegate, SCRecordingViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (IBAction)cameraButtonPressed:(id)sender {
    
    SCImagePickerController *picker = [[SCImagePickerController alloc] init];
    picker.delegate = self;
    
    picker.sourceType = SCImagePickerControllerSourceTypeCamera;
    
//    picker.allowsMultipleSelection = YES;
//    picker.maxMultipleCount = 10;

    picker.allowsEditing = YES;
    picker.cropSize = CGSizeMake(750, 750);
    
    picker.modalPresentationStyle = 0;
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)albumsButtonPressed:(id)sender {
    
    SCImagePickerController *picker = [[SCImagePickerController alloc] init];
    picker.delegate = self;
    
    picker.sourceType = SCImagePickerControllerSourceTypeSavedPhotosAlbum;
    
//    picker.allowsMultipleSelection = YES;
//    picker.maxMultipleCount = 10;
    
    picker.allowsEditing = YES;
    picker.cropSize = CGSizeMake(750, 750);
    picker.allowWhiteEdges = YES;

    picker.modalPresentationStyle = 0;
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)recordButtonPressed:(id)sender {
    SCRecordingViewController *recording = [[SCRecordingViewController alloc] init];
    recording.delegate = self;
    recording.modalPresentationStyle = 0;
    [self presentViewController:recording animated:YES completion:nil];
}

#pragma mark - SCImagePickerControllerDelegate

- (void)assetsPickerController:(SCImagePickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"当前选择图片集合 -> %@", assets);
}

- (void)assetsPickerController:(SCImagePickerController *)picker didFinishPickingImage:(UIImage *)image {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"当前编辑图片 -> %@", image);
    self.imageView.image = image;
}

- (void)assetsPickerControllerDidCancel:(SCImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"结束选择图片");
}

- (void)assetsPickerVontrollerDidOverrunMaxMultipleCount:(SCImagePickerController *)picker {
    NSLog(@"超过最大可选数量 -> %zd", picker.maxMultipleCount);
}

#pragma mark - SCImageClipViewControllerDelegate

- (void)clipViewControllerDidCancel:(SCImageClipViewController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clipViewController:(SCImageClipViewController *)picker didFinishClipImage:(UIImage *)image {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"当前编辑图片 -> %@", image);
        self.imageView.image = image;
    }];
}

#pragma mark - SCImageClipViewControllerDelegate

- (void)assetsPickerController:(SCRecordingViewController *)picker didFinishPickingVideoUrl:(NSURL *)videoUrl {
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"当前录制视频地址 -> %@", videoUrl);
        
        AVPlayer *player = [AVPlayer playerWithURL:videoUrl];
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        playerLayer.frame = CGRectMake(0, 40, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.width);
        [self.view.layer addSublayer:playerLayer];
        [player play];
    }];
}

@end
