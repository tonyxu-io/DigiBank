//
//  MCUserListViewController.m
//  DigiBank
//
//  Created by Moxtra on 2017/3/13.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCUserListViewController.h"
#import <Masonry.h>

#import "MCUserInfoViewController.h"
#import "MCUserListCell.h"

@implementation MCUserSection

- (instancetype)init {
    if (self = [super init]) {
        _data = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (NSArray<MCUserSection *> *)getUserSectionArrayWithUsers:(NSArray<MXUserItem *> *)users
{
    NSMutableArray *userSections = [[NSMutableArray alloc] init];
    NSMutableSet *firstLetter = [[NSMutableSet alloc] init];
    NSMutableDictionary *sectionsMap = [[NSMutableDictionary alloc] init];
    for (MXUserItem *user in users)
    {
        if (user.firstname.length >= 1)
        {
            if ([firstLetter containsObject:[user.firstname substringToIndex:1]])
            {
                //Use the exist MCContactSection
                MCUserSection *existSection = (MCUserSection *)[sectionsMap valueForKey:[user.firstname substringToIndex:1]];
                [existSection.data addObject:user];
            }
            else
            {
                //Create a MCContactSection
                if (user.firstname.length)
                {
                    MCUserSection *oneSection = [[MCUserSection alloc] init];
                    [sectionsMap setObject:oneSection forKey:[user.firstname substringToIndex:1]];
                    oneSection.title = [user.firstname substringToIndex:1];
                    [oneSection.data addObject:user];
                    [userSections addObject:oneSection];
                    [firstLetter addObject:[user.firstname substringToIndex:1]];
                }
            }
        }
    }
    [userSections sortUsingComparator:^NSComparisonResult(MCUserSection *obj1, MCUserSection *obj2) {
        return [obj1.title compare:obj2.title];
    }];
    return [userSections copy];
}

@end

@interface MCUserListViewController ()<UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate,MXUserListModelDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) MXUserListModel *userListModel;
@property (nonatomic, strong) NSArray<MCUserSection*> *userSections;
@property (nonatomic, strong) NSArray<MXUserItem*> *searchResult;
@property (nonatomic, strong) NSArray<MXUserItem *> *users;

@end

static NSString *const kReuseIdentifier = @"kReuseIdentifier";
static CGFloat const kRowHeight = 54.f;

@implementation MCUserListViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTableView];
    [self setupSearchBar];
}

#pragma mark - Getter

- (BOOL)isSearching
{
    return self.searchBar.isFirstResponder;
}

#pragma mark - UserInterface

- (void)setupTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.estimatedRowHeight = kRowHeight;
    self.tableView.tableFooterView = [UIView new];
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
    self.searchBar.placeholder = NSLocalizedString(@"Search", @"search");
    self.tableView.tableHeaderView = self.searchBar;
    self.searchBar.delegate = self;
}

#pragma mark - Public Method

- (void)loadUserList
{
    //Use MXUserListModel to get contact
    MXUserListModel *itemsModel = [[MXUserListModel alloc] init];
    self.userListModel = itemsModel;
    self.userListModel.delegate = self;
    
    //Seperate data to different section
    self.userSections = [MCUserSection getUserSectionArrayWithUsers:itemsModel.users];
    self.users = [itemsModel.users copy];
}

- (void)clearUserList
{
    self.userListModel = nil;
    self.userSections = nil;
    self.users = nil;
    [self.tableView reloadData];
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
    MCUserListCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier];
    MXUserItem *userItem;
    if ([self isSearching])
    {
        userItem = self.searchResult[indexPath.row];
    }
    else
    {
        userItem = self.userSections[indexPath.section].data[indexPath.row];
    }
    @WEAKSELF;
    if (cell == nil)
    {
        cell = [[MCUserListCell alloc] initWithReuseIdentifier:kReuseIdentifier cellType:MCUserListCellTypeCall widgetAction:^(MCUserListCell *cell, id sender) {
            //Handle when call button on clicked
            [weakSelf mc_simpleAlertWithTitle:@"Tip" message:@"Call feature is not supported now"];
        }];
    }
    cell.user = userItem;
    return cell;
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
    MXUserItem *userItem;
    if ([self isSearching])
    {
        userItem = self.searchResult[indexPath.row];
        [self searchBarCancelButtonClicked:self.searchBar];
    }
    else
    {
        userItem = self.userSections[indexPath.section].data[indexPath.row];
    }
    MCUserInfoViewController *userInfoVC = [[MCUserInfoViewController alloc] initWithUserItem:userItem userListModel:self.userListModel];
    userInfoVC.title = userItem.firstname;
    [self.navigationController pushViewController:userInfoVC animated:YES];
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

#pragma mark - MXUserListModelDelegate

- (void)userListModel:(MXUserListModel *)userListModel didCreateUsers:(NSArray<MXUserItem *> *)createdUsers
{
    if (userListModel == self.userListModel)
    {
        //Process duplicate
        NSMutableArray *users = [[NSMutableArray alloc] initWithArray:self.users];
        [users addObjectsFromArray:createdUsers];
        NSSet *newUsers = [NSSet setWithArray:users];
        self.userSections = [MCUserSection getUserSectionArrayWithUsers:[newUsers allObjects]];
        
        [self.tableView reloadData];
    }
}

- (void)userListModel:(MXUserListModel *)userListModel didUpdateUsers:(NSArray<MXUserItem *> *)updatedUsers
{
    if (userListModel == self.userListModel)
    {
        //Process duplicate
        NSMutableArray *users = [[NSMutableArray alloc] initWithArray:self.users];
        [users removeObjectsInArray:updatedUsers];
        NSMutableSet *newUsers = [NSMutableSet setWithArray:users];
        [newUsers addObjectsFromArray:updatedUsers];
        self.userSections = [MCUserSection getUserSectionArrayWithUsers:[newUsers allObjects]];
        
        [self.tableView reloadData];
    }
}

- (void)userListModel:(MXUserListModel *)userListModel didDeleteUsers:(NSArray<MXUserItem *> *)deletedUsers
{
    if (userListModel == self.userListModel)
    {
        NSMutableArray *users = [[NSMutableArray alloc] initWithArray:self.users];
        [users removeObjectsInArray:deletedUsers];
        
        [self.tableView reloadData];
    }
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
