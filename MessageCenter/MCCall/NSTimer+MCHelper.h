//
//  NSTimer+MCHelper.h
//  commonUtility
//
//  Created by wubright on 2016/11/1.
//  Copyright © 2016年 Moxtra. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 <#Description#>
 */
@interface NSTimer (MCHelper)

+ (NSTimer *)mc_scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                         block:(void(^)())block
                                       repeats:(BOOL)repeats;

@end
