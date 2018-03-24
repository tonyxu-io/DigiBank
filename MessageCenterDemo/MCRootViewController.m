//
//  MCRootViewController.m
//  MessageCenter
//
//  Created by Rookie on 01/12/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import "MCRootViewController.h"

#import "MCSideMenuViewController.h"
#import "MCHomeViewController.h"
#import "MCMessageCenterViewController.h"

#import "MXUserItem+MCHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCRootViewController () <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) MCSideMenuViewController *sideMenuViewController;
@property (nonatomic, copy) NSArray<UIViewController *> *viewControllers;
@property (nonatomic, strong) UIViewController *currentViewController;

@end

@implementation MCRootViewController

#pragma mark - LifeCycle & Signleton
+ (instancetype)sharedInstance
{
    static MCRootViewController *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MCRootViewController alloc] init];

    });
    return instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = MCColorBackground;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Do login
    if (![MCMessageCenterInstance sharedInstance].online)
    {
        [[MCMessageCenterInstance sharedInstance] loginWithCompletionHandler:^(NSError *errorOrNil) {
            if (errorOrNil == nil)
            {
                [[MCMessageCenterViewController sharedInstance] loadContent];
                [[MCMessageCenterViewController sharedInstance] configInerfacePresenting];
            }
        }];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (NSArray<UIViewController *> *)viewControllers
{
    if (_viewControllers == nil)
    {
        //Add viewControllers
        MCHomeViewController *homeViewController = [[MCHomeViewController alloc] init];
        _viewControllers = @[homeViewController,[MCMessageCenterViewController sharedInstance]];
    }
    return _viewControllers;
}

- (void)presentSideMenu
{
    @WEAKSELF;
    //Config MCSideMenuViewController and present
    __weak MCRootViewController *weakRoot = [MCRootViewController sharedInstance];
    __weak MCMessageCenterInstance *weakInstance = [MCMessageCenterInstance sharedInstance];
    
    NSArray *titleArray = @[@"Home", @"Accounts", @"Transactions", @"Message Center", @"Contacts", @"News", @"Logout"];
    MCSideMenuViewController *sideMenuViewController = [[MCSideMenuViewController alloc] initWithMenuTitles:titleArray indexSelected:^(NSUInteger index) {
        switch (index) {
            case 0:
            {
                [weakRoot switchContainerController:weakSelf.viewControllers[0]];
            }
                break;
            case 3:
            {
                [weakRoot switchContainerController:[MCMessageCenterViewController sharedInstance]];
            }
                break;
            case 6:
            {
                [weakInstance logout];
                [weakRoot switchContainerController:weakSelf.viewControllers[0]];
            }
                break;
            default:
                break;
        }
    }];
    self.sideMenuViewController = sideMenuViewController;
    self.sideMenuViewController.container = self;
    [self presentViewController:sideMenuViewController animated:YES completion:nil];
}

- (void)switchContainerController:(UIViewController *)containerController;
{
    if (containerController == self.currentViewController)
    {
        //If is same viewcontroller, do nothing.
        return;
    }
    
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.view removeFromSuperview];
        [obj willMoveToParentViewController:nil];
        [obj removeFromParentViewController];
        [obj didMoveToParentViewController:nil];
    }];
    
    UIImage *menuButtonImage = [[UIImage imageNamed:@"menu_topbar_button"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    NSArray *leftBarItems = @[[[UIBarButtonItem alloc] initWithImage:menuButtonImage
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(presentSideMenu)]];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:containerController];
    [[MCRootViewController sharedInstance] setupNavigationForViewController:containerController
                                                               leftBarItems:leftBarItems
                                                              rightBarItems:nil];
    
    
    [navigationController willMoveToParentViewController:self];
    [self addChildViewController:navigationController];
    [self.view addSubview:navigationController.view];
    navigationController.view.frame = self.view.bounds;
    [navigationController didMoveToParentViewController:self];
    self.currentViewController = containerController;
}

- (void)setupNavigationForViewController:(UIViewController *)viewController
                            leftBarItems:(NSArray<UIBarButtonItem *> * __nullable)leftBarItems
                           rightBarItems:(NSArray<UIBarButtonItem *> * __nullable)rightBarItems
{
    UINavigationBar *navigationBar = viewController.navigationController.navigationBar;
    NSAssert(navigationBar, @"the view controller must be put in a navigation controller");
    
    navigationBar.barTintColor = MCColorMain;
    navigationBar.tintColor = [UIColor whiteColor];
    navigationBar.translucent = NO;
    navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    [navigationBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
    [navigationBar setShadowImage:[UIImage new]];
    
    viewController.navigationItem.leftBarButtonItems = leftBarItems;
    viewController.navigationItem.rightBarButtonItems = rightBarItems;
}

- (void)handleRemoteNotification:(NSDictionary *)userInfo
{
    MXChatClient *chatClient = [MCMessageCenterInstance sharedInstance].chatClient;
    MXMeetListModel *meetListModel = [MCMessageCenterInstance sharedInstance].meetListModel;
    
    @WEAK_OBJ(meetListModel);
    if (chatClient && [chatClient isMoxtraRemoteNotification:userInfo])
    {
        if (self.sideMenuViewController)
        {
            [self.sideMenuViewController dismissViewControllerAnimated:YES completion:nil];
            [self switchContainerController:[MCMessageCenterViewController sharedInstance]];
        }
        
        [chatClient fetchItemWithRemoteNotification:userInfo completionHandler:^(NSError * _Nullable error, id  _Nullable item) {
            if ([item isKindOfClass:[MXChat class]])
            {
                [[MCMessageCenterViewController sharedInstance] openChatItem:item withFeedObject:nil];
            }
            else if ([item isKindOfClass:[MXMeet class]])
            {
                MXMeet *currentMeet = (MXMeet *)item;
                NSString *message = [NSString stringWithFormat:@"%@\nHosted by %@ %@", currentMeet.topic, currentMeet.host.firstname,currentMeet.host.lastname];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Meet Invite" message:message preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *joinAction = [UIAlertAction actionWithTitle:@"Join" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [meetListModelWeak joinMeetWithMeetId:currentMeet.meetId completionHandler:^(NSError * _Nullable error, MXMeetSession * _Nullable meetSession) {
                        if (error)
                        {
                            [[UIApplication sharedApplication].keyWindow.mc_frontMostViewController mc_simpleAlertError:error];
                        }
                        else
                        {
                            [meetSession presentMeetWindow];
                        }
                    }];
                }];
                [alert addAction:joinAction];
                
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
                [alert addAction:cancelAction];
                
                [[UIApplication sharedApplication].keyWindow.mc_frontMostViewController presentViewController:alert animated:YES completion:nil];
                
            }
        }];
    }
}

@end

NS_ASSUME_NONNULL_END
