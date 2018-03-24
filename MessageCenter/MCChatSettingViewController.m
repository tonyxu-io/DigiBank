//
//  MCChatSettingViewController.m
//  DigiBank
//
//  Created by Moxtra on 2017/4/14.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCChatSettingViewController.h"

#import "MCUserInfoViewController.h"
#import "MCChatBriefSettingViewController.h"
#import "MCChatEditCategoryViewController.h"
#import "MCChatEmailViewController.h"
#import "MCChatSettingBriefCell.h"
#import "MCChatSettingMemberCell.h"

@interface MCChatSettingViewController ()<UITableViewDataSource, UITableViewDelegate, MCChatBriefUpdateDelegate>

@property (nonatomic, strong) MXChat *chat;
@property (nonatomic, strong) MXChatSession *chatSession;
@property (nonatomic, strong) NSArray *tableViewData;

@property (nonatomic, strong) UITableView *tableView;

@end

static CGFloat const kBriefCellHeight = 90.f;
static CGFloat const kNormalCellHeight = 44.f;
static CGFloat const kSectionHeadHeight = 25.f;

static NSString *const kBriefCellReuseIdentifier = @"kBriefCellReuseIdentifier";
static NSString *const kMemberCellReuseIdentifier = @"kMemberCellReuseIdentifier";
static NSString *const kNormalCellReuseIdentifier = @"kNormalCellReuseIdentifier";
static NSString *const kValue1CellReuseIdentifier = @"kValue1CellReuseIdentifier";

@implementation MCChatSettingViewController

#pragma mark - LifeCycle

- (instancetype)initWithChatItem:(MXChat *)chat
{
    if (self = [super init])
    {
        self.chat = chat;
        self.chatSession = [[MXChatSession alloc] initWithChat:self.chat];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Setting", @"Setting");
    
    self.tableViewData = [self loadTableViewData];
    [self setupUserInterface];
}

#pragma mark - DataProcess

- (NSArray *)loadTableViewData
{
    //Package data
    //
    NSArray *firstSection = @[self.chat];
    
    //Notification setting
    NSArray *secondSection = @[@{NSLocalizedString(@"All Activities", @"All Activities"):@(!self.chat.isMute)},
                               @{NSLocalizedString(@"Nothing", @"Nothing"):@(self.chat.isMute)}];
    
    NSArray *thirdSection = @[@{NSLocalizedString(@"Category", @"Category"):self.chat.category.name},
                              @{NSLocalizedString(@"Chat Email", @"Chat Email"):self.chatSession.emailAddress}];
    
    //Memebers display and operation
    NSMutableArray *members = [[self fetchMembersArray] mutableCopy];
    NSTextAttachment *addImageAttach = [[NSTextAttachment alloc] init];
    addImageAttach.image = [[UIImage imageNamed:@"common_button_add"] mc_renderImageWithColor:MXBrandingColor];
    addImageAttach.bounds = CGRectMake(0, 0, 14, 14);
    NSMutableAttributedString *addString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@" Invite Members", @" Invite Members") attributes:@{NSForegroundColorAttributeName:MXBrandingColor}];
    NSMutableAttributedString *addAttributedString = [[NSMutableAttributedString attributedStringWithAttachment:addImageAttach] mutableCopy];
    [addAttributedString appendAttributedString:addString];
    [members insertObject:addAttributedString atIndex:0];
    NSArray *forthSection = [members copy];
    
    //Chat operation
    NSAttributedString *deleteString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Delete", @"Delete") attributes:@{NSForegroundColorAttributeName:MXRedColor,NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    NSArray *fifthSection = @[deleteString];
    
    return @[firstSection,secondSection,thirdSection,forthSection,fifthSection];
}

- (NSArray *)fetchMembersArray;
{
    //Get chat's members and sort them
    NSArray<MXUserItem *> *result;
    result = [NSArray arrayWithArray:self.chatSession.users];
    [result sortedArrayUsingComparator:^NSComparisonResult(MXUserItem *obj1, MXUserItem *obj2) {
        NSUInteger role1 = 0;
        NSUInteger role2 = 0;
        if (obj1.isMyself)
        {
            role1 = 1;
        }
        if ([self.chatSession.chat accessTypeForUser:obj1] == MXChatMemberAccessTypeOwner)
        {
            role1 = 2;
        }
        if (obj2.isMyself)
        {
            role2 = 1;
        }
        if ([self.chatSession.chat accessTypeForUser:obj2] == MXChatMemberAccessTypeOwner)
        {
            role2 = 2;
        }
        if(role1 != role2)
            return (role1 > role2)?NSOrderedAscending:NSOrderedDescending;
        
        return [obj1.firstname caseInsensitiveCompare:obj2.firstname];
    }];
    return result;
}

