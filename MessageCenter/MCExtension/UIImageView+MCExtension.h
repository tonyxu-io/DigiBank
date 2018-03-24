//
//  UIImageView+MCExtension.h
//  DigiBank
//
//  Created by Moxtra on 2017/3/28.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (MCExtension)

/**
 Cut imageView's image to round with radius.
 @discussion This method is implemented in CoreGraphics, compared with maskToBounds, it is more effective.
 
 @param radius The round's raidus
 */
- (void)mc_cutImageToRoundWithRadius:(CGFloat)radius;

/**
 Draw a colored border with raius on imageView

 @param color Border's color
 @param width Border's width
 @param radius Border's radius
 */
- (void)mc_drawRoundBorderWithColor:(UIColor *)color
                              width:(CGFloat)width
                            radius:(CGFloat)radius;
@end
