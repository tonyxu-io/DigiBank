//
//  MCChatCategoryViewController.m
//  DigiBank
//
//  Created by Moxtra on 2017/4/17.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCChatEditCategoryViewController.h"

@interface MCChatEditCategoryViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) MXChat *chat;
@property (nonatomic, strong) MXChatListModel *chatListModel;
@property (nonatomic, strong) NSArray<MXChatCategory *>* categoryList;
@property (nonatomic, copy) void(^completeUpdateCategory)(MXChatCategory *newChatCategory);

@end

static NSString *const kNormalCellReuseIdentifier = @"kNormalCellReuseIdentifier";

@implementation MCChatEditCategoryViewController

#pragma mark - LifeCycle

- (instancetype)initWithChatItem:(MXChat *)chat completeHandle:(void (^)(MXChatCategory *))handler
{
    if (self = [super init])
    {
        _chat = chat;
        _completeUpdateCategory = handler;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Category", @"Category");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"common_button_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleDone target:self action:@selector(addButtonTapped:)];
    
    [self setupUserInterface];
    [self loadCategoryList];
}

#pragma mark - Getter

- (MXChatListModel *)chatListModel
{
    if (_chatListModel == nil)
    {
        _chatListModel = [MCMessageCenterInstance sharedInstance].chatListModel;
    }
    return _chatListModel;
}

#pragma mark - UserInterface

- (void)setupUserInterface
{
    //Setup TableView
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - DataProcess

- (void)loadCategoryList
{
    //Sort the category list.
    NSMutableArray *sortedCategoryList = [[self.chatListModel.categories sortedArrayUsingComparator:^NSComparisonResult(MXChatCategory *obj1, MXChatCategory *obj2) {
        NSUInteger isDefault1 = obj1.isDefault;
        NSUInteger isDefault2 = obj2.isDefault;
        if (isDefault1 != isDefault2)
            return isDefault2 > isDefault1;
        else
            return [obj1.name compare:obj2.name];
    }] mutableCopy];
    self.categoryList = [sortedCategoryList copy];
}

#pragma mark - UITableViewDataSource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.categoryList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *categoryCell = [tableView dequeueReusableCellWithIdentifier:kNormalCellReuseIdentifier];
    if (categoryCell == nil)
    {
        categoryCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kNormalCellReuseIdentifier];
    }
    MXChatCategory *category = self.categoryList[indexPath.row];
    NSArray *chatsInCategory = [self.chatListModel chatsInCategory:category];
    if ([self.chat.category isEqual:category])
    {
        categoryCell.textLabel.textColor = MXBlueColor;
        categoryCell.detailTextLabel.textColor = MXBlueColor;
    }
    else
    {
        categoryCell.textLabel.textColor = MXBlackColor;
        categoryCell.detailTextLabel.textColor = MXBlackColor;
    }
    categoryCell.textLabel.text = category.name;
    categoryCell.detailTextLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)chatsInCategory.count];
    return categoryCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @WEAKSELF;
    MXChatCategory *category = self.categoryList[indexPath.row];
    [self.chat updateCategory:category withCompletionHandler:^(NSError * _Nullable errorOrNil) {
        if (errorOrNil)
        {
            [weakSelf mc_simpleAlertError:errorOrNil];
        }
        else
        {
            weakSelf.completeUpdateCategory(category);
            [weakSelf loadCategoryList];
            [weakSelf.tableView reloadData];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark - WidgetsActions

- (void)addButtonTapped:(UIBarButtonItem *)sender
{
    @WEAKSELF;
    __block UITextField *alertTextFiled;
    UIAlertController *addCategoryAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Category Name", @"Category Name") message:nil preferredStyle:UIAlertControllerStyleAlert];
    [addCategoryAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        alertTextFiled = textField;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Done", @"Done") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       [weakSelf.chatListModel createCategoryWithName:alertTextFiled.text completionHandler:^(NSError * _Nullable error, MXChatCategory * _Nullable category) {
           if (error)
           {
               [weakSelf mc_simpleAlertError:error];
           }
           else
           {
               [weakSelf loadCategoryList];
               [weakSelf.tableView reloadData];
           }
       }];
    }];
    [addCategoryAlert addAction:cancelAction];
    [addCategoryAlert addAction:confirmAction];
    [self presentViewController:addCategoryAlert animated:YES completion:nil];
}

@end
