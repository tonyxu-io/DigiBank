//
//  MCFileListViewController.m
//  DigiBank
//
//  Created by Moxtra on 2017/3/28.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCFileListViewController.h"

#import "MCFileDeclineViewController.h"
#import "MCExpandHeadCell.h"
#import "MCFileListCell.h"
#import "MCFileSigneeCell.h"
#import "MCFileSignActionCell.h"
#import "MCExpandCompleteCell.h"
#import "MCExpandTableView.h"

@interface MCFileListViewController ()<MCExpandTableViewDelegate,MXChatListModelDelegate, MXChatSessionDelegate>

@property (nonatomic, strong) UINavigationController *signFileNavigator;
@property (nonatomic, strong) MCExpandTableView *tableView;
@property (nonatomic, strong) MCExpandHeadCell *lastExpandedCell;

@property (nonatomic, strong) MXChatListModel *chatListModel;
@property (nonatomic, strong) NSArray <MXChat *> *chatList;
@property (nonatomic, strong) MXChatSession *currentChatSession;
@property (nonatomic, strong) MCExpandModel *currentExpandModel;
@property (nonatomic, strong) NSMutableArray <MCExpandModel *> *expandModelArray;
@property (nonatomic, strong) NSArray *tempFileArray;

@property (nonatomic, assign) BOOL needUpdateChatList;

@end

static CGFloat const kExpandHeadHeight = 40.f;
static CGFloat const kFileListHeight = 54.f;
static CGFloat const kDefaultCellHeight = 44.f;

static NSString *const kExpandHeadCellReuseIdentifier = @"kExpandHeadCellReuseIdentifier";
static NSString *const kExpandCompleteCellReuseIdentifier = @"kExpandCompleteCellReuseIdentifier";
static NSString *const kFileListCellReuseIdentifier = @"kFileListCellReuseIdentifier";
static NSString *const kFileSignerCellReuseIdentifier = @"kFileSignerCellReuseIdentifier";
static NSString *const kFileSignActionCellReuseIdentifier = @"kFileSignActionCellReuseIdentifier";

static NSString *const kSignActionIdentifier = @"kSignActionIdentifier";

@implementation MCFileListViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _needUpdateChatList = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupTableView];
    [self loadFileList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_needUpdateChatList)
    {
        [self loadFileList];
        _needUpdateChatList = NO;
    }
}

#pragma mark - Getter

- (UINavigationController *)signFileNavigator
{
    if (_signFileNavigator == nil)
    {
        _signFileNavigator = [[UINavigationController alloc] init];
        _signFileNavigator.navigationBar.barStyle = UIBarStyleBlack;
        _signFileNavigator.navigationBar.barTintColor = MCColorMain;
        _signFileNavigator.navigationBar.tintColor = [UIColor whiteColor];
        _signFileNavigator.navigationBar.translucent = NO;
        [_signFileNavigator.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:18.0f]}];
    }
    return _signFileNavigator;
}

- (MXUserItem *)currentUser
{
    return [MCMessageCenterInstance sharedInstance].chatClient.currentUser;
}

#pragma mark - UserInterface

