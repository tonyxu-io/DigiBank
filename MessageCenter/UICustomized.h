//
//  UICustomized.h
//  Agent
//
//  Created by Rookie on 16/02/2017.
//  Copyright © 2017 moxtra. All rights reserved.
//

#ifndef UICustomized_h
#define UICustomized_h

/***************Font********************/

#define MXRegularFont(_size) [MXFontManager moxtraRegularFontWithSize:_size]
#define MXLightFont(_size)   [MXFontManager moxtraLightFontWithSize:_size]

/***************Color*******************/

#define MXBrandingColor                  [MXColorManager moxtraBrandingColor]
#define MXBrandingForegroundColor        [MXColorManager moxtraBrandingForegroundColor]

#define MXBadgeColor                     [MXColorManager moxtraBadgeColor]
#define MXFeedOutgoingColor              [MXColorManager moxtraFeedOutgoingColor]
#define MXMeetColor                      [MXColorManager moxtraMeetColor]
#define MXMeetForegroundColor            [MXColorManager moxtraMeetForegroundColor]
#define MXNavBarColor                    [MXColorManager moxtraNavBarColor]
#define MXFavoriteColor                  [MXColorManager moxtraFavoriteColor]

#define MXBlackColor                     [MXColorManager moxtraBlackColor]
#define MXGrayColor                      [MXColorManager moxtraGrayColor]
#define MXGray08Color                    [MXColorManager moxtraGray08Color]
#define MXGray20Color                    [MXColorManager moxtraGray20Color]
#define MXGray40Color                    [MXColorManager moxtraGray40Color]
#define MXGray60Color                    [MXColorManager moxtraGray60Color]
#define MXWhiteColor                     [MXColorManager moxtraWhiteColor]
#define MXRedColor                       [MXColorManager moxtraRedColor]
#define MXBlueColor                      [MXColorManager moxtraBlueColor]

#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:a]
#define RGB(r, g, b) RGBA(r, g, b, 1)

#define MCColorMain RGB(65, 180, 100)
#define MCColorBackground RGB(241, 241, 241)
#define MCColorFontBlack RGB(51, 51, 51)
#define MCColorFontDarkGray RGB(102, 102, 102)
#define MCColorFontGray RGB(153, 153, 153)
#define MCColorFontLightGray RGB(204, 204, 204)
#define MCColorBlue RGB(45, 156, 245)

#pragma mark - WeakSelf

#define WEAKSELF autoreleasepool{} __weak typeof(self) weakSelf = self;

#define WEAK_OBJ(o) autoreleasepool{} __weak typeof(o) o##Weak = o;

#endif /* UICustomized_h */
