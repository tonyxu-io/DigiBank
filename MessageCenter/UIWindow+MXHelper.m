//
//  UIWindow+MXHelper.m
//  MessageCenter
//
//  Created by Rookie on 9/7/16.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import "UIWindow+MXHelper.h"
#import <objc/runtime.h>

@implementation UIWindow (MXHelper)

- (void)mx_showMessage:(NSString *)message {
    UIView *panel = [UIView new];
    panel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    panel.layer.cornerRadius = 5;
    panel.clipsToBounds = YES;
    panel.alpha = 0;
    panel.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *messageLabel = [UILabel new];
    messageLabel.text = message;
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.layer.cornerRadius = 10;
    messageLabel.clipsToBounds = YES;
    messageLabel.center = self.center;
    messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    messageLabel.adjustsFontSizeToFitWidth = YES;
    messageLabel.numberOfLines = 1;
    
    [panel addSubview:messageLabel];
    [self addSubview:panel];
    
    [panel.heightAnchor constraintLessThanOrEqualToConstant:50].active = YES;
    [panel.widthAnchor constraintLessThanOrEqualToConstant:self.bounds.size.width - 50].active = YES;
    [panel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [panel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    
    [messageLabel.topAnchor constraintEqualToAnchor:panel.layoutMarginsGuide.topAnchor].active = YES;
    [messageLabel.bottomAnchor constraintEqualToAnchor:panel.layoutMarginsGuide.bottomAnchor].active = YES;
    [messageLabel.leftAnchor constraintEqualToAnchor:panel.layoutMarginsGuide.leftAnchor].active = YES;
    [messageLabel.rightAnchor constraintEqualToAnchor:panel.layoutMarginsGuide.rightAnchor].active = YES;
    
    [UIView animateKeyframesWithDuration:3 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.1 animations:^{
            panel.alpha = 1;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.9 relativeDuration:0.1 animations:^{
            panel.alpha = 0;
        }];
    } completion:^(BOOL finished) {
        [panel removeFromSuperview];
    }];
}

- (UIViewController *)mx_frontMostViewController {
    UIViewController *result = self.rootViewController;
    while (result.presentedViewController) {
        result = result.presentedViewController;
    }
    return result;
}

@end
