//
//  MCFileDeclineViewController.m
//  DigiBank
//
//  Created by Moxtra on 2017/4/11.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCFileDeclineViewController.h"

@interface MCFileDeclineViewController ()

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UITextView *reasonInputView;

@property (nonatomic, weak) MXChatSession *chatSession;
@property (nonatomic, strong) MXSignFileItem *signFileItem;

@end

static CGFloat const kTipLabelHeight = 44.f;

@implementation MCFileDeclineViewController

#pragma mark - LifeCycle

- (instancetype)initWithChatItemModel:(MXChatSession *)chatSession
                         signFileItem:(MXSignFileItem *)signItem
{
    if (self = [super init])
    {
        self.chatSession = chatSession;
        self.signFileItem = signItem;
        [self setupNavigationItem];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = MXGray08Color;
    self.title = self.signFileItem.name;
    [self setupUserInterface];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

#pragma mark - UserInterface

- (void)setupNavigationItem
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Decline", @"Decline") style:UIBarButtonItemStyleDone target:self action:@selector(declineButtonTapped:)];
}

- (void)setupUserInterface
{
    self.tipLabel = [[UILabel alloc] init];
    self.tipLabel.backgroundColor = MXGray08Color;
    self.tipLabel.textColor = MXGray60Color;
    self.tipLabel.font = [UIFont systemFontOfSize:12];
    self.tipLabel.text = NSLocalizedString(@"PLEASE PROVIDE A REASON FOR DECLINING:", @"PLEASE PROVIDE A REASON FOR DECLINING:");
    [self.view addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(20.f);
        make.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.height.mas_equalTo(kTipLabelHeight);
    }];
    
    self.reasonInputView = [[UITextView alloc] init];
    self.reasonInputView.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:self.reasonInputView];
    [self.reasonInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.tipLabel.mas_bottom);
    }];
}

#pragma mark - WidgetsActions

- (void)declineButtonTapped:(UIBarButtonItem *)sender
{
    @WEAKSELF;
    [self.view.window mc_startIndicatorViewAnimating];
    [self.view endEditing:YES];
    [self.chatSession declineSignFile:self.signFileItem withReason:self.reasonInputView.text completionHandler:^(NSError * _Nullable error) {
        [weakSelf.view.window mc_stopIndicatorViewAnimating];
        if (error)
        {
            [weakSelf mc_simpleAlertError:error];
        }
        else
        {
            [weakSelf.view.window mc_showMessage:NSLocalizedString(@"Decline Success", @"Decline Success")];
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
