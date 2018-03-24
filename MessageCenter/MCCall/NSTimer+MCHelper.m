//
//  NSTimer+MCHelper.m
//  commonUtility
//
//  Created by wubright on 2016/11/1.
//  Copyright © 2016年 Moxtra. All rights reserved.
//

#import "NSTimer+MCHelper.h"

@implementation NSTimer (MCHelper)

+ (NSTimer *)mc_scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                         block:(void(^)())block
                                       repeats:(BOOL)repeats{
    
    return [self scheduledTimerWithTimeInterval:ti
                                         target:self
                                       selector:@selector(mc_blockInvoke:)
                                       userInfo:[block copy]
                                        repeats:repeats];
}

+ (void)mc_blockInvoke:(NSTimer *)timer{
    
    void(^block)() = timer.userInfo;
    if (block) {
        block();
    }
}

@end
