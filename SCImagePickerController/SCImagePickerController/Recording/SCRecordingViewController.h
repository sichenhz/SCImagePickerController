//
//  SCRecordingViewController.h
//  SCImagePickerController
//
//  Created by sichenwang on 2016/11/23.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

@import UIKit;
@import Photos;
@class SCRecordingViewController;

@protocol SCRecordingViewControllerDelegate <NSObject>

@optional

/** This method is called when a video is selected. */
- (void)assetsPickerController:(SCRecordingViewController *)picker didFinishPickingVideoUrl:(NSURL *)videoUrl;
/** This method is called when imagePicker has canceled. */
- (void)assetsPickerControllerDidCancel:(SCRecordingViewController *)picker;

@end

@interface SCRecordingViewController : UIViewController

@property (nonatomic, weak) id<SCRecordingViewControllerDelegate> delegate;

@end
