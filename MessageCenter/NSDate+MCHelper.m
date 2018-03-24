//
//  NSDate+MCHelper.m
//  MessageCenter
//
//  Created by Rookie on 01/12/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import "NSDate+MCHelper.h"

@implementation NSDate (MCHelper)

- (BOOL)mc_isSameDay:(NSDate *)date {
    return [self mc_isSame:date withUnits:@[@(NSCalendarUnitYear), @(NSCalendarUnitMonth), @(NSCalendarUnitDay)]];
}

- (BOOL)mc_isSameWeek:(NSDate *)date {
    return [self mc_isSame:date withUnits:@[@(NSCalendarUnitYear), @(NSCalendarUnitWeekOfYear)]];
}

- (BOOL)mc_isSame:(NSDate *)date withUnits:(NSArray<NSNumber *> *)unitFlags {
    if (unitFlags.count == 0 || date == nil) {
        return NO;
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger dateComponent, theDateComponent;
    for (NSNumber *flag in unitFlags) {
        dateComponent = [calendar component:[flag unsignedIntegerValue] fromDate:self];
        theDateComponent = [calendar component:[flag unsignedIntegerValue] fromDate:date];
        if (dateComponent != theDateComponent) {
            return NO;
        }
    }
    
    return YES;
}

@end