#pragma mark - UserInterface

- (void)setupUserInterface
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.tableView registerClass:[MCChatSettingBriefCell class] forCellReuseIdentifier:kBriefCellReuseIdentifier];
    [self.tableView registerClass:[MCChatSettingMemberCell class] forCellReuseIdentifier:kMemberCellReuseIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kNormalCellReuseIdentifier];
}

#pragma mark - UITableViewDataSource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tableViewData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableViewData[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *value1Cell = [tableView dequeueReusableCellWithIdentifier:kValue1CellReuseIdentifier];
    if (value1Cell == nil)
    {
        value1Cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kValue1CellReuseIdentifier];
    }
    
    switch (indexPath.section)
    {
        case 0:
        {
            //Brief Cell
            MCChatSettingBriefCell *briefCell = [tableView dequeueReusableCellWithIdentifier:kBriefCellReuseIdentifier];
            briefCell.chat = self.chat;
            MXChatMemberAccessType accessType = [self.chatSession.chat accessTypeForUser:[MCMessageCenterInstance sharedInstance].chatClient.currentUser];
            if (accessType == MXChatMemberAccessTypeOwner || accessType == MXChatMemberAccessTypeEditor)
            {
                briefCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else
            {
                briefCell.accessoryType = UITableViewCellAccessoryNone;
            }
            return briefCell;
        }
            break;
        case 1:
        {
            //Notification cell
            UITableViewCell *notifyCell = [tableView dequeueReusableCellWithIdentifier:kNormalCellReuseIdentifier];
            NSDictionary *notifySetDic = self.tableViewData[indexPath.section][indexPath.row];
            notifyCell.textLabel.text = (NSString *)[notifySetDic.allKeys firstObject];
            notifyCell.textLabel.textAlignment = NSTextAlignmentLeft;
            notifyCell.accessoryType = [[notifySetDic.allValues firstObject] boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            return notifyCell;
        }
            break;
        case 2:
        {
            //Catrgory & Email Cell
            value1Cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            NSDictionary *infoDic = self.tableViewData[indexPath.section][indexPath.row];
            value1Cell.textLabel.text = (NSString *)[infoDic.allKeys firstObject];
            value1Cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
            value1Cell.detailTextLabel.text = (NSString *)[infoDic.allValues firstObject];
            return value1Cell;
        }
            break;
        case 3:
        {
            if (indexPath.row == 0)
            {
                //Config invite button
                UITableViewCell *inviteCell = [tableView dequeueReusableCellWithIdentifier:kNormalCellReuseIdentifier];
                inviteCell.textLabel.textAlignment = NSTextAlignmentCenter;
                inviteCell.textLabel.attributedText = self.tableViewData[indexPath.section][indexPath.row];
                return inviteCell;
            }
            //Member cell
            MCChatSettingMemberCell *memberCell = [tableView dequeueReusableCellWithIdentifier:kMemberCellReuseIdentifier];
            MXUserItem *user = self.tableViewData[indexPath.section][indexPath.row];
            memberCell.userItem = user;
            [[MCMessageCenterInstance sharedInstance] getRoundedAvatarWithUser:user completionHandler:^(UIImage *avatar, NSError *error) {
                memberCell.imageView.image = avatar;
            }];
            memberCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            memberCell.accessType = [self.chatSession.chat accessTypeForUser:user];
            return memberCell;
        }
            break;
        case 4:
        {
            //Delete
            UITableViewCell *actionCell = [tableView dequeueReusableCellWithIdentifier:kNormalCellReuseIdentifier];
            actionCell.accessoryType = UITableViewCellAccessoryNone;
            [actionCell.textLabel setAttributedText:self.tableViewData[indexPath.section][indexPath.row]];
            actionCell.textLabel.textAlignment = NSTextAlignmentCenter;
            return actionCell;
        }
            break;
        default:
            return nil;
            break;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @WEAKSELF;
    switch (indexPath.section)
    {
        case 0:
        {
            MXChatMemberAccessType accessType = [self.chatSession.chat accessTypeForUser:[MCMessageCenterInstance sharedInstance].chatClient.currentUser];
            if (accessType == MXChatMemberAccessTypeOwner || accessType == MXChatMemberAccessTypeEditor)
            {
                MCChatBriefSettingViewController *briefSetViewController = [[MCChatBriefSettingViewController alloc] initWithChatItem:self.chat];
                briefSetViewController.updateDelegate = self;
                [self.navigationController pushViewController:briefSetViewController animated:YES];
            }
        }
            break;
        case 1:
        {
            if (indexPath.row == 0)
            {
                [self.chat mute:NO withCompletionHandler:^(NSError * _Nullable errorOrNil) {
                    UITableViewCell *markCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                                      inSection:1]];
                    UITableViewCell *clearCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1
                                                                                                    inSection:1]];
                    markCell.accessoryType = UITableViewCellAccessoryCheckmark;
                    clearCell.accessoryType = UITableViewCellAccessoryNone;
                }];
            }
            else
            {
                [self.chat mute:YES withCompletionHandler:^(NSError * _Nullable errorOrNil) {
                    UITableViewCell *markCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1
                                                                                                      inSection:1]];
                    UITableViewCell *clearCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
                    markCell.accessoryType = UITableViewCellAccessoryCheckmark;
                    clearCell.accessoryType = UITableViewCellAccessoryNone;
                }];
            }
        }
            break;
        case 2:
        {
            if (indexPath.row == 0)
            {
                //Category
                MCChatEditCategoryViewController *editCategoryVc = [[MCChatEditCategoryViewController alloc] initWithChatItem:self.chat completeHandle:^(MXChatCategory *newCategory) {
                    UITableViewCell *categoryCell = [tableView cellForRowAtIndexPath:indexPath];
                    categoryCell.detailTextLabel.text = newCategory.name;
                }];
                [self.navigationController pushViewController:editCategoryVc animated:YES];
            }
            else
            {
                //Emaill
                MCChatEmailViewController *emailViewController = [[MCChatEmailViewController alloc] initWithChatItem:self.chat emailAdress:self.chatSession.emailAddress];
                [self.navigationController pushViewController:emailViewController animated:YES];
            }
        }
            break;
        case 3:
        {
            if (indexPath.row == 0)
            {
                //Invite
                [[MCMessageCenterViewController sharedInstance] openInviteControllerWithHandleSelectedUsers:^(NSArray<MXUserItem *> *users) {
                    [weakSelf.chatSession inviteUsers:users withCompletionHandler:^(NSError * _Nullable error) {
                        if (error)
                        {
                            [weakSelf mc_simpleAlertError:error];
                        }
                        weakSelf.tableViewData = [self loadTableViewData];
                        [weakSelf.tableView reloadData];
                    }];
                    [weakSelf.presentedViewController dismissViewControllerAnimated:YES completion:nil];
                }];
            }
            else
            {
                //Choose 'User Info' or 'Delete'
                [self handleSelectedUser:self.tableViewData[indexPath.section][indexPath.row]];
            }
        }
            break;
        case 4:
        {
            if (indexPath.row == 0)
            {
                //Delete this chat
                UIAlertController *deleteAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notice", @"Notice") message:NSLocalizedString(@"Do you want delete this chat?", @"Do you want delete this chat?") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *delete = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", @"Delete") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf.view.window mc_startIndicatorViewAnimating];
                    [[MCMessageCenterInstance sharedInstance].chatListModel deleteOrLeaveChat:self.chat withCompletionHandler:^(NSError * _Nullable error) {
                        [weakSelf.view.window mc_stopIndicatorViewAnimating];
                        if (error)
                        {
                            [weakSelf mc_simpleAlertError:error];
                        }
                        else
                        {
                            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                        }
                    }];
                }];
                [deleteAlert addAction:cancel];
                [deleteAlert addAction:delete];
                [self presentViewController:deleteAlert animated:YES completion:nil];
            }
        }
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
            return kBriefCellHeight;
            break;
        default:
            return kNormalCellHeight;
            break;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 1:
            return NSLocalizedString(@"SEND NOTIFICATION AS", @"SEND NOTIFICATION AS");
            break;
        case 3:
            return NSLocalizedString(@"MEMBERS", @"MEMBERS");
            break;
        default:
            return @"";
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? DBL_EPSILON : kSectionHeadHeight;
}

