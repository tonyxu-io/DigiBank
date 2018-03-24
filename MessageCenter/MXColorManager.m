//
//  MXColorManager.m
//  Agent
//
//  Created by Rookie on 16/02/2017.
//  Copyright © 2017 moxtra. All rights reserved.
//

#import "MXColorManager.h"

@implementation MXColorManager

+ (BOOL)isLightColor:(UIColor *)color;
{
    CGFloat colorBrightness = 0;
    
    CGColorSpaceRef colorSpace = CGColorGetColorSpace(color.CGColor);
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorSpace);
    
    if(colorSpaceModel == kCGColorSpaceModelRGB){
        
        const CGFloat *componentColors = CGColorGetComponents(color.CGColor);
        colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
    }
    else{
        [color getWhite:&colorBrightness alpha:0];
    }
    
    return (colorBrightness >= 0.75f);
}


+ (UIColor *)moxtraColorWithHex:(NSInteger)hex alpha:(CGFloat)alpha
{
    return [[UIColor alloc] initWithRed:(((hex >> 16) & 0xff) / 255.0f) green:(((hex >> 8) & 0xff) / 255.0f) blue:(((hex) & 0xff) / 255.0f) alpha:alpha];
}

+ (UIColor *)moxtraColorWithHexString:(NSString *)hexString
{
    if(hexString.length == 0)
        return nil;
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (UIColor *)moxtraBrandingColor;
{
    return [UIColor colorWithRed:65/255.f green:180/255.f blue:100/255.f alpha:1];
}

+ (UIColor *)moxtraBrandingForegroundColor;
{
    return [self moxtraWhiteColor];
}

+ (UIColor *)moxtraMeetColor;
{
    return [self moxtraOrangeColor];
}

+ (UIColor *)moxtraMeetForegroundColor;
{
    return [self moxtraWhiteColor];
}

+ (UIColor *)moxtraNavBarColor;
{
    return [UIColor colorWithRed:247.0f/255.0f green:247.0f/255.0f blue:247.0f/255.0f alpha:1.0f];
}

+ (UIColor *)moxtraNavBarForegroundColor;
{
    return [self moxtraWhiteColor];
}

+ (UIColor *)moxtraAlertColor;
{
    return [self moxtraColorWithHex:0xFF3300 alpha:1.0f];
}

+ (UIColor *)moxtraFavoriteColor;
{
    return [self moxtraColorWithHex:0xFFCC00 alpha:1.0f];
}

+ (UIColor *)moxtraPresenceColor;
{
    return [self moxtraColorWithHex:0x669900 alpha:1.0f];
}

+ (UIColor *)moxtraWhiteColor;
{
    return [self moxtraColorWithHex:0xFFFFFF alpha:1.0f];
}

+ (UIColor *)moxtraGray04Color;
{
    return [self moxtraColorWithHex:0xF0F0F5 alpha:0.9f];
}

+ (UIColor *)moxtraGray08Color;
{
    return [self moxtraColorWithHex:0xE6E6EB  alpha:1.0f];
}

+ (UIColor *)moxtraGray20Color;
{
    return [self moxtraColorWithHex:0xC8C8CC alpha:1.0f];
}

+ (UIColor *)moxtraGray40Color;
{
    return [self moxtraColorWithHex:0x969699 alpha:1.0f];
}

+ (UIColor *)moxtraGray60Color;
{
    return [self moxtraColorWithHex:0x646466 alpha:1.0f];
}

+ (UIColor *)moxtraBlackColor;
{
    return [self moxtraColorWithHex:0x191919 alpha:1.0f];
}

+ (UIColor *)moxtraRedColor;
{
    return [self moxtraColorWithHex:0xC62828 alpha:1.0f];
}

+ (UIColor *)moxtraBlueColor;
{
    return [self moxtraColorWithHex:0x2D9CF5 alpha:1.0f];
}

+ (UIColor *)moxtraCallViewBackgroundColor
{
    return [self moxtraColorWithHex:0x387FB7 alpha:1.0f];
}

+ (UIColor *)moxtraGreenColor;
{
    return [self moxtraColorWithHex:0x00C853 alpha:1.0f];
}

+ (UIColor *)moxtraOrangeColor
{
    return [self moxtraColorWithHex:0xFF7043 alpha:1.0f];
}

+ (UIColor *)moxtraFeedIncomingColor;
{
    return [self moxtraGray08Color];
}

+ (UIColor *)moxtraFeedOutgoingColor;
{
    return [self moxtraGreenColor];
}

+ (UIColor *)moxtraFeedOutgoingInternalColor;
{
    return [self moxtraBrandingColor];
}

+ (UIColor *)moxtraGrayColor;
{
    return [self moxtraGray40Color];;
}

+ (UIColor *)moxtraDarkGrayColor;
{
    return [self moxtraGray60Color];
}

+ (UIColor *)moxtraLightGrayColor;
{
    return [self moxtraGray20Color];
}

+ (UIColor *)moxtraBadgeColor;
{
    return  [UIColor colorWithRed:1.0 green:0.22 blue:0.14 alpha:1.0];
}

+ (UIColor *)moxtraPageTextureColor
{
    return [self moxtraDarkGrayColor];
}

+ (UIColor *)moxtraTableViewBackground;
{
    return [UIColor groupTableViewBackgroundColor];
}

+ (UIColor *)moxtraViewBackgroundColor;
{
    return [self moxtraGray04Color];
}

+ (UIColor *)operationTextLabelColor;
{
    return [UIColor blackColor];
}

+ (UIColor *)operationDetailTextLabelColor;
{
    return [UIColor darkGrayColor];
}


@end
