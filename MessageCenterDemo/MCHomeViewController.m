//
//  MCHomeViewController.m
//  MessageCenter
//
//  Created by wubright on 2016/12/15.
//  Copyright © 2016年 moxtra. All rights reserved.
//

#import "MCHomeViewController.h"

#import "MCHomeAccountCell.h"
#import "MCHomeInvestmentCell.h"
#import "MCHomeNewsCell.h"
#import "MCAccountController.h"
#import "MCStatementController.h"
#include "MCMessageCenterViewController.h"
#import "MXUserItem+MCHelper.h"

#import <Masonry.h>
#import <ChatSDK/MXChatSDK.h>

@interface MCHomeViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *helloLabel;

@end

@implementation MCHomeViewController

#pragma mark - LifeCycle
- (id)init
{
    self = [super init];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        //Register login&logout notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(accoutStatusDidChanged:)
                                                     name:MCMessageCenterUserDidLoginNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(accoutStatusDidChanged:)
                                                     name:MCMessageCenterUserDidLogoutNotification
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Home", @"");
    self.view.backgroundColor = MCColorBackground;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    UIView *headerView = [UIView new];
    headerView.backgroundColor = MCColorMain;
    [self.view addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.height.equalTo(@100);
    }];
    
    self.helloLabel = [UILabel new];
    self.helloLabel.font = [UIFont systemFontOfSize:22.0f];
    self.helloLabel.textColor = [UIColor whiteColor];
    self.helloLabel.text = @"Hello,";
    [headerView addSubview:self.helloLabel];
    [self.helloLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView).offset(14.0f);
        make.right.equalTo(headerView).offset(-14.0);
        make.top.equalTo(headerView).offset(10.f);
    }];
    
    UILabel *welcomeLable = [UILabel new];
    welcomeLable.font = [UIFont systemFontOfSize:18.0f];
    welcomeLable.textColor = [UIColor whiteColor];
    welcomeLable.text = @"Welcome to digital banking";
    [headerView addSubview:welcomeLable];
    [welcomeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.helloLabel);
        make.right.equalTo(self.helloLabel);
        make.top.equalTo(self.helloLabel.mas_bottom).offset(20.f);
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.clipsToBounds = NO;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0, 0, 0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0;
    [self.tableView registerClass:[MCHomeAccountCell class] forCellReuseIdentifier:@"MCHomeAccountCell"];
    [self.tableView registerClass:[MCHomeInvestmentCell class] forCellReuseIdentifier:@"MCHomeInvestmentCell"];
    [self.tableView registerClass:[MCHomeNewsCell class] forCellReuseIdentifier:@"MCHomeNewsCell"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new];
    [self.view insertSubview:self.tableView atIndex:0];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(headerView.mas_bottom);
        make.bottom.equalTo(self.view);
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 2;
    else if(section == 1)
        return 2;
    else if(section == 2)
        return 2;
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [UILabel new];
    
    NSString *text;
    if (section == 0) {
        text = @"Account";
    } else if(section == 1) {
        text = @"Investments";
    } else {
        text = @"News";
    }
    
    label.text = text;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = MCColorFontBlack;
    UIView *headerView = [UIView new];
    headerView.backgroundColor = MCColorBackground;
    [headerView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(15);
    }];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        MCHomeAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MCHomeAccountCell" forIndexPath:indexPath];
        if (indexPath.row == 0)
        {
            cell.cardTypeLabel.text = @"Cash Reward Card";
            cell.cardAccountLabel.text = @"*1234";
            cell.cardAmountLabel.text = @"$1,2345";
        }
        else
        {
            cell.cardTypeLabel.text = @"Cash Reward Card";
            cell.cardAccountLabel.text = @"*8765";
            cell.cardAmountLabel.text = @"$898,2345";
        }
        
        return cell;
    }
    else if (indexPath.section == 1)
    {
        MCHomeInvestmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MCHomeInvestmentCell" forIndexPath:indexPath];
        if (indexPath.row == 0)
        {
            cell.nameLabel.text = @"Select Fund A";
            cell.accountLabel.text = @"*1234";
            cell.priceLabel.text = @"$1,3413";
            cell.rateLabel.text = @"+2.56%";
        }
        else
        {
            cell.nameLabel.text = @"Select Fund B";
            cell.accountLabel.text = @"*7893";
            cell.priceLabel.text = @"$9,3413";
            cell.rateLabel.text = @"+10.56%";
        }
        
        return cell;
    }
    else if (indexPath.section == 2)
    {
        MCHomeNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MCHomeNewsCell" forIndexPath:indexPath];
        if (indexPath.row == 0)
        {
            cell.topicLabel.text = @"Advisers managing $1.7 billion move to…";
            cell.detailLabel.text = @"Chris and Brian Cooke partner with the 108-year-old firm for strategic expansion";
        }
        else
        {
            cell.topicLabel.text = @"Women-owned advisory firms outperfo…";
            cell.detailLabel.text = @"Firms majority owned by women in InvestmentNews study were more like…";
        }
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        MCHomeAccountCell *cell = (MCHomeAccountCell*)[tableView cellForRowAtIndexPath:indexPath];
        MCAccountController *accountController = [[MCAccountController alloc] init];
        accountController.navigationItem.title = [NSString stringWithFormat:@"%@ %@", cell.cardTypeLabel.text, cell.cardAccountLabel.text];
        [self.navigationController pushViewController:accountController animated:YES];
    }
    else if (indexPath.section == 1)
    {
        MCStatementController *statementController = [[MCStatementController alloc] init];
        [self.navigationController pushViewController:statementController animated:YES];
    }
    
    [tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - Notifications

- (void)accoutStatusDidChanged:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[MXChatClient class]])
    {
        MXChatClient *chatClient = (MXChatClient *)notification.object;
        if (chatClient.currentUser.fullName.length > 0)
        {
            self.helloLabel.text = [NSString stringWithFormat:@"Hello, %@", chatClient.currentUser.fullName];
            return;
        }
    }
    self.helloLabel.text = @"Hello";
}
@end
