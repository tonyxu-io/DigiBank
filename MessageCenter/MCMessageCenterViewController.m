  //
//  MCMessageCenterViewController.m
//  MessageCenter
//
//  Created by Rookie on 30/11/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import "MCMessageCenterViewController.h"

#import <Masonry.h>

#import "MCTabBar.h"
#import "MCTabButton.h"
#import "MCChatListViewController.h"
#import "MCChatSettingViewController.h"
#import "MCFileListViewController.h"
#import "MCToDoListViewController.h"
#import "MCMeetListViewController.h"
#import "MCUserListViewController.h"
#import "MCUserInfoViewController.h"
#import "MCInviteViewController.h"
#import "MCMeetRingCallViewController.h"
#import "MCCallKitManager.h"


@interface MCMessageCenterViewController () <MCMessageCenterInstanceDelegate, MXChatListModelDelegate, MXMeetListModelDelegate, MXMeetSessionDelegate,MCMeetRingCallViewControllerDelegate>

@property (nonatomic, weak) MXChatClient *chatClient;
@property (nonatomic, weak) MXChatListModel *chatListModel;
@property (nonatomic, weak) MXMeetListModel *meetListModel;

@property (nonatomic, strong) UIView *tabView;
@property (nonatomic, strong) MCTabBar *tabBar;

@property (nonatomic, strong) UINavigationController *navigator;
@property (nonatomic, strong) MCChatListViewController *chatListViewController;
@property (nonatomic, strong) MCFileListViewController *fileListViewController;
@property (nonatomic, strong) MCToDoListViewController *todoListViewController;
@property (nonatomic, strong) MCMeetListViewController *meetListViewController;
@property (nonatomic, strong) MCUserListViewController *userListViewController;
@property (nonatomic, strong) MXGlobalSearchViewController *globalSearchController;

@property (nonatomic, strong, nullable) MCMeetRingCallViewController *meetCallViewController;
@property (nonatomic, assign) BOOL joiningCall;

@property (nonatomic, weak) MCTabButton *currTab;
@property (nonatomic, weak) UIViewController *currChildViewController;

@end

static CGFloat const kTabBarHeight = 44.f;

@implementation MCMessageCenterViewController

#pragma mark - LifeCycle

+ (instancetype)sharedInstance
{
    static MCMessageCenterViewController *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MCMessageCenterViewController alloc] initPrivate];
        [MCMessageCenterInstance sharedInstance].delegate = instance;
    });
    return instance;
}

