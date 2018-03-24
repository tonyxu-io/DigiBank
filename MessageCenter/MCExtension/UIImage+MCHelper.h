//
//  UIImage+MCHelper.h
//  MessageCenter
//
//  Created by Rookie on 08/12/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MCHelper)

+ (instancetype)badgeImageWithNumber:(UInt64)number;
- (UIImage *)branding;
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;
+ (UIImage *)mc_imageNamed:(NSString *)name;
@end
