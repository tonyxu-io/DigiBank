//
//  NSDate+MCExtension.h
//  DigiBank
//
//  Created by Moxtra on 2017/4/20.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (MCExtension)

- (NSString *)mc_description;

// Returns a three letter abbreviation of weekday name
- (NSString *)mc_dayNameOnCalendar:(NSCalendar *)calendar;

- (NSString *)mc_dayShortNameOnCalendar:(NSCalendar *)calendar;

//  Prints out "January", "February", etc for Gregorian dates.
- (NSString *)mc_monthNameOnCalendar:(NSCalendar *)calendar;

//  Prints out "January 2012", "February 2012", etc for Gregorian dates.
- (NSString *)mc_monthAndYearOnCalendar:(NSCalendar *)calendar;

//  Prints out "Jan 2012", "Feb 2012", etc for Gregorian dates.
- (NSString *)mc_monthAbbreviationAndYearOnCalendar:(NSCalendar *)calendar;

//  Prints out "January 3", "February 28", etc for Gregorian dates.
- (NSString *)mc_monthAndDayOnCalendar:(NSCalendar *)calendar;

//  Prints out "Jan", "Feb", etc for Gregorian dates.
- (NSString *)mc_monthAbbreviationOnCalendar:(NSCalendar *)calendar;

//  Prints out a number, representing the day of the month
- (NSString *)mc_dayOfMonthOnCalendar:(NSCalendar *)calendar;

//  Prints out, for example, January 12, 2013
- (NSString *)mc_monthAndDayAndYearOnCalendar:(NSCalendar *)calendar;

// Prints out dates such as 12, 2013
- (NSString *)mc_dayOfMonthAndYearOnCalendar:(NSCalendar *)calendar;

// Prints out dates such as 12:30 PM
- (NSString *)mc_timeOfHourAndMinuteOnCalendar:(NSCalendar *)calendar;

// Judge the equality of the two dates
- (BOOL)mc_isSameDay:(NSDate *)date;
- (BOOL)mc_isSameWeek:(NSDate *)week;
- (BOOL)mc_isSame:(NSDate *)date withUnits:(NSArray<NSNumber *> *)unitFlags;

+ (NSString*)mc_getLocalizedShortFullDateString:(NSDate *)date;

+ (NSString*)mc_getLocalizedShortDateString:(NSDate *)date;

+ (NSString*)mc_formatTimeLengthString:(UInt64)timeseconds;
@end