- (instancetype)initPrivate
{
    if (self = [super init])
    {
        [self setupDelegate];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = MCColorBackground;
    self.navigationItem.title = NSLocalizedString(@"Message Center", @"");
    
    [self setupTableView];
    
    [self setupTabbar];
    self.view.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    @WEAKSELF;
    [super viewDidAppear:animated];
    if (![MCMessageCenterInstance sharedInstance].online)
    {
        [[MCMessageCenterInstance sharedInstance] loginWithCompletionHandler:^(NSError *errorOrNil) {
            if (!errorOrNil)
            {
                [weakSelf configInerfacePresenting];
                [weakSelf loadContent];
            }
            else
            {
                [weakSelf mc_simpleAlertError:errorOrNil];
            }
        }];
    }
}

#pragma mark - Getter

- (MXChatClient *)chatClient
{
    return [MCMessageCenterInstance sharedInstance].chatClient;
}

- (MXChatListModel *)chatListModel
{
    return [MCMessageCenterInstance sharedInstance].chatListModel;
}

- (MXMeetListModel *)meetListModel
{
    return [MCMessageCenterInstance sharedInstance].meetListModel;
}

- (UINavigationController *)navigator
{
    if (_navigator == nil)
    {
        _navigator = [[UINavigationController alloc] init];
        _navigator.modalPresentationStyle = UIModalPresentationFormSheet;
        _navigator.navigationBar.barStyle = UIBarStyleBlack;
        _navigator.navigationBar.barTintColor = MCColorMain;
        _navigator.navigationBar.tintColor = [UIColor whiteColor];
        _navigator.navigationBar.translucent = NO;
    }
    return _navigator;
}

- (MCChatListViewController *)chatListViewController
{
    if (_chatListViewController == nil)
    {
        _chatListViewController = [[MCChatListViewController alloc] init];
    }
    return _chatListViewController;
}

- (MCFileListViewController *)fileListViewController
{
    if (_fileListViewController == nil)
    {
        _fileListViewController = [[MCFileListViewController alloc] init];
    }
    return _fileListViewController;
}

- (MCToDoListViewController *)todoListViewController
{
    if (_todoListViewController == nil)
    {
        _todoListViewController = [[MCToDoListViewController alloc] init];
    }
    return _todoListViewController;
}

- (MCMeetListViewController *)meetListViewController
{
    if (_meetListViewController == nil)
    {
        _meetListViewController = [[MCMeetListViewController alloc] init];
    }
    return _meetListViewController;
}

- (MCUserListViewController *)userListViewController
{
    if (_userListViewController == nil)
    {
        _userListViewController = [[MCUserListViewController alloc] init];
    }
    return _userListViewController;
}

- (void)setupDelegate
{
    //Congfig some global delegate.
    self.meetListModel.delegate = self;
}

#pragma mark - Public Setter

- (void)setDeviceToken:(NSData *)deviceToken
{
    _deviceToken = deviceToken;
    if (self.chatClient)
    {
        [self.chatClient registerNotificationDeviceToken:self.deviceToken];
    }
}

#pragma mark - UserInterface

- (void)setupTableView
{
    self.tabView = [[UIView alloc] init];
    self.tabView.backgroundColor = MCColorBackground;
    self.tabView.layer.shadowOffset = CGSizeMake(0, -1);
    self.tabView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.tabView.layer.shadowRadius = 2;
    self.tabView.layer.shadowOpacity = 0.3;
    [self.view addSubview:self.tabView];
    [self.tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(12);
        make.height.mas_equalTo(44);
    }];
}

- (void)setupTabbar
{
    @WEAKSELF;
    MCTabBarButton *inboxBarButton = [[MCTabBarButton alloc] initWithTitle:NSLocalizedString(@"Inbox", @"Inbox") image:[UIImage imageNamed:@"tab_inbox"] tag:0];
    MCTabBarButton *fileBarButton = [[MCTabBarButton alloc] initWithTitle:NSLocalizedString(@"File",@"File") image:[UIImage imageNamed:@"tab_file"] tag:1];
    MCTabBarButton *todoBarButton = [[MCTabBarButton alloc] initWithTitle:NSLocalizedString(@"To-Do", @"todo") image:[UIImage imageNamed:@"tab_todo"] tag:2];
    MCTabBarButton *meetingBarButton = [[MCTabBarButton alloc] initWithTitle:NSLocalizedString(@"Meet", @"Meet") image:[UIImage imageNamed:@"tab_meet"] tag:3];
    MCTabBarButton *contactButton = [[MCTabBarButton alloc] initWithTitle:NSLocalizedString(@"Contacts", @"contacts") image:[UIImage imageNamed:@"tab_contact"] tag:4];
    
    MCTabBar *tabBar = [[MCTabBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,kTabBarHeight) handleSelectedItem:^(UITabBarItem *item) {
        switch (item.tag)
        {
            case 0:
                [weakSelf presentChildViewController:weakSelf.chatListViewController];
                break;
            case 1:
            {
                [weakSelf presentChildViewController:weakSelf.fileListViewController];
            }
                break;
            case 2:
            {
                [weakSelf presentChildViewController:weakSelf.todoListViewController];
            }
                break;
            case 3:
            {
                [weakSelf presentChildViewController:weakSelf.meetListViewController];
            }
                break;
            default:
            {
                [weakSelf presentChildViewController:weakSelf.userListViewController];
            }
                break;
        }
    }];
    [tabBar setItems:@[inboxBarButton,fileBarButton,todoBarButton,meetingBarButton,contactButton]];
    tabBar.selectedItem = inboxBarButton;
    [self.tabView addSubview:tabBar];
    [tabBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.tabView);
        make.height.mas_offset(44);
    }];
    self.tabBar = tabBar;
    
    if (self.chatClient)
    {
        [self.chatListViewController loadChatList];
        [self presentChildViewController:self.chatListViewController];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Public Method

- (void)loadContent
{
    [self.tabBar selectIndex:0];
    [self.chatListViewController loadChatList];
    [self.fileListViewController loadFileList];
    [self.todoListViewController loadTodoList];
    [self.meetListViewController loadMeetList];
    [self.userListViewController loadUserList];
    self.view.hidden = NO;
}

- (void)openGlobalSearch
{
    @WEAKSELF;
    self.globalSearchController = [[MXGlobalSearchViewController alloc] init];
    
    self.globalSearchController.didTapCancel = ^(id  _Nonnull sender) {
        [weakSelf dismissGlobalSearch];
    };
    self.globalSearchController.didTapFeed = ^(MXChat * _Nonnull chat, id  _Nonnull sender, id  _Nonnull feed) {
        [weakSelf dismissGlobalSearch];
        [weakSelf openChatItem:chat withFeedObject:feed];
    };
    
    self.globalSearchController.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:_globalSearchController animated:YES completion:nil];
    [self.globalSearchController setNeedsStatusBarAppearanceUpdate];
}

