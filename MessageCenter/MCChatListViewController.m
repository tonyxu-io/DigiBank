//
//  MCChatListViewController.m
//  MessageCenter
//
//  Created by Rookie on 30/11/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import "MCChatListViewController.h"

#import "MCAddChatOptionController.h"
#import "MCInviteViewController.h"
#import "MCChatListCell.h"

static NSString * const kChatCellReuseIdentifier = @"kChatCellReuseIdentifier";
static CGFloat const kChatCellHeight = 95.f;

@interface MCChatListViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, MXChatListModelDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *createButton;               //Button used to create a new chat
@property (nonatomic, strong) UINavigationController *inviteNavigator;

@property (nonatomic, weak) MXChatListModel *chatListModel;
@property (nonatomic, strong) NSArray<MXChat *> *chatList;
@property (nonatomic, assign) CGFloat preOffset;                    //Storeage of createButton's previous offset.
@property (nonatomic, copy) NSComparator chatsComparator;           

@end

@implementation MCChatListViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUserInterface];
}

#pragma mark - Getter

- (NSComparator)chatsComparator
{
    return ^(MXChat *obj1, MXChat *obj2) {
        return [obj2.lastFeedTime compare:obj1.lastFeedTime];
    };
}

- (MXChatListModel *)chatListModel
{
    return [MCMessageCenterInstance sharedInstance].chatListModel;
}

#pragma mark - UserInterface

- (void)setupUserInterface
{
    //Setup TableView
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = kChatCellHeight;
    [self.tableView registerClass:[MCChatListCell class] forCellReuseIdentifier:kChatCellReuseIdentifier];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    //Setup SearchBar
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    searchBar.delegate = self;
    searchBar.placeholder = NSLocalizedString(@"Search", @"search");
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.barTintColor = [UIColor whiteColor];
    searchBar.tintColor = MCColorFontGray;
    self.tableView.tableHeaderView = searchBar;
    
    UIView *separator = [UIView new];
    separator.backgroundColor = [UIColor lightGrayColor];
    [searchBar addSubview:separator];
    [separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
    
    //Setup CreateButton
    self.createButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.createButton addTarget:self action:@selector(createButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.createButton setImage:[UIImage imageNamed:@"create_binder"] forState:UIControlStateNormal];
    [self.view addSubview:self.createButton];
    [self.createButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(-15);
        make.height.width.mas_equalTo(55);
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:kChatCellReuseIdentifier forIndexPath:indexPath];
    [cell setChat:self.chatList[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Open a chat using MXChatViewController
    [[MCMessageCenterViewController sharedInstance] openChatItem:self.chatList[indexPath.row] withFeedObject:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //Config createButton's position
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (offsetY > self.preOffset && offsetY > 0 && offsetY < scrollView.contentSize.height)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.createButton.transform = CGAffineTransformMakeTranslation(0, 100);
        }];
        self.preOffset = scrollView.contentOffset.y;
    }
    else if (offsetY < self.preOffset)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.createButton.transform = CGAffineTransformIdentity;
        }];
        self.preOffset = offsetY;
    }
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    //Use MXGlobalSearchViewController to search
    [[MCMessageCenterViewController sharedInstance] openGlobalSearch];
    return NO;
}

#pragma mark - Widgets Action

- (void)createButtonTapped:(UIButton *)sender
{
    @WEAKSELF;
    [[MCMessageCenterViewController sharedInstance] openInviteControllerWithHandleSelectedUsers:^(NSArray<MXUserItem *> *users) {
        MCAddChatOptionController *optionController  = [[MCAddChatOptionController alloc] initWithInvitedUsers:users];
        UINavigationController *currentNavi = (UINavigationController *)weakSelf.presentedViewController;
        [currentNavi pushViewController:optionController animated:YES];
    }];
}

#pragma mark - Public Method

- (void)loadChatList
{
    [self clearChatList];
    self.chatListModel.delegate = self;
    self.chatList = [[self sortedChatList:self.chatListModel.chats] mutableCopy];
    [self.tableView reloadData];
    [self updateBadge];
}

- (void)clearChatList
{
    self.chatList = nil;
    [self.tableView setContentOffset:CGPointZero];
    self.preOffset = 0;
    [self.tableView reloadData];
    [self updateBadge];
}

#pragma mark - MXChatListModelDelegate

- (void)chatListModel:(MXChatListModel *)chatListModel didCreateChats:(NSArray<MXChat *> *)createdChats
{
    NSMutableArray *chatList = [NSMutableArray arrayWithArray:self.chatList];
    [chatList binaryInsertObjects:createdChats withComparator:self.chatsComparator];
    
    [self refreshWithChatList:chatList];
}

