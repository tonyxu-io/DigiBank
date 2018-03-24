//
//  MXUserItem+MCHelper.m
//  Digi Bank
//
//  Created by Jacob ding on 16/12/29.
//  Copyright © 2016年 moxtra. All rights reserved.
//

#import "MXUserItem+MCHelper.h"

@implementation MXUserItem (MCHelper)
- (NSString *)fullName
{
    NSString *firstName = self.firstname;
    NSString *lastname = self.lastname;
    if( firstName.length == 0 && lastname.length == 0 )
        return NSLocalizedString(@"Unknown", @"unknown");
    else if( firstName.length > 0 && lastname.length > 0 ){
        return [NSString stringWithFormat:@"%@ %@", firstName, lastname];
    }
    else{
        return firstName;
    }
}
@end