- (void)setupTableView
{
    self.tableView = [[MCExpandTableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.expandDelegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.manualHandleUpdate = YES;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    [self.tableView registerClass:[MCExpandHeadCell class] forCellReuseIdentifier:kExpandHeadCellReuseIdentifier];
    [self.tableView registerClass:[MCExpandCompleteCell class] forCellReuseIdentifier:kExpandCompleteCellReuseIdentifier];
    [self.tableView registerClass:[MCFileListCell class] forCellReuseIdentifier:kFileListCellReuseIdentifier];
    [self.tableView registerClass:[MCFileSigneeCell class] forCellReuseIdentifier:kFileSignerCellReuseIdentifier];
    [self.tableView registerClass:[MCFileSignActionCell class] forCellReuseIdentifier:kFileSignActionCellReuseIdentifier];
}

#pragma mark - Public Method

- (void)loadFileList
{
    [self clearFileList];
    //Get chat datas and put them in MXChatSession.
    self.chatListModel = [[MXChatListModel alloc] init];
    self.chatListModel.delegate = self;
    
    NSArray *allChats = self.chatListModel.chats;
    //Filter the chat list, only keep the chat  which has e-sign files.
    self.chatList = [[allChats filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        MXChat *chat = evaluatedObject;
        return chat.signFilesCount > 0;
    }]] mutableCopy];
    
    self.chatList = [self.chatList sortedArrayUsingComparator:^NSComparisonResult(MXChat *obj1, MXChat *obj2) {
        return [obj2.lastFeedTime compare:obj1.lastFeedTime];
    }];
    
    self.expandModelArray = [[NSMutableArray alloc] init];
    [self.chatList enumerateObjectsUsingBlock:^(MXChat * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //Put chat item in MCExpandModel to let them support expand & fold
        MCExpandModel *model = [MCExpandModel expandModelWithObject:obj identifier:obj.lastFeedContent];
        //Forbid the models in same level could expand at the same time
        model.sameLevelExclusion = YES;
        [self.expandModelArray addObject:model];
    }];
    self.tableView.expandModels = self.expandModelArray;
    [self.tableView reloadData];
    
    //Code below must put here: after 'reloadData' called
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = view;
    
}

- (void)clearFileList
{
    self.chatListModel = nil;
    self.chatList = nil;
    self.expandModelArray = nil;
    [self.tableView setContentOffset:CGPointZero];
    [self.tableView clearData];
}

#pragma mark - MCExpandTableViewDelegate

- (UITableViewCell *)mcExpandTableView:(MCExpandTableView *)tableView cellForModel:(MCExpandModel *)model
{
    //Return cells in different type accroding to the model's class.
    if ([model.object isKindOfClass:[MXChat class]])
    {
        MCExpandHeadCell *headCell = [tableView dequeueReusableCellWithIdentifier:kExpandHeadCellReuseIdentifier];
        MXChat *chat = model.object;
        [headCell setTitle:chat.topic];
        [headCell setExpanded:model.expand animated:NO];
        [headCell setBadgeNumber:chat.myTurnSignFilesCount];
        return headCell;
    }
    else if ([model.object isKindOfClass:[MXSignFileItem class]])
    {
        MCFileListCell *fileCell = [tableView dequeueReusableCellWithIdentifier:kFileListCellReuseIdentifier];
        MXSignFileItem *fileItem = model.object;
        MXChatMemberAccessType type = [self.currentChatSession.chat accessTypeForUser:[self currentUser]];
        if (type == MXChatMemberAccessTypeOwner || type == MXChatMemberAccessTypeEditor)
        {
            fileCell.actionButtonHide = NO;
            UIAlertController *actionController = [self configFileActionsControllerWithItem:fileItem];
            if (actionController)
            {
                fileCell.actionButtonTapped = ^(MXSignFileItem *fileItem) {
                    [self presentViewController:actionController animated:YES completion:nil];
                };
            }
        }
        [fileCell setSignFileItem:fileItem];
        return fileCell;
    }
    else if ([model.object isKindOfClass:[NSNumber class]])
    {
        MCExpandCompleteCell *completeCell = [tableView dequeueReusableCellWithIdentifier:kExpandCompleteCellReuseIdentifier];
        NSString *format = NSLocalizedString(@"%d signed documents", @"%d signed documents");
        [completeCell setTitle:[NSString stringWithFormat:format,model.subModel.count]];
        [completeCell setExpand:model.expand];
        return completeCell;
    }
    else if ([model.object isKindOfClass:[MXUserItem class]])
    {
        MXSignFileItem *signFileModel = (MXSignFileItem *)model.fatherModel.object;
        MCFileSigneeCell *signerCell = [tableView dequeueReusableCellWithIdentifier:kFileSignerCellReuseIdentifier];
        [signerCell setFileSigner:model.object];
        [signerCell setSignState:[signFileModel stateForSignee:model.object]];
        return signerCell;
    }
    else if ([model.identifier isEqualToString:kSignActionIdentifier])
    {
        @WEAKSELF;
        MCFileSignActionCell *signerCell = [tableView dequeueReusableCellWithIdentifier:kFileSignActionCellReuseIdentifier];
        MXSignFileItem *signFileItem = (MXSignFileItem *)model.fatherModel.object;
        signerCell.declineButtonTapped = ^{
            [weakSelf handlePresentDeclineFileItem:signFileItem];
        };
        signerCell.signButtonTapped = ^{
            [weakSelf handlePresentSignFileItem:signFileItem];
        };
        return signerCell;
    }
    else
    {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        return cell;
    }
}

