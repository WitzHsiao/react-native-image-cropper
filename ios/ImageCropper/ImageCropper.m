//
//  ImageCropper.m
//  ImageCropper
//
//  Created by Witz Hsiao on 8/1/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "ImageCropper.h"

@implementation ImageCropper {
  float _width,
  float _height
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(open:(NSString *)uri
                  width:(float)width
                  height:(float)height)
{
  UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:uri]];
  RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image cropMode:RSKImageCropModeCustom];
  imageCropVC.dataSource = self;
  imageCropVC.delegate = self;
  _width = width;
  _height = height;
  
  UIViewController *root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
  dispatch_async(dispatch_get_main_queue(), ^{
    if (root.presentedViewController) {
      [root.presentedViewController presentViewController:imageCropVC animated:YES completion:nil];
    } else {
      [root presentViewController:imageCropVC animated:YES completion:nil];
    }
  });
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
  [controller dismissViewControllerAnimated:YES completion:nil];
//  self.imageView.image = croppedImage;
//  [self.navigationController popViewControllerAnimated:YES];
}

// The original image has been cropped. Additionally provides a rotation angle used to produce image.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
                  rotationAngle:(CGFloat)rotationAngle
{
  [controller dismissViewControllerAnimated:YES completion:nil];
//  self.imageView.image = croppedImage;
//  [self.navigationController popViewControllerAnimated:YES];
}

//// The original image will be cropped.
//- (void)imageCropViewController:(RSKImageCropViewController *)controller
//                  willCropImage:(UIImage *)originalImage
//{
//  // Use when `applyMaskToCroppedImage` set to YES.
//  [SVProgressHUD show];
//}

#pragma mark - RSKImageCropViewControllerDataSource

// Returns a custom rect in which the image can be moved.
- (CGRect)imageCropViewControllerCustomMovementRect:(RSKImageCropViewController *)controller
{
  // If the image is not rotated, then the movement rect coincides with the mask rect.
  return controller.maskRect;
}

// Returns a custom rect for the mask.
- (CGRect)imageCropViewControllerCustomMaskRect:(RSKImageCropViewController *)controller
{
  CGSize maskSize = CGSizeMake(200*_width, 200*_height);
  
  CGFloat viewWidth = CGRectGetWidth(controller.view.frame);
  CGFloat viewHeight = CGRectGetHeight(controller.view.frame);
  
  CGRect maskRect = CGRectMake((viewWidth - maskSize.width) * 0.5f,
                               (viewHeight - maskSize.height) * 0.5f,
                               maskSize.width,
                               maskSize.height);
  
  return maskRect;
}

@end