#pragma mark - ConfigAlertController

- (void)handleSelectedUser:(MXUserItem *)userItem
{
    @WEAKSELF;
    MXChatMemberAccessType accessType = [self.chatSession.chat accessTypeForUser:userItem];
    if (accessType != MXChatMemberAccessTypeOwner)
    {
        if (!userItem.isMyself)
        {
            UIAlertController *userActionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            if (accessType == MXChatMemberAccessTypeEditor)
            {
                UIAlertAction *userInfoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"User Info", @"User Info") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf presentUserInfoWithUser:userItem];
                }];
                UIAlertAction *makeViewerAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Make Viewer", @"Make Viewer") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf.chatSession updateUser:userItem withAccessType:MXChatMemberAccessTypeViewer completionHandler:^(NSError * _Nullable error) {
                        if (error)
                        {
                            [weakSelf mc_simpleAlertError:error];
                        }
                        else
                        {
                            weakSelf.tableViewData = [self loadTableViewData];
                            [weakSelf.tableView reloadData];
                        }
                    }];
                }];
                [userActionSheet addAction:userInfoAction];
                [userActionSheet addAction:makeViewerAction];
            }
            if (accessType == MXChatMemberAccessTypeViewer)
            {
                UIAlertAction *makeEditorAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Make Editor", @"Make Editor") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf.chatSession updateUser:userItem withAccessType:MXChatMemberAccessTypeEditor completionHandler:^(NSError * _Nullable error) {
                        if (error)
                        {
                            [weakSelf mc_simpleAlertError:error];
                        }
                        else
                        {
                            weakSelf.tableViewData = [self loadTableViewData];
                            [weakSelf.tableView reloadData];
                        }
                    }];
                }];
                [userActionSheet addAction:makeEditorAction];
            }
            UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Remove", @"Remove") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                UIAlertController *tipAlert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Do you want remove this user", @"Do you want remove this member") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf.chatSession removeUser:userItem withCompletionHandler:^(NSError * _Nullable error) {
                        if (error)
                        {
                            [weakSelf mc_simpleAlertError:error];
                        }
                        else
                        {
                            weakSelf.tableViewData = [self loadTableViewData];
                            [weakSelf.tableView reloadData];
                        }
                    }];
                }];
                [tipAlert addAction:cancelAction];
                [tipAlert addAction:deleteAction];
                [weakSelf presentViewController:tipAlert animated:YES completion:nil];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
            
            [userActionSheet addAction:deleteAction];
            [userActionSheet addAction:cancelAction];
            [weakSelf presentViewController:userActionSheet animated:YES completion:nil];
            return;
        }
    }
    [self presentUserInfoWithUser:userItem];
}

