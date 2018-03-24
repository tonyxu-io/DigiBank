//
//  UIWindow+MXHelper.h
//  MessageCenter
//
//  Created by Rookie on 9/7/16.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (MXHelper)

- (void)mx_showMessage:(NSString *)message;
- (UIViewController *)mx_frontMostViewController;

@end
