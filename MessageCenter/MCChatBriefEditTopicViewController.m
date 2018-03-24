//
//  MCChatBriefEditTopicViewController.m
//  DigiBank
//
//  Created by Moxtra on 2017/4/17.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCChatBriefEditTopicViewController.h"

#import "MCInputTableViewCell.h"

@interface MCChatBriefEditTopicViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MCInputTableViewCell *topicEditCell;

@property (nonatomic, strong) MXChat *chat;
@property (nonatomic, strong) MXChatSession *chatSession;
@property (nonatomic, copy) void(^saveButtonTapped)(NSString *newTopic);

@end

static NSString *const kNormalCellReuseIdentifier = @"kNormalCellReuseIdentifier";
static NSString *const kInputCellReuseIdentifier = @"kInputCellReuseIdentifier";

@implementation MCChatBriefEditTopicViewController

#pragma mark - LifeCycle

- (instancetype)initWithChatItem:(MXChat *)chat completeHandler:(void (^)(NSString *))handler
{
    if (self = [super init])
    {
        _chat = chat;
        _saveButtonTapped = handler;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Topic", @"Topic");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"Save") style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonTapped:)];
    [self setupUserInterface];
    // Do any additional setup after loading the view.
}

#pragma mark - Getter

- (MXChatSession *)chatSession
{
    if (_chatSession == nil)
    {
        _chatSession = [[MXChatSession alloc] initWithChat:self.chat];
    }
    return _chatSession;
}

#pragma mark - UserInterface

- (void)setupUserInterface
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.left.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - UITableViewDataSource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCInputTableViewCell *editTopicCell = [tableView dequeueReusableCellWithIdentifier:kInputCellReuseIdentifier];
    if (editTopicCell == nil)
    {
        editTopicCell = [[MCInputTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kInputCellReuseIdentifier];
        editTopicCell.selectionStyle = UITableViewCellSelectionStyleGray;
        editTopicCell.backgroundColor = [UIColor whiteColor];
    }

    editTopicCell.text = self.chat.topic;
    self.topicEditCell = editTopicCell;
    return editTopicCell;
}

#pragma mark - WidgetsActions

- (void)saveButtonTapped:(UIBarButtonItem *)sender
{
    @WEAKSELF;
    [self.chatSession.chat updateTopic:self.topicEditCell.text withCompletionHandler:^(NSError * _Nullable error) {
        if (error)
        {
            [weakSelf mc_simpleAlertError:error];
        }
        else
        {
            if (weakSelf.saveButtonTapped)
            {
                weakSelf.saveButtonTapped(weakSelf.topicEditCell.text);
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
}

@end
