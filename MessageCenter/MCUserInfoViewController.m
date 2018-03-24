//
//  MCUserInfoViewController.m
//  DigiBank
//
//  Created by Moxtra on 2017/4/7.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCUserInfoViewController.h"

#import "MCMessageCenterViewController.h"
#import "MCExpandTableView.h"

#pragma mark - MCUserInfoHeadView

typedef NS_ENUM(NSUInteger,MCUserInfoActionType ){
    MCUserInfoActionTypeChat = 0,
    MCUserInfoActionTypeCall,
    MCUserInfoActionTypeMeet,
};

@interface MCUserInfoHeadView : UIView

@property (nonatomic, strong) UIImageView* avatarImageView;
@property (nonatomic, strong) UILabel* displayNameLabel;
@property (nonatomic, strong) UILabel* titleAndStatusLabel;

@property (nonatomic, strong) UIButton* startCallButton;
@property (nonatomic, strong) UILabel* startCallLabel;

@property (nonatomic, strong) UIButton* startChatButton;
@property (nonatomic, strong) UILabel* startChatLabel;

@property (nonatomic, strong) UIButton* startMeetButton;
@property (nonatomic, strong) UILabel* startMeetLabel;

@property (nonatomic, copy) void(^handleWidgetTapped)(MCUserInfoActionType action);

@end

@implementation MCUserInfoHeadView

- (instancetype)initWithUserItem:(MXUserItem *)user widgetTapped:(void(^)(MCUserInfoActionType action))handler
{
    if (self = [super init])
    {
        self.handleWidgetTapped = handler;
        [self setupUserInterfaceWithUser:user];
    }
    return self;
}

