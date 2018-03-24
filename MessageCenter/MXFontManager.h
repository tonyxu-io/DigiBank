//
//  MXFontManager.h
//  Agent
//
//  Created by Rookie on 16/02/2017.
//  Copyright © 2017 moxtra. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MXFontManager : NSObject

+ (UIFont *)operationTextLabelFont;
+ (UIFont *)operationDetailTextLabelFont;

+ (UIFont *)moxtraRegularFontWithSize:(CGFloat)size;
+ (UIFont *)moxtraLightFontWithSize:(CGFloat)size;

+ (void)replaceSystemFont;

@end
