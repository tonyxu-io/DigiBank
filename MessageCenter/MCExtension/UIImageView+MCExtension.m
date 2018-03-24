//
//  UIImageView+MCExtension.m
//  DigiBank
//
//  Created by Moxtra on 2017/3/28.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "UIImageView+MCExtension.h"

@implementation UIImageView (MCExtension)

#pragma mark - Public Method

- (void)mc_cutImageToRoundWithRadius:(CGFloat)radius
{
    if (self.image)
    {
        self.image = [self mc_reDrawToRoundWithImage:self.image inRadius:radius];
    }
}

#pragma mark - Private Method

-(void)mc_drawRoundBorderWithColor:(UIColor *)color
                             width:(CGFloat)width
                            radius:(CGFloat)radius
{
    [color set];
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetLineJoin(currentContext, kCGLineJoinRound);
    CGContextSetLineWidth(currentContext,width);
    CGContextAddArc(currentContext, self.center.x, self.center.y, radius, 0, 2*M_PI, 1);
    CGContextStrokePath(currentContext);
}



- (UIImage *)mc_reDrawToRoundWithImage:(UIImage *)image inRadius:(CGFloat)radius
{
    CGRect rect = CGRectMake(0, 0, radius, radius);
    UIGraphicsBeginImageContextWithOptions(rect.size, false, [[UIScreen mainScreen] scale]);
    UIBezierPath *roundPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    CGContextAddPath(UIGraphicsGetCurrentContext(), roundPath.CGPath);
    CGContextClip(UIGraphicsGetCurrentContext());
    [image drawInRect:rect];
    CGContextDrawPath(UIGraphicsGetCurrentContext(), kCGPathFillStroke);
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output;
}

@end