- (void)setupUserInterfaceWithUser:(MXUserItem *)user;
{
    self.backgroundColor = [UIColor whiteColor];
    
    self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 90.0f, 90.0f)];
    [self addSubview:self.avatarImageView];
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(20.0f);
        make.centerX.equalTo(self);
        make.width.equalTo(@(86.0f));
        make.height.equalTo(@(86.0f));
    }];
    
    self.displayNameLabel = [UILabel new];
    self.displayNameLabel.font = [UIFont systemFontOfSize:28.0f];
    self.displayNameLabel.textColor = [UIColor blackColor];
    self.displayNameLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.displayNameLabel];
    [self.displayNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10.0f);
        make.right.offset(-10.0f);
        make.top.equalTo(self.avatarImageView.mas_bottom).offset(10.0f);
    }];
    
    self.titleAndStatusLabel = [UILabel new];
    self.titleAndStatusLabel.font = [UIFont systemFontOfSize:12.0f];
    self.titleAndStatusLabel.textColor = MXGray40Color;
    [self addSubview:self.titleAndStatusLabel];
    [self.titleAndStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.displayNameLabel.mas_bottom).offset(5.0f);
        make.centerX.equalTo(self.displayNameLabel);
    }];
    
    self.startChatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.startChatButton];
    self.startChatButton.tag = 0;
    [self.startChatButton setBackgroundImage:[[UIImage imageNamed:@"tel_circle_solid"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];

    self.startChatButton.tintColor = MXBrandingColor;
    [self.startChatButton setImage:[UIImage imageNamed:@"tel_chat"] forState:UIControlStateNormal];
    [self.startChatButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.startChatLabel = [UILabel new];
    self.startChatLabel.font = [UIFont systemFontOfSize:11.0f];
    self.startChatLabel.textColor = MXBrandingColor;
    self.startChatLabel.text = NSLocalizedString(@"Chat", @"");
    [self addSubview:self.startChatLabel];
    
    self.startCallButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.startCallButton];
    self.startCallButton.tag = 1;
    [self.startCallButton setBackgroundImage:[[UIImage imageNamed:@"tel_circle_solid"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.startCallButton.tintColor = MXBrandingColor;
    [self.startCallButton setImage:[UIImage imageNamed:@"tel_call_solid_small"] forState:UIControlStateNormal];
    [self.startCallButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.startCallLabel = [UILabel new];
    self.startCallLabel.font = [UIFont systemFontOfSize:11.f];
    self.startCallLabel.textColor = MXBrandingColor;
    self.startCallLabel.text = NSLocalizedString(@"Call", @"");
    [self addSubview:self.startCallLabel];
    
    self.startMeetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.startMeetButton];
    self.startMeetButton.tag = 2;
    [self.startMeetButton setBackgroundImage:[[UIImage imageNamed:@"tel_circle_solid"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];


    self.startMeetButton.tintColor = MXMeetColor;
    [self.startMeetButton setImage:[UIImage imageNamed:@"tel_meet_button"] forState:UIControlStateNormal];
    [self.startMeetButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.startMeetLabel = [UILabel new];
    self.startMeetLabel.font = [UIFont systemFontOfSize:11.f];
    self.startMeetLabel.textColor = MXMeetColor;
    self.startMeetLabel.text = NSLocalizedString(@"Meeting", @"");
    [self addSubview:self.startMeetLabel];
    
    [self.startCallButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleAndStatusLabel.mas_bottom).offset(15.0f);
        make.centerX.equalTo(self);
        make.height.equalTo(@40.0f);
        make.width.equalTo(@40.0f);
    }];
    
    [self.startCallLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.startCallButton.mas_bottom).offset(4.0f);
        make.centerX.equalTo(self.startCallButton);
    }];
    
    [self.startChatButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleAndStatusLabel.mas_bottom).offset(15.0f);
        make.right.equalTo(self.startCallButton.mas_left).offset(-30.0f);
        make.height.equalTo(@40.0f);
        make.width.equalTo(@40.0f);
    }];
    
    [self.startChatLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.startChatButton.mas_bottom).offset(4.0f);
        make.centerX.equalTo(self.startChatButton);
    }];
    
    [self.startMeetButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleAndStatusLabel.mas_bottom).offset(15.0f);
        make.left.equalTo(self.startCallButton.mas_right).offset(30.0f);
        make.height.equalTo(@40.0f);
        make.width.equalTo(@40.0f);
    }];
    
    [self.startMeetLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.startMeetButton.mas_bottom).offset(4.0f);
        make.centerX.equalTo(self.startMeetButton);
    }];
    
    UIView *separateLineView = [UIView new];
    separateLineView.backgroundColor = MXGray20Color;
    [self addSubview:separateLineView];
    [separateLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_bottom);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@(0.5f));
    }];
    
    [self updateContentWithUser:user];
}

- (void)updateContentWithUser:(MXUserItem *)user;
{
    @WEAKSELF;
    [[MCMessageCenterInstance sharedInstance] getRoundedAvatarWithUser:user completionHandler:^(UIImage *avatar, NSError *error) {
        weakSelf.avatarImageView.image = avatar;
    }];
    self.displayNameLabel.text = [NSString stringWithFormat:@"%@ %@",user.firstname,user.lastname];
    self.titleAndStatusLabel.text = user.email;
}

- (void)buttonTapped:(UIButton *)sender
{
    if (self.handleWidgetTapped)
    {
        self.handleWidgetTapped(sender.tag);
    }
}

@end

@interface MCUserInfoChatCell : UITableViewCell

@end

@implementation MCUserInfoChatCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.imageView.frame = CGRectMake(15, (self.bounds.size.height - 30 )/2.f, 30, 30);
        self.imageView.image = [UIImage mc_imageWithColor:[UIColor whiteColor] andSize:CGSizeMake(30, 30)];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(15, (self.bounds.size.height - 30 )/2.f, 30, 30);
    self.textLabel.frame = CGRectMake(70, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
}

@end

#pragma mark - MCUserInfoViewController

@interface MCUserInfoViewController ()<MCExpandTableViewDelegate>

@property (nonatomic, strong) MCUserInfoHeadView *headView;
@property (nonatomic, strong) MCExpandTableView *tableView;

