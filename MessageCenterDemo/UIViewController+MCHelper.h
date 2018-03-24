//
//  UIViewController+MCHelper.h
//  MessageCenter
//
//  Created by Rookie on 9/7/16.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIViewController (MXHelper)

- (void)mc_simpleAlertError:(NSError *)error;
- (void)mc_simpleAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
