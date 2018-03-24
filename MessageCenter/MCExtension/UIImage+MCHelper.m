//
//  UIImage+MCHelper.m
//  MessageCenter
//
//  Created by Rookie on 08/12/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import "UIImage+MCHelper.h"

static const CGFloat badgePadding = 3;
static const CGFloat badgeFontSize = 12;

@implementation UIImage (MCHelper)

+ (instancetype)badgeImageWithNumber:(UInt64)number {
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

- (UIImage *)branding
{
    return [self imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;
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

@end