@property (nonatomic, strong) MXUserItem *user;
@property (nonatomic, strong) MXUserListModel *userListModel;
@property (nonatomic, weak) MXChatListModel *chatListModel;
@property (nonatomic, weak) MXMeetListModel *meetListModel;

@property (nonatomic, strong) NSArray<MXChat *> *sharedChats;
@property (nonatomic, strong) NSMutableArray<MCExpandModel *> *expandModels;
@end

static NSUInteger const kChatsShowNumber = 5.f;
static NSString *const kChatsCellReuseIdentifier = @"kChatsCellReuseIdentifier";
static NSString *const kViewMoreCellReuseIdentifier = @"kViewMoreCellReuseIdentifier";

@implementation MCUserInfoViewController

#pragma mark - LifeCycle

- (instancetype)initWithUserItem:(MXUserItem *)user userListModel:(MXUserListModel *)userListModel
{
    if (self = [self init])
    {
        self.user = user;
        self.userListModel = userListModel;
    }
    return self;
}

- (MXChatListModel *)chatListModel
{
    return [MCMessageCenterInstance sharedInstance].chatListModel;
}

- (MXMeetListModel *)meetListModel
{
    return [MCMessageCenterInstance sharedInstance].meetListModel;
}

- (MXUserListModel *)userListModel
{
    if (_userListModel == nil)
    {
        _userListModel = [[MXUserListModel alloc] init];
    }
    return _userListModel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"User Profile", @"User Profile");
    [self setupUserInterface];
    [self loadChats];
}

- (NSMutableArray<MCExpandModel *> *)expandModels
{
    if (_expandModels == nil)
    {
        _expandModels = [[NSMutableArray alloc] init];
    }
    return _expandModels;
}

#pragma mark - UserInterface

- (void)setupUserInterface
{
    @WEAKSELF;
    //Set up head view
    self.headView = [[MCUserInfoHeadView alloc] initWithUserItem:self.user widgetTapped:^(MCUserInfoActionType action) {
        switch (action)
        {
            case MCUserInfoActionTypeChat:
            {
                [self.chatListModel startIndividualChatWithUniqueId:self.user.uniqueId orgId:self.user.orgId completionHandler:^(NSError * _Nullable error, MXChat * _Nullable chat) {
                    [[MCMessageCenterViewController sharedInstance] openChatItem:chat withFeedObject:nil];
                }];
            }
                break;
            case MCUserInfoActionTypeCall:
            {
                [self mc_simpleAlertWithTitle:@"Tip" message:@"Call feature is not supported now"];
            }
                break;
            case MCUserInfoActionTypeMeet:
            {
                //Handle when call button on clicked
                [self.meetListModel startMeetWithTopic:NSLocalizedString(@"your meeting topic", @"Meeting topic") completionHandler:^(NSError * _Nullable error, MXMeetSession *_Nullable meetSession) {
                    [weakSelf.view.window mc_stopIndicatorViewAnimating];
                    if (error)
                    {
                        [weakSelf mc_simpleAlertError:error];
                    }
                    if (meetSession != nil)
                    {
                        [meetSession inviteUsers:@[self.user] withCompletionHandler:^(NSError * _Nullable error) {
                            if (error)
                            {
                                [weakSelf mc_simpleAlertError:error];
                            }
                        }];
                        [meetSession presentMeetWindow];
                    }
                }];
            }
                break;
            default:
                break;
        }
    }];
    [self.view addSubview:self.headView];
    [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.height.mas_equalTo(256.f);
    }];
    
    self.tableView = [[MCExpandTableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    //    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = MXGray08Color;
    self.tableView.showsVerticalScrollIndicator = NO;
    if([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    self.tableView.expandDelegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.headView.mas_bottom);
        make.bottom.equalTo(self.view);
    }];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kViewMoreCellReuseIdentifier];
}

