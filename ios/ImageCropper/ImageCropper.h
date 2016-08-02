//
//  ImageCropper.h
//  ImageCropper
//
//  Created by Witz Hsiao on 8/1/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#ifndef RN_IMAGE_CROPPER_h
#define RN_IMAGE_CROPPER_h

#import <Foundation/Foundation.h>
#import <RSKImageCropper/RSKImageCropper.h>
#import "RCTBridgeModule.h"

@interface ImageCropper : NSObject<
RCTBridgeModule,
RSKImageCropViewControllerDelegate,
RSKImageCropViewControllerDataSource>

@property (nonatomic, strong) RCTPromiseResolveBlock resolve;
@property (nonatomic, strong) RCTPromiseRejectBlock reject;

@property (nonatomic, strong) float width;
@property (nonatomic, strong) float height;


@end

#endif