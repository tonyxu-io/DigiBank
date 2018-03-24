//
//  MXAddBinderOptionController.m
//  MoxtraBinder
//
//  Created by bright wu on 14-12-5.
//
//

#import "MCAddBinderOptionController.h"
#import "MCMessageCenterViewController.h"
#import "AppDelegate.h"

#import "Masonry.h"

@interface MCAddBinderOptionController ()<UINavigationControllerDelegate>

@property (nonatomic, weak) MXChatListModel *chatListModel;

@end

@implementation MCAddBinderOptionController

- (id)init
{
    if(self = [super initWithNibName:nil bundle:nil])
    {
        
    }
    
    return self;
}

- (MXChatListModel *)chatListModel
{
    return [MCMessageCenterInstance sharedInstance].chatListModel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedString(@"Topic", @"Topic");
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.contentEdgeInsets = UIEdgeInsetsMake(4.0, 0.0f, 0.0, 0.0f);
    [doneButton setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    doneButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [doneButton sizeToFit];
    [doneButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    
    self.topicTextField = [UITextField new];
    [self.view addSubview:self.topicTextField];
    self.topicTextField.placeholder = NSLocalizedString(@"Name Your Conversation", @"");
    self.topicTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.topicTextField.textAlignment = NSTextAlignmentCenter;
    self.topicTextField.font = [UIFont systemFontOfSize:21.0f];
    [self.topicTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(60.0f);
        make.width.equalTo(self.view).multipliedBy(0.9f);
        make.height.greaterThanOrEqualTo(@0).priorityLow();
    }];
    
    self.splitLineView = [UIView new];
    self.splitLineView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.splitLineView];
    [self.splitLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topicTextField.mas_bottom).offset(0.0f);
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(0.9f);
        make.height.equalTo(@1);
    }];
    
    self.topicTitleLabel = [UILabel new];
    [self.view addSubview:self.topicTitleLabel];
    self.topicTitleLabel.text = NSLocalizedString(@"(Optional)", @"");
    self.topicTitleLabel.font = [UIFont systemFontOfSize:17];
    self.topicTitleLabel.textColor = [UIColor lightGrayColor];
    [self.topicTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.splitLineView.mas_bottom).offset(4.0f);
        make.centerX.equalTo(self.view);
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(self.topicTextField.text.length == 0)
        [self.topicTextField becomeFirstResponder];
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)doneButtonPressed:(id)sender
{
    @WEAKSELF;
    [self.topicTextField resignFirstResponder];
    
    [self.view.window mc_startIndicatorViewAnimating];
    
    NSString *topicName = [self.topicTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [self.chatListModel createChatWithTopic:topicName completionHandler:^(NSError * _Nullable error, MXChatItem * _Nullable chatItem) {
        [weakSelf.view.window mc_stopIndicatorViewAnimating];
        if (error)
        {
            [weakSelf mc_simpleAlertError:error];
        }
        
        if (chatItem)
        {
            MXChatItemModel *chatItemModel = [[MXChatItemModel alloc] initWithChatItem:chatItem];
            if (weakSelf.invitedItemsArray.count)
            {
                [chatItemModel inviteUsers:self.invitedItemsArray withCompletionHandler:^(NSError * _Nullable error) {
                    if (error)
                    {
                        [weakSelf mc_simpleAlertError:error];
                        [weakSelf.view.window mc_stopIndicatorViewAnimating];
                    }
                    [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
                    [[MCMessageCenterViewController sharedInstance] openChatItem:chatItem withFeedObject:nil];
                }];
            }
            else
            {
                [[MCMessageCenterViewController sharedInstance] openChatItem:chatItem withFeedObject:nil];

            }
            
        }

    }];
}


#pragma mark - UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.topicTextField.text = textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.topicTextField.text = textField.text;
    [self doneButtonPressed:nil];
    return YES;
}

@end