- (void)presentUserInfoWithUser:(MXUserItem *)userItem
{
    MCUserInfoViewController *userInfoController = [[MCUserInfoViewController alloc] initWithUserItem:userItem userListModel:nil];
    [self.navigationController pushViewController:userInfoController animated:YES];
}

#pragma mark - MCChatBriefUpdateDelegate

- (void)briefSettingViewController:(MCChatBriefSettingViewController *)controller didUpdatedChatCoverWithImage:(UIImage *)newImage
{
    MCChatSettingBriefCell *briefCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    briefCell.chatCoverImageView.image = newImage;
}

- (void)briefSettingViewController:(MCChatBriefSettingViewController *)controller didUpdatedChatTopic:(NSString *)newTopic
{
    MCChatSettingBriefCell *briefCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    briefCell.topicLabel.text = newTopic;
    
    //Change chatViewController's title
    NSUInteger index = [self.navigationController.viewControllers indexOfObject:self];
    if (self.navigationController.viewControllers.count >= index)
    {
        MXChatViewController *chatViewController = self.navigationController.viewControllers[index-1];
        chatViewController.title = newTopic;
    }
}

- (void)briefSettingViewController:(MCChatBriefSettingViewController *)controller didUpdatedChatDescription:(NSString *)newDesc
{
    MCChatSettingBriefCell *briefCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    briefCell.descriptionLabel.text = newDesc;
}

@end
