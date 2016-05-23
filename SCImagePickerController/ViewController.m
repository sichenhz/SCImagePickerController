//
//  ViewController.m
//  SCImagePickerController
//
//  Created by sichenwang on 16/5/20.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "ViewController.h"
#import "SCImagePickerController.h"

@interface ViewController ()<SCImagePickerControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startButtonPressed:(id)sender {
    SCImagePickerController *picker = [[SCImagePickerController alloc] init];
    picker.delegate = self;
    
    picker.sourceType = SCImagePickerControllerSourceTypeCamera;
    
    picker.allowsMultipleSelection = YES;
    picker.maxMultipleCount = 5;
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - SCImagePickerControllerDelegate

- (void)assetsPickerController:(SCImagePickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"当前选择图片 -> %@", assets);
}

- (void)assetsPickerControllerDidCancel:(SCImagePickerController *)picker {
    NSLog(@"结束选择图片");
}

- (void)assetsPickerVontrollerDidOverrunMaxMultipleCount:(SCImagePickerController *)picker {
    NSLog(@"超过最大可选数量 -> %zd", picker.maxMultipleCount);
}

@end