- (void)showInboxBadge:(BOOL)show
{
    [self.tabBar setBadgeAtIndex:0 show:show];
}

- (void)showMeetBadge:(BOOL)show
{
    [self.tabBar setBadgeAtIndex:3 show:show];
}

#pragma mark - Interface Presenting

- (void)configInerfacePresenting
{
    @WEAKSELF;
    //Config some present action
    self.chatClient.chatSessionConfig.didTapMemberAvatar = ^(MXChat * _Nonnull chat, UIViewController * _Nonnull viewController, id  _Nonnull sender, MXUserItem * _Nonnull userItem) {
        //If it's already preseneted a navigator, dismiss it first.
        if (weakSelf.navigator.viewControllers.count)
        {
            [weakSelf.navigator dismissViewControllerAnimated:YES completion:nil];
        }
        MCUserInfoViewController *userInfo = [[MCUserInfoViewController alloc] initWithUserItem:userItem userListModel:nil];
        weakSelf.navigator.viewControllers = @[userInfo];
        userInfo.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Close") style:UIBarButtonItemStylePlain target:self action:@selector(userInfoCloseButtonClicked:)];
        [weakSelf presentViewController:weakSelf.navigator animated:YES completion:nil];
    };
}

- (void)presentChildViewController:(UIViewController *)childVC
{
    [self.currChildViewController willMoveToParentViewController:nil];
    [self.currChildViewController.view removeFromSuperview];
    [self.currChildViewController removeFromParentViewController];
    if (childVC)
    {
        [self addChildViewController:childVC];
        [self.view addSubview:childVC.view];
        [childVC didMoveToParentViewController:self];
        [childVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tabView.mas_bottom);
            make.left.right.bottom.mas_equalTo(0);
        }];
    }
    
    [self.view layoutIfNeeded];
    
    self.currChildViewController = childVC;
}

- (void)dismissGlobalSearch
{
    if(self.globalSearchController == nil)
        return;
    
    [self.globalSearchController.view endEditing:YES];
    [self.globalSearchController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController setNeedsStatusBarAppearanceUpdate];
}

