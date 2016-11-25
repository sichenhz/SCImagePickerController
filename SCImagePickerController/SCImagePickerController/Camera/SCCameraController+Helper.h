//
//  SCCameraController+Helper.h
//  SCImagePickerController
//
//  Created by sichenwang on 2016/11/24.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCCameraController.h"

@interface SCCameraController (Helper)

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
                                          previewLayer:(AVCaptureVideoPreviewLayer *)previewLayer
                                                 ports:(NSArray<AVCaptureInputPort *> *)ports;

- (UIImage *)cropImage:(UIImage *)image usingPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer;


@end
