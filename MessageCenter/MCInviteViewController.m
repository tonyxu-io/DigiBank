//
//  MCInviteViewController.m
//  DigiBank
//
//  Created by Moxtra on 2017/4/6.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCInviteViewController.h"
#import "MCUserListViewController.h"
#import "MCUserInfoViewController.h"
#import "MCUserListCell.h"
#import <objc/runtime.h>

@interface MXUserItem (MCInviteExtension)

@property (nonatomic, assign) BOOL selected;

@end

static NSString *const kUserItemSelectedIdentifier = @"";

@implementation MXUserItem (MCInviteExtension)

- (void)setSelected:(BOOL)selected
{
    objc_setAssociatedObject(self, CFBridgingRetain(kUserItemSelectedIdentifier), @(selected), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)selected
{
    return [objc_getAssociatedObject(self, CFBridgingRetain(kUserItemSelectedIdentifier)) boolValue];
}

@end

@interface MCInviteViewController ()<UITableViewDelegate,UITableViewDataSource,MXUserListModelDelegate,UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) MXUserListModel *userListModel;
@property (nonatomic, strong) NSArray<MCUserSection*> *userSections;
@property (nonatomic, strong) NSArray<MXUserItem *> *users;
@property (nonatomic, strong) NSArray<MXUserItem*> *searchResult;

@property (nonatomic, copy) void(^handleSelectedUsers)(NSArray <MXUserItem *> *users);

@end

static NSString *const kReuseIdentifier = @"kReuseIdentifier";
static NSString *const kSearchBarPlaceHolder = @"Search";
static CGFloat const kRowHeight = 54.f;


@implementation MCInviteViewController

- (instancetype)initWithHandleSelectedUsers:(void (^)(NSArray<MXUserItem *> *))handler
{
    if (self = [super init])
    {
        [self setupNavigationItems];
        self.handleSelectedUsers = handler;
    }
    return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Invite", @"Invite");
    [self setupNavigationItems];
    [self setupTableView];
    [self setupSearchBar];
    
    //Use MXUserListModel to get contact
    MXUserListModel *itemsModel = [[MXUserListModel alloc] init];
    self.userListModel = itemsModel;
    self.userListModel.delegate = self;
    
    //Seperate data to different section
    self.userSections = [MCUserSection getUserSectionArrayWithUsers:itemsModel.users];
    self.users = [itemsModel.users copy];
}

- (void)dealloc
{
    for (MXUserItem *user in self.users) {
        objc_removeAssociatedObjects(user);
    }
}

#pragma mark - Getter

- (BOOL)isSearching
{
    return self.searchBar.isFirstResponder;
}

#pragma mark - UserInterface

- (void)setupNavigationItems
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"Invite") style:UIBarButtonItemStyleDone target:self action:@selector(inviteButtonTapped:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonTapped:)];
}

- (void)setupTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.estimatedRowHeight = kRowHeight;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.allowsMultipleSelection = YES;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)setupSearchBar
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.barTintColor = [UIColor whiteColor];
    self.searchBar.tintColor = MCColorFontGray;
    self.searchBar.placeholder = NSLocalizedString(kSearchBarPlaceHolder, kSearchBarPlaceHolder);
    self.tableView.tableHeaderView = self.searchBar;
    self.searchBar.delegate = self;
}

#pragma mark - UITableViewDataSource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self isSearching])
    {
        return 1;
    }
    else
    {
        return self.userSections.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self isSearching])
    {
        return self.searchResult.count;
    }
    else
    {
        return self.userSections[section].data.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @WEAK_OBJ(tableView);
    @WEAK_OBJ(indexPath);
    MCUserListCell *userCell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier];
    MXUserItem *userItem;
    if ([self isSearching])
    {
        userItem = self.searchResult[indexPath.row];
    }
    else
    {
        userItem = self.userSections[indexPath.section].data[indexPath.row];
    }
    if (userCell == nil)
    {
        userCell = [[MCUserListCell alloc] initWithReuseIdentifier:kReuseIdentifier cellType:MCUserListCellTypeCheck widgetAction:^(MCUserListCell *cell, id sender) {
            UIControl *control = (UIControl *)sender;
            cell.user.selected = control.selected;
            if (control.selected)
            {
                [tableViewWeak selectRowAtIndexPath:indexPathWeak animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            else
            {
                [tableViewWeak deselectRowAtIndexPath:indexPathWeak animated:NO];
            }
        }];
    }
    userCell.user = userItem;
    userCell.control.selected = userItem.selected;
    if (userItem.selected)
    {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    return userCell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self isSearching])
    {
        return nil;
    }
    return [self sectionIndexTitlesForTableView:tableView][section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCUserListCell *userCell = (MCUserListCell *)[tableView cellForRowAtIndexPath:indexPath];
    userCell.control.selected = userCell.user.selected = !userCell.user.selected;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCUserListCell *userCell = (MCUserListCell *)[tableView cellForRowAtIndexPath:indexPath];
    userCell.control.selected = userCell.user.selected = !userCell.user.selected;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kRowHeight;
}

//SectionIndex
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if ([self isSearching])
    {
        return nil;
    }
    NSDictionary *sectionsMap = [self.userSections dictionaryWithValuesForKeys:@[@"title"]];
    return [[sectionsMap objectForKey:@"title"] sortedArrayUsingComparator:^NSComparisonResult(NSString   * _Nonnull  obj1, NSString *  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

- (void)inviteButtonTapped:(UIBarButtonItem *)sender
{
    if (self.handleSelectedUsers)
    {
        NSMutableArray *seletedUsers = [[NSMutableArray alloc] init];
        for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
            [seletedUsers addObject:self.userSections[indexPath.section].data[indexPath.row]];
        }
        self.handleSelectedUsers([seletedUsers copy]);
    }
}

- (void)cancelButtonTapped:(UIBarButtonItem *)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSMutableArray *searchResults = [[NSMutableArray alloc] init];
    //Local search by name
    for (MXUserItem *item in self.users) {
        if ([item.firstname containsString:searchText] || [item.lastname containsString:searchText]) {
            [searchResults addObject:item];
        }
    }
    self.searchResult = [searchResults copy];
    //Update display
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    searchBar.text = nil;
    [searchBar resignFirstResponder];
    self.searchResult = nil;
    [self.tableView reloadData];
}

@end