- (void)loadChats
{
    self.sharedChats = [self.userListModel sharedChatsWithUser:self.user];
    self.sharedChats = [self.sharedChats sortedArrayUsingComparator:^NSComparisonResult(MXChat *obj1, MXChat *obj2) {
        return [obj2.lastFeedTime compare:obj1.lastFeedTime];
    }];
    
    //Declare a button model
    MCExpandModel *buttonModel = [MCExpandModel expandModelWithObject:@(NO) identifier:@"buttonModel"];
    buttonModel.expand = NO;
    @WEAKSELF;
    [self.sharedChats enumerateObjectsUsingBlock:^(MXChat * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MCExpandModel *chatExpandModel = [MCExpandModel expandModelWithObject:obj identifier:obj.topic];
        chatExpandModel.interactionEnabled = NO;
        if (idx < kChatsShowNumber)
        {
            //Max of chats in display is 5.
            [weakSelf.expandModels addObject:chatExpandModel];
        }
        else if (idx == kChatsShowNumber)
        {
            [weakSelf.expandModels addObject:buttonModel];
            [buttonModel addSubModel:chatExpandModel];
        }
        else
        {
            [buttonModel addSubModel:chatExpandModel];
        }
    }];
    
    self.tableView.expandModels = [self.expandModels copy];
    [self.tableView reloadData];
}

#pragma mark - MCExpandTableDelegate

- (UITableViewCell *)mcExpandTableView:(MCExpandTableView *)tableView cellForModel:(MCExpandModel *)model
{
    UITableViewCell *chatCell = [tableView dequeueReusableCellWithIdentifier:kChatsCellReuseIdentifier];
    UITableViewCell *viewMoreCell = [tableView dequeueReusableCellWithIdentifier:kViewMoreCellReuseIdentifier];
    if (chatCell == nil)
    {
        chatCell = [[MCUserInfoChatCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kChatsCellReuseIdentifier];
        chatCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    @WEAK_OBJ(chatCell);
    if ([model.object isKindOfClass:[MXChat class]])
    {
        MXChat *chat = (MXChat *)model.object;
        if (chat.isIndividualChat)
        {
            [[MCMessageCenterInstance sharedInstance] getRoundedAvatarWithUser:self.user completionHandler:^(UIImage *avatar, NSError *error) {
                chatCellWeak.imageView.image = avatar;
            }];
        }
        else
        {
            [[MCMessageCenterInstance sharedInstance] getChatCoverWithChatItem:chat completionHandler:^(UIImage *image, NSError *error) {
                chatCellWeak.imageView.image = image;
            }];
        }
        chatCell.textLabel.text = [model.object topic];
        return chatCell;
    }
    else
    {
        NSAttributedString *attributeTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"View all binders", @"View all binders") attributes:@{NSForegroundColorAttributeName:MXBrandingColor, NSFontAttributeName:[UIFont systemFontOfSize:18]}];
        [viewMoreCell.textLabel setAttributedText:attributeTitle];
        viewMoreCell.textLabel.textAlignment = NSTextAlignmentCenter;
        return viewMoreCell;
    }
}

- (void)mcExpandTableView:(MCExpandTableView *)tableView didSelectedIndexPath:(NSIndexPath *)indexPath expandModel:(MCExpandModel *)model
{
    if ([model.object isKindOfClass:[MXChat class]])
    {
        [[MCMessageCenterViewController sharedInstance] openChatItem:model.object withFeedObject:nil];
    }
    else
    {
        [self.expandModels addObjectsFromArray:model.subModel];
        [self.expandModels removeObject:model];
        self.tableView.expandModels = [self.expandModels copy];
        [self.tableView reloadData];
    }
}

- (NSString *)mcExpandTableView:(MCExpandTableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return NSLocalizedString(@"SHARED CHATS", @"SHARED CHATS");
    }
    else
    {
        return nil;
    }
}

#pragma mark - Helper

- (void)resizeImage:(UIImage *)image inSize:(CGSize)size handler:(void(^)(UIImage *result))handler;
{
    CGSize itemSize = size;
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [image drawInRect:imageRect];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    dispatch_async(dispatch_get_main_queue(), ^{
        handler(result);
    });
}

@end