- (void)chatListModel:(MXChatListModel *)chatListModel didUpdateChats:(NSArray<MXChat *> *)updatedChats
{
    NSMutableArray *chatList = [NSMutableArray arrayWithArray:self.chatList];
    [chatList removeObjectsInArray:updatedChats];
    [chatList binaryInsertObjects:updatedChats withComparator:self.chatsComparator];
    
    [self refreshWithChatList:chatList];
    
    for (MXChat *chat in updatedChats)
    {
        NSInteger row = [self.chatList indexOfObject:chat];
        if (row != NSNotFound)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            MCChatListCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell setChat:chat];
        }
    }
}

- (void)chatListModel:(MXChatListModel *)chatListModel didDeleteChats:(NSArray<MXChat *> *)deletedChats
{
    NSMutableArray *chatList = [NSMutableArray arrayWithArray:self.chatList];
    [chatList removeObjectsInArray:deletedChats];
    
    [self refreshWithChatList:chatList];
    
    //If the deleted chat are pushed, then pop them out.
    MXChat *selectedChatItem = self.chatList[self.tableView.indexPathForSelectedRow.row];
    for (MXChat *chat in deletedChats)
    {
        if ([chat isEqual:selectedChatItem])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        return;
        }
    }
}

#pragma mark - ChatList Operation

- (NSArray *)sortedChatList:(NSArray<MXChat *> *)chatList
{
    return [chatList sortedArrayUsingComparator:self.chatsComparator];
}

- (void)refreshWithChatList:(NSArray<MXChat *> *)chatList
{
    //Handle chats create/update/delete
    NSMutableArray *insertPaths = [NSMutableArray array];
    NSMutableArray *deletePaths = [NSMutableArray array];
    NSMutableArray *movePairArr = [NSMutableArray array];
    
    NSMutableSet *curChatSet = [NSMutableSet setWithArray:self.chatList];
    NSMutableSet *newChatSet = [NSMutableSet setWithArray:chatList];
    
    //Delete  chats
    NSMutableSet *deleteItems = [curChatSet mutableCopy];
    [deleteItems minusSet:newChatSet];
    for (MXChat *chat in deleteItems) {
        NSInteger index = [self.chatList indexOfObject:chat];
        if (index != NSNotFound) {
            [deletePaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }
    
    //Insert chats
    NSMutableSet *insertItems = [newChatSet mutableCopy];
    [insertItems minusSet:curChatSet];
    for (MXChat *chat in insertItems) {
        NSInteger index = [chatList indexOfObject:chat];
        if (index != NSNotFound) {
            [insertPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }
    
    //Move chats
    NSMutableSet *intersectTodoSet = [curChatSet mutableCopy];
    [intersectTodoSet intersectSet:newChatSet];
    for (MXChat *chat in intersectTodoSet) {
        NSInteger preRow = [self.chatList indexOfObject:chat];
        NSInteger curRow = [chatList indexOfObject:chat];
        if ((preRow != NSNotFound) && (curRow != NSNotFound) && (preRow != curRow)) {
            NSIndexPath *preIndexPath = [NSIndexPath indexPathForRow:preRow inSection:0];
            NSIndexPath *curIndexPath = [NSIndexPath indexPathForRow:curRow inSection:0];
            [movePairArr addObject:@[preIndexPath, curIndexPath]];
        }
    }
    
    self.chatList = chatList;
    
    if (deletePaths.count + insertPaths.count + movePairArr.count > 0)
    {
        [self.tableView beginUpdates];
        if (deletePaths.count > 0)
        {
            [self.tableView deleteRowsAtIndexPaths:deletePaths withRowAnimation:UITableViewRowAnimationTop];
        }
        
        if (insertPaths.count > 0)
        {
            [self.tableView insertRowsAtIndexPaths:insertPaths withRowAnimation:UITableViewRowAnimationTop];
        }
        
        if (movePairArr.count > 0)
        {
            for (NSArray *movePair in movePairArr)
            {
                [self.tableView moveRowAtIndexPath:movePair.firstObject toIndexPath:movePair.lastObject];
            }
        }
        [self.tableView endUpdates];
    }
    [self updateBadge];
}

- (void)updateBadge
{
    for (MXChat *chat in self.chatList)
    {
        if (chat.unreadFeedsCount > 0)
        {
            [[MCMessageCenterViewController sharedInstance] showInboxBadge:YES];
            return;
        }
    }
    [[MCMessageCenterViewController sharedInstance] showInboxBadge:NO];
}

@end
