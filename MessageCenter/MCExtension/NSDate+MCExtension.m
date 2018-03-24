//
//  NSDate+MCExtension.m
//  DigiBank
//
//  Created by Moxtra on 2017/4/20.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "NSDate+MCExtension.h"

@implementation NSDate (MCExtension)

- (NSString *)mc_description
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    return [formatter stringFromDate:self];
}

- (NSString *)mc_dayNameOnCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *f = [NSDateFormatter new];
    [f setCalendar:calendar];
    [f setDateFormat:@"cccc"];
    return [f stringFromDate:self];
}

- (NSString *)mc_dayShortNameOnCalendar:(NSCalendar *)calendar;
{
    NSDateFormatter *f = [NSDateFormatter new];
    [f setCalendar:calendar];
    [f setDateFormat:@"ccc"];
    return [f stringFromDate:self];
}

- (NSString *)mc_monthNameOnCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *f = [NSDateFormatter new];
    [f setCalendar:calendar];
    [f setDateFormat:@"MMMM"];
    return [f stringFromDate:self];
}

- (NSString *)mc_monthAndYearOnCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *f = [NSDateFormatter new];
    [f setCalendar:calendar];
    [f setDateFormat:@"MMMM yyyy"];
    return [f stringFromDate:self];
}

- (NSString *)mc_monthAbbreviationAndYearOnCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *f = [NSDateFormatter new];
    [f setCalendar:calendar];
    [f setDateFormat:@"MMM yyyy"];
    return [f stringFromDate:self];
}


- (NSString *)mc_monthAbbreviationOnCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *f = [NSDateFormatter new];
    [f setCalendar:calendar];
    [f setDateFormat:@"MMM"];
    return [f stringFromDate:self];
}

- (NSString *)mc_monthAndDayOnCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *f = [NSDateFormatter new];
    [f setCalendar:calendar];
    
    [f setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"MMM d" options:0 locale:[NSLocale currentLocale]]];
    return [f stringFromDate:self];
}

- (NSString *)mc_dayOfMonthOnCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *f = [NSDateFormatter new];
    [f setCalendar:calendar];
    [f setDateFormat:@"d"];
    return [f stringFromDate:self];
}

- (NSString *)mc_monthAndDayAndYearOnCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *f = [NSDateFormatter new];
    [f setCalendar:calendar];
    [f setDateFormat:@"MMM d yyyy"];
    return [f stringFromDate:self];
}


- (NSString *)mc_dayOfMonthAndYearOnCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *f = [NSDateFormatter new];
    [f setCalendar:calendar];
    [f setDateFormat:@"d yyyy"];
    return [f stringFromDate:self];
}

- (NSString *)mc_timeOfHourAndMinuteOnCalendar:(NSCalendar *)calendar;
{
    NSDateFormatter *f = [NSDateFormatter new];
    [f setCalendar:calendar];
    [f setDateFormat:@"h:mm a"];
    return [f stringFromDate:self];
}

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

+ (NSString*)mc_getLocalizedShortFullDateString:(NSDate *)date;
{
   	if (date)
    {
        [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        NSString *formattedDateString = [dateFormatter stringFromDate:date];
        [dateFormatter setDateFormat:@"EEE"];
        NSString *weekDay = [dateFormatter stringFromDate:date];
        
        return [NSString stringWithFormat:@"%@, %@",weekDay,formattedDateString];
    }
    return nil;
}

+ (NSString*)mc_getLocalizedShortDateString:(NSDate *)date
{
    if (date) {
        
        static NSDateFormatter *dateFormatter = nil;
        if(dateFormatter == nil)
        {
            [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        }
        
        NSString *formattedDateString = [dateFormatter stringFromDate:date];
        
        return formattedDateString;
    }
    return nil;
}

+ (NSString*)mc_formatTimeLengthString:(UInt64)timeseconds
{
    UInt64 hours = timeseconds/3600;
    UInt64 minutes = (timeseconds%3600)/60;
    UInt64 seconds = (timeseconds%3600)%60;
    
    if(seconds > 0)
        minutes += 1;
    
    if(hours == 0)
        minutes = MAX(minutes, 1);
    
    NSMutableString *timelengthstring = [NSMutableString string];
    
    if (hours>0)
        [timelengthstring appendFormat:@"%llu %@ ", hours, (hours>1?NSLocalizedString(@"hrs", @"time"):NSLocalizedString(@"hr", @"time"))];
    
    if (minutes>0)
        [timelengthstring appendFormat:@"%llu %@ ", minutes, (minutes>1?NSLocalizedString(@"mins", @"time"):NSLocalizedString(@"min", @"time"))];
    
    return timelengthstring;
}

@end
