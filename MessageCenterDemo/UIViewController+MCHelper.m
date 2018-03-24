//
//  UIViewController+MCHelper.m
//  MessageCenter
//
//  Created by Rookie on 9/7/16.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import "UIViewController+MCHelper.h"
#import "MCRootViewController.h"

@implementation UIViewController (MCHelper)

- (void)mc_simpleAlertError:(NSError *)error {
    NSString *title = @"Error";
    NSString *message = [NSString stringWithFormat:@"domain:%@, code:%@\n%@", error.domain, @(error.code), error.localizedDescription];
    [self mc_simpleAlertWithTitle:title message:message];
}

- (void)mc_simpleAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