- (void)mcExpandTableView:(MCExpandTableView *)tableView didSelectedIndexPath:(NSIndexPath *)indexPath expandModel:(MCExpandModel *)model
{
    self.currentExpandModel = model;
    if ([model.object isKindOfClass:[MXChat class]])
    {
        //Close last expanded headcell
        [self.lastExpandedCell setExpanded:NO animated:YES];
        
        //When selected an 'Chat', then expand it with it's 'Files'
        MCExpandHeadCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        [selectedCell setExpanded:!model.expand animated:YES];
        self.lastExpandedCell = selectedCell;
        for (MCExpandModel *data in self.expandModelArray)
        {
            data.subModel = nil;
        }
        //Package data
        self.currentChatSession = [[MXChatSession alloc] initWithChat:model.object];
        self.currentChatSession.delegate = self;
        //Get sign files
        [self.view.window mc_startIndicatorViewAnimating];
        [self fetchSignFilesFillToExpandModel:model withTargetIndex:indexPath completion:nil];
    }
    else if ([model.object isKindOfClass:[NSNumber class]])
    {
        //When selected a 'complete' head, change display
        MCExpandCompleteCell *completeCell = [tableView cellForRowAtIndexPath:indexPath];
        [completeCell setExpand:!model.expand];
        [self.tableView updateTableViewWithTargetIndex:indexPath];
    }
    else if ([model.object isKindOfClass:[MXSignFileItem class]])
    {
        [self handlePresentNormalFileItem:model.object];
        [self.tableView updateTableViewWithTargetIndex:indexPath];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)mcExpandTableView:(MCExpandTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath expandModel:(MCExpandModel *)model
{
    if ([model.object isKindOfClass:[MXChat class]] || [model.object isKindOfClass:[NSNumber class]])
    {
        return kExpandHeadHeight;
    }
    else if ([model.object isKindOfClass:[MXFileItem class]])
    {
        return kFileListHeight;
    }
    else
        return kDefaultCellHeight;
}

#pragma mark - Interface Presenting

- (void)handlePresentNormalFileItem:(MXFileItem *)fileItem
{
    MXFileViewController *fileViewController = [[MXFileViewController alloc] initWithFileItem:fileItem];
    [self presentViewController:fileViewController animated:YES completion:nil];
}

- (void)handlePresentSignFileItem:(MXSignFileItem *)signItem
{
    MXSignFileViewController *signViewController = [[MXSignFileViewController alloc] initWithFileItem:signItem];
    [signViewController startToSign];
    [self presentViewController:signViewController animated:YES completion:nil];
}

- (void)handlePresentDeclineFileItem:(MXSignFileItem *)signItem
{
    MCFileDeclineViewController *declineViewController = [[MCFileDeclineViewController alloc] initWithChatItemModel:self.currentChatSession signFileItem:signItem];
    self.signFileNavigator.viewControllers = @[declineViewController];
    declineViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Close") style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonTapped:)];
    [self presentViewController:self.signFileNavigator animated:YES completion:nil];
}

#pragma mark - FileItem Operation

- (UIAlertController *)configFileActionsControllerWithItem:(MXSignFileItem *)signFileItem
{
    @WEAKSELF;
    @WEAK_OBJ(signFileItem);
    UIAlertController *actionController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *shareAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Share", @"Share") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.currentChatSession shareFiles:@[signFileItemWeak] withCompletionHandler:^(NSError * _Nullable error, NSURL * _Nullable shareURL, NSURL * _Nullable downloadURL) {
            UIActivityViewController *shareViewController = [[UIActivityViewController alloc] initWithActivityItems:@[shareURL] applicationActivities:nil];
            [weakSelf presentViewController:shareViewController animated:YES completion:nil];
        }];
    }];
    UIAlertAction *renameAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Rename", @"Rename") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *renameController = [UIAlertController alertControllerWithTitle:@"Rename" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [renameController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = signFileItem.name;
        }];
        @WEAK_OBJ(renameController);
        [renameController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil]];
        [renameController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.currentChatSession renameFile:signFileItemWeak withNewName:renameControllerWeak.textFields.firstObject.text completionHandler:^(NSError * _Nullable error) {
                if (error)
                {
                    [weakSelf mc_simpleAlertError:error];
                }
                else
                {
                    [weakSelf handleChatItemDelegate];
                }
            }];
        }]];
        [actionController dismissViewControllerAnimated:YES completion:nil];
        [weakSelf presentViewController:renameController animated:YES completion:nil];
        [renameController becomeFirstResponder];
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", @"Delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *deleteController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm", @"Confirm") message:NSLocalizedString(@"Do you want to delete the file?", @"Do you want to delete the file?") preferredStyle:UIAlertControllerStyleAlert];
        [deleteController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil]];
        [deleteController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", @"Delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.currentChatSession deleteFiles:@[signFileItemWeak] withCompletionHandler:^(NSError * _Nullable error) {
                if (error)
                {
                    [weakSelf mc_simpleAlertError:error];
                }
                else
                {
                    [weakSelf handleChatItemDelegate];
                }
            }];
        }]];
        [actionController dismissViewControllerAnimated:YES completion:nil];
        [weakSelf presentViewController:deleteController animated:YES completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    if (signFileItem.state == MXSignFileItemStateFinished)
    {
        [actionController addAction:shareAction];
    }
    if (signFileItem.owner.isMyself)
    {
        if (signFileItem.state != MXSignFileItemStateFinished)
        {
            [actionController addAction:renameAction];
            [actionController addAction:deleteAction];
        }
    }
    [actionController addAction:cancelAction];
    if (actionController.actions.count == 1)
    {
        return nil;
    }
    return  actionController;
}


