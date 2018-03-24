//
//  UIImage+MCHelper.h
//  MessageCenter
//
//  Created by Rookie on 08/12/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MCExtension)

/**
 Get a number image in badge style

 @param number The number
 @return UIImage
 */
+ (instancetype)mc_badgeImageWithNumber:(UInt64)number;

/**
 Set a image's rendering mode to UIImageRenderingModeAlwaysTemplate

 @return UIImage
 */
- (UIImage *)mc_branding;

/**
 Get a full pure colored image

 @param color The image's color
 @param size The image's size
 @return UIImage
 */
+ (UIImage *)mc_imageWithColor:(UIColor *)color andSize:(CGSize)size;

/**
 Get image in ChatSDKResource.bundle with name

 @param name The image's name
 @return UIImage
 */
+ (UIImage *)mc_imageNamed:(NSString *)name;

/**
 Render a image with color
 
 @param color The render color
 @return UIImage
 */
- (UIImage *)mc_renderImageWithColor:(UIColor *)color;

@end
