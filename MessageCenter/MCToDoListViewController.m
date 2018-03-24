//
//  TestToDoListViewController.m
//  DigiBank
//
//  Created by Moxtra on 2017/3/23.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCToDoListViewController.h"

#import "MCTodoListCell.h"
#import "MCExpandTableView.h"
#import "MCExpandHeadCell.h"
#import "MCExpandCompleteCell.h"
#import "MCMessageCenterViewController.h"

@interface MCToDoListViewController ()<MCExpandTableViewDelegate,MXChatListModelDelegate,MXChatSessionDelegate>

@property (nonatomic, strong) MCExpandTableView *tableView;
@property (nonatomic, strong) UINavigationController *todoInfoNavigator;
@property (nonatomic, strong) MCExpandHeadCell *lastExpandedCell;

@property (nonatomic, strong) MXChatListModel *chatListModel;
@property (nonatomic, strong) NSArray <MXChat *> *chatList;
@property (nonatomic, strong) MXChatSession *currentItemModel;
@property (nonatomic, strong) MCExpandModel *currentExpandModel;
@property (nonatomic, strong) NSMutableArray <MCExpandModel *> *expandModelArray;
@property (nonatomic, strong) NSArray *tempTodoArray;

@property (nonatomic, assign) BOOL needUpdateChatList;

@property (nonatomic, strong) dispatch_semaphore_t fetchTodoSema;

@end

static CGFloat const kExpandHeadHeight = 40.f;
static CGFloat const kFileListHeight = 54.f;
static CGFloat const kDefaultCellHeight = 44.f;
static CGFloat const kSignerCellHeight = 50.f;

static NSString *const kExpandHeadCellReuseIdentifier = @"kExpandHeadCellReuseIdentifier";
static NSString *const kExpandCompleteCellReuseIdentifier = @"kExpandCompleteCellReuseIdentifier";
static NSString *const kTodoListCellReuseIdentifier = @"kFileListCellReuseIdentifier";

@implementation MCToDoListViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.fetchTodoSema = dispatch_semaphore_create(0);

    [self setupTableView];
    [self loadTodoList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_needUpdateChatList)
    {
        [self loadTodoList];
    }
}

#pragma mark - Getter

- (UINavigationController *)todoInfoNavigator
{
    if (_todoInfoNavigator == nil)
    {
        _todoInfoNavigator = [[UINavigationController alloc] init];
        _todoInfoNavigator.navigationBar.barStyle = UIBarStyleBlack;
        _todoInfoNavigator.navigationBar.barTintColor = MCColorMain;
        _todoInfoNavigator.navigationBar.tintColor = [UIColor whiteColor];
        _todoInfoNavigator.navigationBar.translucent = NO;
        [_todoInfoNavigator.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:18.0f]}];
        _todoInfoNavigator.view.backgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.0f];
        _todoInfoNavigator.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    return _todoInfoNavigator;
}

- (MXChatListModel *)chatListModel
{
    //Manager a independent MXChatListModel byself.
    if (_chatListModel == nil)
    {
        _chatListModel = [[MXChatListModel alloc] init];
        _chatListModel.delegate = self;
    }
    return _chatListModel;
}

#pragma mark - UserInterface

