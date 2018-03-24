//
//  UIWindow+MCHelper.h
//  MessageCenter
//
//  Created by Rookie on 9/7/16.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (MCHelper)

- (void)mc_showMessage:(NSString *)message;
- (UIViewController *)mc_frontMostViewController;

@end
