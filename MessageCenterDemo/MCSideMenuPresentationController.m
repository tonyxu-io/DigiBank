//
//  MCSideMenuPresentationController.m
//  MessageCenter
//
//  Created by Rookie on 01/12/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import "MCSideMenuPresentationController.h"

@interface MCSideMenuPresentationController () <UIGestureRecognizerDelegate>

@end

@implementation MCSideMenuPresentationController
{
    UIView *_dimmingView;
}

- (void)presentationTransitionWillBegin
{
    _dimmingView = [[UIView alloc] initWithFrame:self.containerView.bounds];
    _dimmingView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismiss)];
    [_dimmingView addGestureRecognizer:tapGesture];
    [self.containerView addSubview:_dimmingView];
    
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        _dimmingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if ([context isCancelled]) {
            [_dimmingView removeFromSuperview];
        }
    }];
}

- (void)dismissalTransitionWillBegin
{
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        _dimmingView.backgroundColor = [UIColor clearColor];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (![context isCancelled]) {
            [_dimmingView removeFromSuperview];
        }
    }];
}

- (CGRect)frameOfPresentedViewInContainerView
{
    return CGRectMake(0, 0, self.containerView.bounds.size.width * 0.6, self.containerView.bounds.size.height);
}

- (void)handleDismiss
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
