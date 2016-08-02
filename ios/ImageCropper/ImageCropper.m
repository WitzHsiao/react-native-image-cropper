//
//  ImageCropper.m
//  ImageCropper
//
//  Created by Witz Hsiao on 8/1/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "ImageCropper.h"

@implementation ImageCropper
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(open:(NSString *)uri
                  width:(float)width
                  height:(float)height
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  _width = width;
  _height = height;
  _resolve = resolve;
  _reject = reject;
  
  UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:uri]]];
  RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image cropMode:RSKImageCropModeCustom];
  imageCropVC.dataSource = self;
  imageCropVC.delegate = self;
  
  UIViewController *root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
  dispatch_async(dispatch_get_main_queue(), ^{
    if (root.presentedViewController) {
      [root.presentedViewController presentViewController:imageCropVC animated:YES completion:nil];
    } else {
      [root presentViewController:imageCropVC animated:YES completion:nil];
    }
  });
}

// at the moment it is not possible to upload image by reading PHAsset
// we are saving image and saving it to the tmp location where we are allowed to access image later
- (NSString*) persistFile:(NSData*)data {
  // create temp file
  NSString *filePath = [NSTemporaryDirectory() stringByAppendingString:[[NSUUID UUID] UUIDString]];
  filePath = [filePath stringByAppendingString:@".jpg"];
  
  // save cropped file
  BOOL status = [data writeToFile:filePath atomically:YES];
  if (!status) {
    return nil;
  }
  
  return filePath;
}

#pragma mark - RSKImageCropViewControllerDelegate

// Crop image has been canceled.
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
  [controller dismissViewControllerAnimated:YES completion:nil];
}

// The original image has been cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
{
  NSString *filePath = [self persistFile:UIImagePNGRepresentation(croppedImage)];
  if (filePath == nil) {
    self.reject(@"error", @"Cannot save image. Unable to write to tmp location.", nil);
    return;
  }
  
  NSDictionary *image = @{
                          @"uri": filePath,
                          @"width": @(croppedImage.size.width),
                          @"height": @(croppedImage.size.height),
                          };
  
  self.resolve(image);
  [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - RSKImageCropViewControllerDataSource

// Returns a custom rect in which the image can be moved.
- (CGRect)imageCropViewControllerCustomMovementRect:(RSKImageCropViewController *)controller
{
  // If the image is not rotated, then the movement rect coincides with the mask rect.
  return controller.maskRect;
}

// Returns a custom path for the mask.
- (UIBezierPath *)imageCropViewControllerCustomMaskPath:(RSKImageCropViewController *)controller
{
  CGRect rect = controller.maskRect;
  CGPoint point1 = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
  CGPoint point2 = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
  CGPoint point3 = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
  CGPoint point4 = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
  
  UIBezierPath *rectangle = [UIBezierPath bezierPath];
  [rectangle moveToPoint:point1];
  [rectangle addLineToPoint:point2];
  [rectangle addLineToPoint:point3];
  [rectangle addLineToPoint:point4];
  [rectangle closePath];
  
  return rectangle;
}

// Returns a custom rect for the mask.
- (CGRect)imageCropViewControllerCustomMaskRect:(RSKImageCropViewController *)controller
{
  CGFloat viewWidth = CGRectGetWidth(controller.view.frame);
  CGFloat viewHeight = CGRectGetHeight(controller.view.frame);
  
  CGSize maskSize;
  int baseRectSize = 0;
  
  if (_height > _width)
  {
    baseRectSize = viewHeight * 0.6 *1.2;
    maskSize = CGSizeMake(baseRectSize*0.65, baseRectSize);
  }
  else
  {
    baseRectSize = viewWidth * 0.8 *1.2;
    maskSize = CGSizeMake(baseRectSize, baseRectSize*0.65);
  }
  
  CGRect maskRect = CGRectMake((viewWidth - maskSize.width) * 0.5f,
                               (viewHeight - maskSize.height) * 0.5f,
                               maskSize.width,
                               maskSize.height);
  
  return maskRect;
}

@end