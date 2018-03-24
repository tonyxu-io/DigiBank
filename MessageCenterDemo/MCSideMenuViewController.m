//
//  MCSideMenuViewController.m
//  MessageCenter
//
//  Created by Rookie on 01/12/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import "MCSideMenuViewController.h"

#import "MCSideMenuPresentationController.h"
#import "MCFlipFromLeftAnimator.h"

static CGFloat const kHeadBlankHeight = 60;
static CGFloat const kMenuOptionHeight = 50;

static NSString * const kMenuCellReuseIdentifier = @"kSideMenuCellToken";

@interface MCSideMenuViewController () <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransition;

@property (nonatomic, assign) CGFloat menuWidth;

@property (nonatomic, strong) NSArray <NSString *> *menuTitles;

@property (nonatomic, copy) void(^handleIndexSelected)(NSUInteger index);

@end

@implementation MCSideMenuViewController

#pragma  mark - LifeCycle
- (instancetype)initWithMenuTitles:(NSArray<NSString *> *)titles
                     indexSelected:(void (^)(NSUInteger))handler
{
    if (self = [super initWithStyle:UITableViewStylePlain])
    {
        self.menuTitles = titles;
        self.handleIndexSelected = handler;
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.menuWidth = self.view.window.bounds.size.width * 0.7;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.menuWidth, kHeadBlankHeight)];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = kMenuOptionHeight;
    
    self.tableView.backgroundColor = MCColorMain;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kMenuCellReuseIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleInteractiveWithPanGesture:)];
    [self.tableView addGestureRecognizer:panGesture];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)setContainer:(UIViewController *)container
{
    _container = container;
    
    //Config call out gesture on container
    UIScreenEdgePanGestureRecognizer *panGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleInteractiveWithPanGesture:)];
    panGesture.edges = UIRectEdgeLeft;
    [container.view addGestureRecognizer:panGesture];
}

#pragma mark - Action
- (void)handleInteractiveWithPanGesture:(UIPanGestureRecognizer *)gesture
{
    @WEAKSELF;
    NSParameterAssert(self.container);
    
    CGFloat direction = [gesture translationInView:self.view].x;
    BOOL isSwipeLeft = direction < 0 ? YES : NO;
    CGPoint translation = [gesture translationInView:self.view.superview];
    CGFloat leftPercent = MIN(1, MAX(0, -translation.x  / self.view.bounds.size.width));
    CGFloat rightPercent = MIN(1, MAX(0, translation.x / self.view.bounds.size.width * 0.6));
    
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            self.interactiveTransition = [UIPercentDrivenInteractiveTransition new];
            if (isSwipeLeft)
            {
                [self dismissViewControllerAnimated:YES completion:^{
                    weakSelf.interactiveTransition = nil;
                }];
            }
            else
            {
                [self.container presentViewController:self animated:YES completion:^{
                    weakSelf.interactiveTransition = nil;
                }];
            }
        }
            break;
                
        case UIGestureRecognizerStateChanged:
        {
            [self.interactiveTransition updateInteractiveTransition:isSwipeLeft ? leftPercent: rightPercent];
        }
            break;
    
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            CGFloat velocity = [gesture velocityInView:self.view].x;
            if (isSwipeLeft)
            {
                if (leftPercent > 0.5 || velocity < -200) {
                    CGFloat originalSpeed = self.view.bounds.size.width / 0.25;
                    CGFloat speed = MAX(originalSpeed, velocity);
                    self.interactiveTransition.completionSpeed = speed/originalSpeed;
                    [self.interactiveTransition finishInteractiveTransition];
                }
                else
                {
                    [self.interactiveTransition cancelInteractiveTransition];
                }
            }
            else
            {
                CGFloat vx = [gesture velocityInView:self.view].x;
                CGFloat vy = [gesture velocityInView:self.view].y;
                if (rightPercent > 0.5 || vx > MAX(200, vy))
                {
                    CGFloat originalSpeed = self.view.bounds.size.width / 0.25;
                    CGFloat speed = MAX(originalSpeed, vx);
                    self.interactiveTransition.completionSpeed = speed/originalSpeed;
                    [self.interactiveTransition finishInteractiveTransition];
                }
                else
                {
                    [self.interactiveTransition cancelInteractiveTransition];
                }
            }
            break;
        }
                
        default:
            break;
        }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.menuTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMenuCellReuseIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.menuTitles[indexPath.row];
    cell.backgroundColor = MCColorMain;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
        if (self.handleIndexSelected)
        {
            self.handleIndexSelected(indexPath.row);
        }
    });
}

#pragma mark - UIViewControllerTransitioningDelegate
- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    return [[MCSideMenuPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return self.interactiveTransition;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return self.interactiveTransition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [MCFlipFromLeftAnimator new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [MCFlipFromLeftAnimator new];
}

@end
