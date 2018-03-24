//
//  UIView+MCHelper.m
//  MessageCenter
//
//  Created by Rookie on 16/12/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import "UIView+MCHelper.h"
#import <objc/runtime.h>

static const char *kIndicatorView = "kIndicatorView";

@implementation UIView (MCHelper)

- (void)mc_startIndicatorViewAnimating {
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicatorView.frame = self.bounds;
    indicatorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [self addSubview:indicatorView];
    [indicatorView startAnimating];
    objc_setAssociatedObject(self, kIndicatorView, indicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)mc_stopIndicatorViewAnimating {
    UIActivityIndicatorView *indicatorView = objc_getAssociatedObject(self, kIndicatorView);
    if (indicatorView) {
        objc_setAssociatedObject(self, kIndicatorView, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [indicatorView stopAnimating];
        [indicatorView removeFromSuperview];
    }
}

@end