- (void)setupTableView
{
    self.tableView = [[MCExpandTableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.manualHandleUpdate = YES;
    self.tableView.expandDelegate = self;
    
    [self.tableView registerClass:[MCExpandHeadCell class] forCellReuseIdentifier:kExpandHeadCellReuseIdentifier];
    [self.tableView registerClass:[MCTodoListCell class] forCellReuseIdentifier:kTodoListCellReuseIdentifier];
    [self.tableView registerClass:[MCExpandCompleteCell class] forCellReuseIdentifier:kExpandCompleteCellReuseIdentifier];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - PublicMethod

- (void)loadTodoList
{
    [self clearTodoList];
    //Get chat datas and put them in MXChatSession.
    NSArray *allChats = self.chatListModel.chats;
    self.chatList = [[allChats filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        MXChat *chat = evaluatedObject;
        return chat.todosCount > 0;
    }]] mutableCopy];
    self.chatList = [self.chatList sortedArrayUsingComparator:^NSComparisonResult(MXChat *obj1, MXChat *obj2) {
        return [obj2.lastFeedTime compare:obj1.lastFeedTime];
    }];
    
    self.expandModelArray = [[NSMutableArray alloc] init];
    
    [self.chatList enumerateObjectsUsingBlock:^(MXChat * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //Put chat item in MXChatSession to let them support expand & fold
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

- (void)clearTodoList
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
        MCExpandHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:kExpandHeadCellReuseIdentifier];
        MXChat *chat = model.object;
        [cell setTitle:chat.topic];
        [cell setBadgeNumber:chat.uncompleteTodosCount];
        [cell setExpanded:model.expand animated:NO];
        return cell;
    }
    else if ([model.object isKindOfClass:[MXTodoItem class]])
    {
        MCTodoListCell *cell = [tableView dequeueReusableCellWithIdentifier:kTodoListCellReuseIdentifier];
        MXTodoItem *todoItem = model.object;
        [cell setTodoItem:todoItem];
        return cell;
    }
    else if ([model.object isKindOfClass:[NSNumber class]])
    {
        MCExpandCompleteCell *completeCell = [tableView dequeueReusableCellWithIdentifier:kExpandCompleteCellReuseIdentifier];
        NSString *format = nil;
        if ([model.object boolValue])
        {
            format = NSLocalizedString(@"%d completed todos",@"%d completed todos");
        }
        else
        {
            format = NSLocalizedString(@"%d completed todo",@"%d completed todo");
        }
        [completeCell setTitle:[NSString stringWithFormat:format,model.subModel.count]];
        [completeCell setExpand:model.expand];
        return completeCell;
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
        self.currentExpandModel = model;
        //Close last expanded headcell
        [self.lastExpandedCell setExpanded:NO animated:YES];
        
        //When selected an 'Chat', then expand it with it's 'Todos'
        MCExpandHeadCell *selectedHeadCell = [tableView cellForRowAtIndexPath:indexPath];
        [selectedHeadCell setExpanded:!model.expand animated:YES];
        self.lastExpandedCell = selectedHeadCell;

        [self.view.window mc_startIndicatorViewAnimating];
        
        for (MCExpandModel *data in self.expandModelArray)
        {
            data.subModel = nil;
        }
        //Package data
        self.currentItemModel = [[MXChatSession alloc] initWithChat:model.object];
        self.currentItemModel.delegate = self;
        [self fetchTodosFillToExpandModel:self.currentExpandModel withTatgetIndex:indexPath completion:nil];
    }
    else if ([model.object isKindOfClass:[NSNumber class]])
    {
        //When selected a 'complete' head, change display
        MCExpandCompleteCell *completeCell = [tableView cellForRowAtIndexPath:indexPath];
        [completeCell setExpand:!model.expand];
        [self.tableView updateTableViewWithTargetIndex:indexPath];
    }
    else if ([model.object isKindOfClass:[MXTodoItem class]])
    {
        //Present todo info viewcontroller
        MXTodoViewController *todoInfo = [[MXTodoViewController alloc] initWithTodoItem:model.object];
        todoInfo.title = NSLocalizedString(@"To-Do Info", @"To-Do Info");
        self.todoInfoNavigator.viewControllers = @[todoInfo];
        todoInfo.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Close") style:UIBarButtonItemStyleDone target:self action:@selector(closeButtonTapped:)];
        [self presentViewController:self.todoInfoNavigator animated:YES completion:nil];
        [self.tableView updateTableViewWithTargetIndex:indexPath];
    }
}

- (CGFloat)mcExpandTableView:(MCExpandTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath expandModel:(MCExpandModel *)model
{
    if ([model.object isKindOfClass:[MXChat class]] || [model.object isKindOfClass:[NSNumber class]])
    {
        return kExpandHeadHeight;
    }
    else if ([model.object isKindOfClass:[MXFileItem class]])
    {
        return kFileListHeight;
    }
    else if ([model.object isKindOfClass:[MXUserItem class]])
    {
        return kSignerCellHeight;
    }
    else
        return kDefaultCellHeight;
}

#pragma mark - WidgetsAction

- (void)closeButtonTapped:(UIBarButtonItem *)sender
{
    [self.todoInfoNavigator dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - MXChatModelDelegate

- (void)chatSession:(MXChatSession *)chatSession didCreateTodos:(nonnull NSArray<MXTodoItem *> *)createdTodos
{
    
    [self handleChatItemDelegate];
}

- (void)chatSession:(MXChatSession *)chatSession didUpdateTodos:(NSArray<MXTodoItem *> *)updatedTodos
{
    [self handleChatItemDelegate];
}

- (void)chatSession:(MXChatSession *)chatSession didDeleteTodos:(NSArray<MXTodoItem *> *)deletedTodos
{
    //Pop over the TodoInfoViewController when it's todo get deleted
    MXTodoItem *selectedTodo = self.currentExpandModel.object;
    
    for (MXTodoItem *todo in deletedTodos) {
        if ([todo isEqual:selectedTodo])
        {
            if (self.todoInfoNavigator.viewControllers.count)
            {
                [self closeButtonTapped:nil];
                [self mc_simpleAlertWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"The todo has just be deleted", @"The todo has just be deleted")];
            }
        }
    }
    [self handleChatItemDelegate];
}

#pragma mark - Helper

- (void)fetchTodosFillToExpandModel:(MCExpandModel *)model withTatgetIndex:(NSIndexPath *)indexPath completion:(void(^)())handler
{
    @WEAKSELF;
    model.subModel = nil;
    [self.currentItemModel fetchTodosWithCompletionHandler:^(NSError * _Nullable errorOrNil, NSArray<MXTodoItem *> * _Nullable todosOrNil) {
        self.tempTodoArray = [[NSArray alloc] initWithArray:todosOrNil];
        NSMutableArray *completed = [[NSMutableArray alloc] init];
        [self.tempTodoArray enumerateObjectsUsingBlock:^(MXTodoItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MCExpandModel *todoModel = [MCExpandModel expandModelWithObject:obj identifier:obj.title];
            if (obj.isCompleted)
            {
                [completed addObject:todoModel];
            }
            else
            {
                [model addSubModel:todoModel];
            }
        }];
        if (completed.count > 0)
        {
            MCExpandModel *completedHead = [MCExpandModel expandModelWithObject:[NSNumber numberWithBool:@(YES)] identifier:@"complted"];
            completedHead.expand = YES;
            for (MCExpandModel *todo in completed) {
                [completedHead addSubModel:todo];
            }
            [model addSubModel:completedHead];
        }
        if (indexPath)
        {
            [weakSelf.view.window mc_stopIndicatorViewAnimating];
            [weakSelf.tableView updateTableViewWithTargetIndex:indexPath];
        }
        if (handler)
        {
            handler();
        }
    }];
}

- (void)handleChatItemDelegate
{
    @WEAKSELF;
    //Refetch todos in currentChat
    if (self.currentExpandModel && [self.currentExpandModel.object isKindOfClass:[MXChat class]])
    {
        [self.view.window mc_startIndicatorViewAnimating];
        [self fetchTodosFillToExpandModel:self.currentExpandModel withTatgetIndex:nil completion:^{
            [weakSelf.view.window mc_stopIndicatorViewAnimating];
            [weakSelf.tableView updateData];
        }];
    }
}

@end
