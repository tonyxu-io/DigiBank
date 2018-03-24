//
//  UIImage+MCHelper.m
//  MessageCenter
//
//  Created by Rookie on 08/12/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import "UIImage+MCExtension.h"

static const CGFloat badgePadding = 3;
static const CGFloat badgeFontSize = 12;

@implementation UIImage (MCExtension)

+ (instancetype)mc_badgeImageWithNumber:(UInt64)number {
    NSString *badge = number > 99 ? @"99+" : @(number).description;
    
    NSMutableParagraphStyle *badgeParagraphStyle = [NSMutableParagraphStyle new];
    badgeParagraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *badgeAttr = @{NSFontAttributeName: [UIFont systemFontOfSize:badgeFontSize], NSForegroundColorAttributeName: [UIColor whiteColor], NSParagraphStyleAttributeName: badgeParagraphStyle};
    CGSize textSize = [badge boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:badgeAttr
                                          context:nil].size;
    CGFloat badgeHeight = textSize.height + 2 * badgePadding;
    CGFloat badgeWidth = MAX(badgeHeight, textSize.width + 2 * badgePadding);
    CGRect badgeRect = CGRectMake(0, 0, badgeWidth, badgeHeight);
    
    UIGraphicsBeginImageContextWithOptions(badgeRect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddRect(context, badgeRect);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillPath(context);
    
    CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:badgeRect cornerRadius:badgeHeight/2].CGPath;
    CGContextAddPath(context, path);
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextFillPath(context);
    
    [badge drawInRect:CGRectOffset(badgeRect, 0, badgePadding) withAttributes:badgeAttr];
    UIImage *badgeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return badgeImage;
}

- (UIImage *)mc_branding;
{
    return [self imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (UIImage *)mc_imageWithColor:(UIColor *)color andSize:(CGSize)size;
{
    UIImage *img = nil;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   color.CGColor);
    CGContextFillRect(context, rect);
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

+ (UIImage *)mc_imageNamed:(NSString *)name
{
    NSString *relativeName = [NSString stringWithFormat:@"ChatSDKResource.bundle/%@", name];
    return [UIImage imageNamed:relativeName];
}

- (UIImage *)mc_renderImageWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
