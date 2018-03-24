//
//  MCChatBriefSettingViewController.m
//  DigiBank
//
//  Created by Moxtra on 2017/4/17.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCChatBriefSettingViewController.h"

#import "MCChatSettingBriefCell.h"
#import "MCChatBriefEditTopicViewController.h"
#import "MCChatBriefEditDescViewController.h"

@interface MCChatBriefSettingViewController ()<UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    /**
     A struct to flag whether delegate implemented the protocol method
     */
    struct {
        unsigned int updateCoverFlag : 1;
        unsigned int updateTopicFlag : 1;
        unsigned int updateDescFlag : 1;
    }_delegateFlag;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, strong) MXChat *chat;
@property (nonatomic, strong) MXChatSession *chatSession;

@end

static CGFloat const kBriefCellHeight = 90.f;
static CGFloat const kNormalCellHeight = 44.f;

static NSString *const kBriefCellReuseIdentifier = @"kBriefCellReuseIdentifier";
static NSString *const kNormalCellReuseIdentifier = @"kNormalCellReuseIdentifier";

@implementation MCChatBriefSettingViewController

#pragma mark - LifeCycle

- (instancetype)initWithChatItem:(MXChat *)chat
{
    if (self = [super init])
    {
        _chat = chat;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Edit", @"Edit");
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUserInterface];
}

#pragma mark - Getter

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil)
    {
        _imagePicker = [[UIImagePickerController alloc]init];
        _imagePicker.allowsEditing = YES;
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

- (MXChatSession *)chatSession
{
    if (_chatSession == nil)
    {
        _chatSession = [[MXChatSession alloc] initWithChat:self.chat];
    }
    return _chatSession;
}

#pragma mark - Setter

- (void)setUpdateDelegate:(id<MCChatBriefUpdateDelegate>)updateDelegate
{
    _updateDelegate = updateDelegate;
    if ([_updateDelegate respondsToSelector:@selector(briefSettingViewController:didUpdatedChatCoverWithImage:)])
    {
        _delegateFlag.updateCoverFlag = YES;
    }
    if ([_updateDelegate respondsToSelector:@selector(briefSettingViewController:didUpdatedChatTopic:)])
    {
        _delegateFlag.updateTopicFlag = YES;
    }
    if ([_updateDelegate respondsToSelector:@selector(briefSettingViewController:didUpdatedChatDescription:)])
    {
        _delegateFlag.updateDescFlag = YES;
    }
}

#pragma mark - UserInterface

- (void)setupUserInterface
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    [self.tableView registerClass:[MCChatSettingBriefCell class] forCellReuseIdentifier:kBriefCellReuseIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kNormalCellReuseIdentifier];
}

#pragma mark - UITableViewDataSource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:kNormalCellReuseIdentifier];
    tableViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    tableViewCell.backgroundColor = [UIColor whiteColor];
    
    MCChatSettingBriefCell *chatBriefCell = [tableView dequeueReusableCellWithIdentifier:kBriefCellReuseIdentifier];
    switch (indexPath.row)
    {
        case 0:
        {
            chatBriefCell.type = MCChatSettingBriefCellTypeUpdate;
            chatBriefCell.chat = self.chat;
        }
            return chatBriefCell;
            break;
        case 1:
        {
            tableViewCell.textLabel.text = self.chat.topic;
        }
            break;
        case 2:
        {
            tableViewCell.textLabel.text = self.chatSession.descriptionString.length ? self.chatSession.descriptionString : NSLocalizedString(@"Description", @"Description");
        }
            break;
        default:
            break;
    }
    return tableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return kBriefCellHeight;
    }
    else
    {
        return kNormalCellHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @WEAKSELF;
    switch (indexPath.row) {
        case 0:
        {
            //Edit Cover
            UIAlertController *imageActionAlertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", @"Camera") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                weakSelf.imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
                [weakSelf presentViewController:weakSelf.imagePicker animated:YES completion:nil];
            }];
            UIAlertAction *ablumPhoto = [UIAlertAction actionWithTitle:NSLocalizedString(@"Album", @"Album") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                weakSelf.imagePicker.sourceType =  UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                [weakSelf presentViewController:weakSelf.imagePicker animated:YES completion:nil];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
            [imageActionAlertController addAction:takePhoto];
            [imageActionAlertController addAction:ablumPhoto];
            [imageActionAlertController addAction:cancel];
            [self presentViewController:imageActionAlertController animated:YES completion:nil];
        }
            break;
        case 1:
        {
            //Edit Topic
            MCChatBriefEditTopicViewController *topicEditVc = [[MCChatBriefEditTopicViewController alloc] initWithChatItem:self.chat completeHandler:^(NSString *newTopic) {
                UITableViewCell *topicCell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                topicCell.textLabel.text = newTopic;
                                                    
                if (_delegateFlag.updateTopicFlag)
                {
                    [_updateDelegate briefSettingViewController:weakSelf didUpdatedChatTopic:newTopic];
                }
            }];
            [self.navigationController pushViewController:topicEditVc animated:YES];
        }
            break;
        case 2:
        {
            //Edit Description
            MCChatBriefEditDescViewController *descEditVc = [[MCChatBriefEditDescViewController alloc] initWithChatItem:self.chat completeHandler:^(NSString *newDesc) {
                UITableViewCell *descCell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                descCell.textLabel.text = newDesc;
                
                if (_delegateFlag.updateTopicFlag)
                {
                    [_updateDelegate briefSettingViewController:weakSelf didUpdatedChatDescription:newDesc];
                }
            }];
            [self.navigationController pushViewController:descEditVc animated:YES];
        }
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    @WEAKSELF;
    //Update Cover
    NSLog(@"%@",info);
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    [self.view.window mc_startIndicatorViewAnimating];
    //Aftet the image wrote to disk then upload it.
    [[MCMessageCenterInstance sharedInstance] writeToDiskWithImage:editedImage completeHandler:^(NSString *imagePath, NSError *error) {
        if (error)
        {
            [weakSelf.view.window mc_stopIndicatorViewAnimating];
            [weakSelf  mc_simpleAlertError:error];
        }
        if (imagePath)
        {
            [weakSelf.chat updateCoverWithImagePath:imagePath withCompletionHandler:^(NSError * _Nullable errorOrNil) {
                [weakSelf.view.window mc_stopIndicatorViewAnimating];
                if (errorOrNil)
                {
                    [weakSelf mc_simpleAlertError:errorOrNil];
                }
                else
                {
                    [weakSelf.view.window mc_showMessage:NSLocalizedString(@"Upload Success", @"Upload Success")];
                    
                    //Refresh cell
                    MCChatSettingBriefCell *briefCell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    briefCell.chatCoverImageView.image = editedImage;
                    
                    if (_delegateFlag.updateCoverFlag)
                    {
                        [_updateDelegate briefSettingViewController:weakSelf didUpdatedChatCoverWithImage:editedImage];
                    }
                    [[MCMessageCenterInstance sharedInstance] clearDiskUploadImage];
                }
            }];
        }
    }];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
