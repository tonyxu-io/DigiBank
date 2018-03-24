//
//  NSDate+MCHelper.h
//  MessageCenter
//
//  Created by Rookie on 01/12/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSDate (MCHelper)

- (BOOL)mc_isSameDay:(NSDate *)date;
- (BOOL)mc_isSameWeek:(NSDate *)week;
- (BOOL)mc_isSame:(NSDate *)date withUnits:(NSArray<NSNumber *> *)unitFlags;
@end
