//
//  MCChatBriefEditDescViewController.m
//  DigiBank
//
//  Created by Moxtra on 2017/4/17.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCChatBriefEditDescViewController.h"

@interface MCChatBriefEditDescViewController ()

@property (nonatomic, strong) UITextView *editDescView;

@property (nonatomic, strong) MXChat *chat;
@property (nonatomic, strong) MXChatSession *chatSession;
@property (nonatomic, copy) void(^saveButtonTapped)(NSString *newDesc);

@end

@implementation MCChatBriefEditDescViewController

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
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"Chat Description", @"Chat Description");
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
    self.editDescView = [[UITextView alloc] init];
    self.editDescView = [[UITextView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f))];
    [self.view addSubview:self.editDescView];
    self.editDescView.font = [UIFont systemFontOfSize:20];
    self.editDescView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.editDescView.backgroundColor = [UIColor clearColor];
    self.editDescView.text = self.chatSession.descriptionString;
    self.editDescView.editable = YES;
}

#pragma mark - WidgetsActions

- (void)saveButtonTapped:(UIBarButtonItem *)sender
{
    @WEAKSELF;
    [self.chatSession updateDescripion:self.editDescView.text withCompletionHandler:^(NSError * _Nullable error) {
        if (error)
        {
            [weakSelf mc_simpleAlertError:error];
        }
        else
        {
            if (weakSelf.saveButtonTapped)
            {
                weakSelf.saveButtonTapped(weakSelf.editDescView.text);
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