- (void)openChatItem:(MXChat *)chat withFeedObject:(id)feed
{
    MXChatViewController *chatViewController = [[MXChatViewController alloc] initWithChat:chat];
    chatViewController.title = chat.topic;
    if (feed)
    {
        [chatViewController scrollToFeed:feed];
    }
    chatViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Option" style:UIBarButtonItemStylePlain target:self action:@selector(chatSettingButtonTapped:)];
    if ([self.presentedViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *naviGator = (UINavigationController *)self.presentedViewController;
        [naviGator pushViewController:chatViewController animated:YES];
    }
    else
    {
        [self.navigationController pushViewController:chatViewController animated:YES];
    }
}

- (void)openInviteControllerWithHandleSelectedUsers:(void(^)(NSArray<MXUserItem *> *users))handler
{
    MCInviteViewController *inviteVC = [[MCInviteViewController alloc] initWithHandleSelectedUsers:handler];
    self.navigator.viewControllers = @[inviteVC];
    UIViewController *fronMostVC = [[UIApplication sharedApplication].keyWindow mc_frontMostViewController];
    [fronMostVC presentViewController:self.navigator animated:YES completion:nil];
}

- (void)chatSettingButtonTapped:(UIBarButtonItem *)sender
{
    if ([self.presentedViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *naviGator = (UINavigationController *)self.presentedViewController;
        MXChatViewController *currentChatVC = (MXChatViewController *)[naviGator.viewControllers lastObject];
        MCChatSettingViewController *settingViewController = [[MCChatSettingViewController alloc] initWithChatItem:currentChatVC.chat];
        [naviGator pushViewController:settingViewController animated:YES];
    }
    else if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[MXChatViewController class]])
    {
        MXChatViewController *currentChatVC = (MXChatViewController *)[self.navigationController.viewControllers lastObject];
        MCChatSettingViewController *settingViewController = [[MCChatSettingViewController alloc] initWithChatItem:currentChatVC.chat];
        [self.navigationController pushViewController:settingViewController animated:YES];
    }
}

#pragma mark - MCMessageCenterInstanceDelegate

- (void)instanceDidLogout:(MCMessageCenterInstance *)instance
{
    if (!instance.online)
    {
        [self presentChildViewController:nil];
        _chatListViewController = nil;
        _fileListViewController = nil;
        _todoListViewController = nil;
        _meetListViewController = nil;
        _userListViewController = nil;
    }
}

#pragma mark - MXMeetListModelDelegate

- (void)meetListModel:(MXMeetListModel *)meetListModel didStartMeet:(MXMeet *)meet
{
    //if no session in progress and no ring call popuped. popup a ring call
    if( self.meetCallViewController == nil && meet != nil )
    {
        //if host not myself. popup ring call.
        if (meet != nil && !meet.host.isMyself)
        {
            self.meetCallViewController = [[MCMeetRingCallViewController alloc] initWithMeetItem:meet];
            self.meetCallViewController.delegate = self;
            [[UIApplication sharedApplication].keyWindow.mc_frontMostViewController presentViewController:self.meetCallViewController animated:NO completion:nil];
        }
    }
}

- (void)meetListModel:(MXMeetListModel *)meetListModel didEndMeet:(MXMeet *)meet
{
    if (self.meetCallViewController != nil)
    {
        if ([meet isEqual:self.meetCallViewController.meetItem])
        {
            [self.meetCallViewController dismissViewControllerAnimated:NO completion:nil];
            self.meetCallViewController = nil;
        }
    }
}

#pragma mark - MCMeetRingCallViewControllerDelegate

- (void)meetRingCallView:(MCMeetRingCallViewController *)sender didAcceptWithMeetItem:(MXMeet *)meetItem
{
    [self.meetCallViewController dismissViewControllerAnimated:NO completion:nil];
    self.meetCallViewController = nil;
    [self.meetListModel joinMeetWithMeetId:meetItem.meetId completionHandler:^(NSError * _Nullable error, MXMeetSession * _Nullable meetSession) {
        if (meetSession != nil)
        {
            [meetSession presentMeetWindow];
        }
    }];
}

- (void)meetRingCallView:(MCMeetRingCallViewController *)sender didDeclineWithMeetItem:(MXMeet *)meetItem
{
    [self.meetCallViewController dismissViewControllerAnimated:NO completion:nil];
    self.meetCallViewController = nil;
}

#pragma mark - WidgetsActions

- (void)userInfoCloseButtonClicked:(UIBarButtonItem *)sender
{
    if (self.presentedViewController == self.navigator)
    {
        [self.navigator dismissViewControllerAnimated:YES completion:nil];
    }
}

@end