#pragma mark - WidgetsActions

- (void)closeButtonTapped:(UIBarButtonItem *)sender
{
    [self.signFileNavigator dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MXChatListModelDelegate

- (void)chatListModel:(MXChatListModel *)chatListModel didCreateChats:(NSArray<MXChat *> *)createdChats
{
    _needUpdateChatList = YES;
}

- (void)chatListModel:(MXChatListModel *)chatListModel didUpdateChats:(NSArray<MXChat *> *)updatedChats
{
    _needUpdateChatList = YES;
}

- (void)chatListModel:(MXChatListModel *)chatListModel didDeleteChats:(nonnull NSArray<MXChat *> *)deletedChats
{
    _needUpdateChatList = YES;
}

#pragma mark - ChatItemModelDelegate

- (void)chatSession:(MXChatSession *)chatSession didCreateSignFiles:(nonnull NSArray<MXSignFileItem *> *)createdFiles
{
    [self handleChatItemDelegate];
}

- (void)chatSession:(MXChatSession *)chatSession didUpdateSignFiles:(NSArray<MXSignFileItem *> *)updatedFiles
{
    [self handleChatItemDelegate];
}

- (void)chatSession:(MXChatSession *)chatSession didDeleteSignFiles:(nonnull NSArray<MXSignFileItem *> *)deletedFiles
{
    //The MXSignFileViewController will handle this situation by itself, we don't need to pop or dismiss the MXSignFileViewController.
    [self handleChatItemDelegate];
}

#pragma mark - Helper

- (void)fetchSignFilesFillToExpandModel:(MCExpandModel *)model withTargetIndex:(NSIndexPath *)indexPath completion:(void(^)())handler
{
    @WEAKSELF;
    //Get sign files
    model.subModel = nil;
    [self.currentChatSession fetchSignFilesWithCompletionHandler:^(NSError * _Nullable error, NSArray<MXSignFileItem *> * _Nullable signFiles) {
        weakSelf.tempFileArray = [signFiles sortedArrayUsingComparator:^NSComparisonResult(MXSignFileItem *obj1, MXSignFileItem *obj2) {
            return [obj2.updatedTime compare:obj1.updatedTime];
        }];
        NSMutableArray *completed = [[NSMutableArray alloc] init];
        
        [weakSelf.tempFileArray enumerateObjectsUsingBlock:^(MXSignFileItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //Package data
            MCExpandModel *fileModel = [MCExpandModel expandModelWithObject:obj identifier:obj.name];
            fileModel.expand = YES;
            fileModel.interactionEnabled = NO;
            if (obj.state == MXSignFileItemStateFinished || obj.state == MXSignFileItemStateFailed || obj.state == MXSignFileItemStateInvalid)
            {
                [completed addObject:fileModel];
            }
            else
            {
                [model addSubModel:fileModel];
            }
            if (obj.state == MXSignFileItemStateInProgress)
            {
                if (obj.currentSignee.isMyself)
                {
                    //My turn to sign file
                    MCExpandModel *signActionModel = [MCExpandModel expandModelWithObject:nil identifier:kSignActionIdentifier];
                    [fileModel addSubModel:signActionModel];
                }
                MCExpandModel *signeeModel = [MCExpandModel expandModelWithObject:obj.currentSignee identifier:obj.currentSignee.uniqueId];
                [fileModel addSubModel:signeeModel];
                
                for (MXUserItem *signee in obj.allSignees)
                {
                    //Add other sinees
                    if (![signee isEqual:obj.currentSignee])
                    {
                        MCExpandModel *signeeModel = [MCExpandModel expandModelWithObject:signee identifier:signee.uniqueId];
                        [fileModel addSubModel:signeeModel];
                    }
                }
            }
        }];
        
        if (completed.count > 0)
        {
            MCExpandModel *completedHead = [MCExpandModel expandModelWithObject:[NSNumber numberWithBool:@(YES)] identifier:@"completed"];
            completedHead.expand = YES;
            for (MCExpandModel *file in completed)
            {
                [completedHead addSubModel:file];
            }
            [model addSubModel:completedHead];
        }
        [weakSelf.view.window mc_stopIndicatorViewAnimating];
        if (indexPath != nil)
        {
            [weakSelf.tableView updateTableViewWithTargetIndex:indexPath];
        }
        if (handler) {
            handler();
        }
    }];
}

- (void)handleChatItemDelegate
{
    @WEAKSELF;
    //Refetch all the sign files in this chat
    if (self.currentExpandModel && [self.currentExpandModel.object isKindOfClass:[MXChat class]])
    {
        [self.view.window mc_startIndicatorViewAnimating];
        [self fetchSignFilesFillToExpandModel:self.currentExpandModel withTargetIndex:nil completion:^{
            [weakSelf.view.window mc_stopIndicatorViewAnimating];
            [weakSelf.tableView updateData];
        }];
    }
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [[MCMessageCenterViewController sharedInstance] openGlobalSearch];
    return NO;
}

@end

