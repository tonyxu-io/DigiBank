//
//  MXColorManager.h
//  Agent
//
//  Created by Rookie on 16/02/2017.
//  Copyright © 2017 moxtra. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MXColorManager : NSObject

+ (BOOL)isLightColor:(UIColor *)color;

+ (UIColor *)moxtraBrandingColor;
+ (UIColor *)moxtraBrandingForegroundColor;

+ (UIColor *)moxtraMeetColor;
+ (UIColor *)moxtraMeetForegroundColor;

+ (UIColor *)moxtraNavBarColor;
+ (UIColor *)moxtraNavBarForegroundColor;

+ (UIColor *)moxtraAlertColor;
+ (UIColor *)moxtraFavoriteColor;
+ (UIColor *)moxtraPresenceColor;

+ (UIColor *)moxtraWhiteColor;  //#FFFFFF rgba(255, 255, 255, 1)
+ (UIColor *)moxtraGray04Color; //#F0F0F5 rgba(240, 240, 245, 0.9)
+ (UIColor *)moxtraGray08Color; //#E6E6EB rgba(230, 230, 235, 1)
+ (UIColor *)moxtraGray20Color; //#C8C8CC rgba(200, 200, 204, 1)
+ (UIColor *)moxtraGray40Color; //#969699 rgba(150, 150, 153, 1)
+ (UIColor *)moxtraGray60Color; //#646466 rgba(100, 100, 102, 1)
+ (UIColor *)moxtraBlackColor;  //#191919 rgba(25, 25, 25, 1)

+ (UIColor *)moxtraRedColor;
+ (UIColor *)moxtraBlueColor;
+ (UIColor *)moxtraGreenColor;
+ (UIColor *)moxtraOrangeColor;

+ (UIColor *)moxtraFeedIncomingColor;
+ (UIColor *)moxtraFeedOutgoingColor;
+ (UIColor *)moxtraFeedOutgoingInternalColor;

//---------------------------
+ (UIColor *)moxtraGrayColor;
+ (UIColor *)moxtraDarkGrayColor;
+ (UIColor *)moxtraLightGrayColor;
+ (UIColor *)moxtraBadgeColor;
+ (UIColor *)moxtraPageTextureColor;
+ (UIColor *)moxtraTableViewBackground;
+ (UIColor *)moxtraViewBackgroundColor;
+ (UIColor *)moxtraCallViewBackgroundColor;

+ (UIColor *)operationTextLabelColor;
+ (UIColor *)operationDetailTextLabelColor;

+ (UIColor *)moxtraColorWithHexString:(NSString *)hexString;

@end
