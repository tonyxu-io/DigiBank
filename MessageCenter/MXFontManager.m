//
//  MXFontManager.m
//  Agent
//
//  Created by Rookie on 16/02/2017.
//  Copyright © 2017 moxtra. All rights reserved.
//

#import "MXFontManager.h"
#import <objc/runtime.h>

@implementation MXFontManager

+ (void)registerFonts
{
}

+ (UIFont *)operationTextLabelFont;
{
    return [self moxtraRegularFontWithSize:15];
}

+ (UIFont *)operationDetailTextLabelFont;
{
    return [self moxtraRegularFontWithSize:15];
}

+ (UIFont *)moxtraRegularFontWithSize:(CGFloat)size;
{
    return [UIFont systemFontOfSize:size];
}

+ (UIFont *)moxtraLightFontWithSize:(CGFloat)size;
{
    return [UIFont systemFontOfSize:size];
}

+ (void)replaceSystemFont
{
    static BOOL replaced = NO;
    if( !replaced )
    {
        Class fontClass = [UIFont class];
#pragma GCC diagnostic ignored "-Wundeclared-selector"
        Method method = class_getClassMethod(fontClass, @selector(moxtraSystemFontOfSize:));
        Method methodSys = class_getClassMethod(fontClass, @selector(systemFontOfSize:));
        method_exchangeImplementations(method,methodSys);
        method = class_getClassMethod(fontClass, @selector(moxtraBoldSystemFontOfSize:));
        methodSys = class_getClassMethod(fontClass, @selector(boldSystemFontOfSize:));
        method_exchangeImplementations(method,methodSys);
#pragma GCC diagnostic warning "-Wundeclared-selector"
        replaced = YES;
    }
}


@end
