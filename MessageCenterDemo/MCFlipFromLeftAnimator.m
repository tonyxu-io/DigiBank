//
//  MCFlipFromLeftAnimator.m
//  MessageCenter
//
//  Created by Rookie on 06/12/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import "MCFlipFromLeftAnimator.h"

@implementation MCFlipFromLeftAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect onScreenFrame = [transitionContext finalFrameForViewController:toVC.isBeingPresented ? toVC : fromVC];
    CGRect offScreenFrame = CGRectOffset(onScreenFrame, -onScreenFrame.size.width, 0);
    CGRect finalFrame;
    UIView *animatedView;
    if (toVC.isBeingPresented)
    {
        animatedView = toVC.view;
        [transitionContext.containerView addSubview:animatedView];
        animatedView.frame = offScreenFrame;
        finalFrame = onScreenFrame;
    }
    else
    {
        animatedView = fromVC.view;
        finalFrame = offScreenFrame;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        animatedView.frame = finalFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
