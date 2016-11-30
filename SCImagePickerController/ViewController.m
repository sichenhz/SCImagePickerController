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

@interface ViewController ()<SCImagePickerControllerDelegate, SCImageClipViewControllerDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 200, 200)];
    [self.view addSubview:self.imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startButtonPressed:(id)sender {
    
    SCImagePickerController *picker = [[SCImagePickerController alloc] init];
    picker.delegate = self;
    
    picker.sourceType = SCImagePickerControllerSourceTypeCamera;
    
//    picker.allowsMultipleSelection = YES;
//    picker.maxMultipleCount = 10;

    picker.allowsEditing = YES;
    picker.cropSize = CGSizeMake(750, 750);
    
    [self presentViewController:picker animated:YES completion:nil];

//    SCImageClipViewController *clipViewController = [[SCImageClipViewController alloc] initWithImage:[UIImage imageNamed:@"IMG_4034.jpg"] cropSize:CGSizeMake(750, 750)];
//    clipViewController.delegate = self;
//    [self presentViewController:clipViewController animated:YES completion:nil];
}

- (IBAction)albumsButtonPressed:(id)sender {
    SCImagePickerController *picker = [[SCImagePickerController alloc] init];
    picker.delegate = self;
    
    picker.sourceType = SCImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    picker.allowsMultipleSelection = YES;
    picker.maxMultipleCount = 10;
    
    picker.allowsEditing = YES;
    picker.cropSize = CGSizeMake(750, 750);
    
    [self presentViewController:picker animated:YES completion:nil];
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

@end
