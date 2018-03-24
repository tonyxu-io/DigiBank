//
//  MCMeetListCell.m
//  DigiBank
//
//  Created by Moxtra on 2017/3/27.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCMeetListCell.h"
#import "NSDate+MCExtension.h"

#pragma mark - MCMeetCellRecordView

@interface MCMeetCellRecordView()

@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, copy) void(^handlePlayButtonTapped)(UIButton *sender);

@end

@implementation MCMeetCellRecordView

- (instancetype)initWithPlayButtonTapped:(void(^)(UIButton *sender))handler;
{
    if (self = [super init])
    {
        self.handlePlayButtonTapped = handler;
        [self setupRecordView];
    }
    return self;
}

- (void)setupRecordView
{
    //Left Describe Label
    UILabel *describelabel = [[UILabel alloc] init];
    [self addSubview:describelabel];
    [describelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.centerY.equalTo(self);
    }];
    NSTextAttachment *describeAttachment = [[NSTextAttachment alloc] init];
    describeAttachment.image = [UIImage imageNamed:@"meetlist_recording_indicator"];
    describeAttachment.bounds = CGRectMake(0, 0, 14, 8);
    NSAttributedString *attributedDescribe = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"  Recording available ", nil)
                                                                             attributes:@{NSFontAttributeName:MXLightFont(12.0f),
                                                                                          NSForegroundColorAttributeName:MXBlackColor}];
    NSMutableAttributedString *describeAttachString = [[NSMutableAttributedString attributedStringWithAttachment:describeAttachment] mutableCopy];
    [describeAttachString appendAttributedString:attributedDescribe];
    describelabel.attributedText = describeAttachString;
    
    //Right Play Label
    UILabel *playLabel = [[UILabel alloc] init];
    playLabel.font = MXLightFont(12.0f);
    playLabel.textColor = MXBrandingColor;
    playLabel.text = NSLocalizedString(@"Recording available ", nil);
    [self addSubview:playLabel];
    [playLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.right.centerY.equalTo(self);
    }];
    
    NSTextAttachment *playAttachment = [[NSTextAttachment alloc] init];
    playAttachment.image = [[UIImage imageNamed:@"meetlist_record_play"] mc_renderImageWithColor:MXBrandingColor];
    playAttachment.bounds = CGRectMake(0, 0, 8, 8);
    NSAttributedString *attributedPlayStr = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"  PLAY", nil)
                                                                            attributes:@{NSFontAttributeName:MXLightFont(12.f),
                                                                                         NSForegroundColorAttributeName:MXBrandingColor}];
    NSMutableAttributedString *playAttachString = [[NSMutableAttributedString attributedStringWithAttachment:playAttachment] mutableCopy];
    [playAttachString appendAttributedString:attributedPlayStr];
    playLabel.attributedText = playAttachString;
    
    //PlayButton
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playButton.backgroundColor = [UIColor clearColor];
    [self.playButton addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playButton];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(playLabel);
    }];
}

- (void)playButtonTapped:(UIButton *)sender
{
    if (self.handlePlayButtonTapped)
    {
        self.handlePlayButtonTapped(sender);
    }
}

@end

#pragma mark - MCMeetListCell

@interface MCMeetListCell()

//Info
@property (nonatomic, strong) UILabel *topicLabel;
@property (nonatomic, strong) UILabel *hosterLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIView *seperator;

//Avatars
@property (nonatomic, strong) UIImageView *firstAvatarImageView;
@property (nonatomic, strong) UIImageView *secondAvatarImageView;
@property (nonatomic, strong) UIImageView *thirdAvatarImageView;
@property (nonatomic, strong) NSArray <UIImageView *> *avatarImageArray;
@property (nonatomic, strong) UILabel *membersNumberLabel;

//Buttons
@property (nonatomic, strong) UIButton *joinButton;
@property (nonatomic, strong) MCMeetCellRecordView *recordView;

@end

static CGFloat const kImageSize = 25.f;

@implementation MCMeetListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self setupUserInterface];
        [self setupRightUtilityButtons];
    }
    return self;
}

#pragma mark - User Interface

- (void)setupUserInterface
{
    //Set time label
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = MXLightFont(12.f);
    self.timeLabel.textColor = MXBlackColor;
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    [self.timeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.timeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(15.f);
        make.left.offset(15.f);
        make.width.mas_equalTo(60.f);
    }];
    
    self.durationLabel = [[UILabel alloc] init];
    self.durationLabel.font = MXLightFont(12.f);
    self.durationLabel.textColor = MXBlackColor;
    self.durationLabel.numberOfLines = 2;
    self.durationLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.durationLabel];
    [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timeLabel.mas_bottom).with.offset(5.f);
        make.left.equalTo(self.timeLabel);
        make.width.mas_equalTo(60.f);
    }];
    
    self.seperator = [UIView new];
    self.seperator.backgroundColor = MXBrandingColor;
    [self.contentView addSubview:self.seperator];
    [self.seperator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(10.f);
        make.left.equalTo(self.timeLabel.mas_right).with.offset(10.f);
        make.bottom.offset(-10.f);
        make.width.mas_equalTo(3.f);
    }];
    
    self.topicLabel = [[UILabel alloc] init];
    self.topicLabel.font = MXRegularFont(15.f);
    self.topicLabel.textColor = MXBlackColor;
    self.topicLabel.numberOfLines = 2;
    [self.contentView addSubview:self.topicLabel];
    [self.topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(15.f);
        make.left.equalTo(self.seperator.mas_right).with.offset(10.f);
        make.right.equalTo(self.contentView).offset(-85.f);
    }];
    
    self.hosterLabel = [[UILabel alloc] init];
    self.hosterLabel.font = MXLightFont(12.f);
    self.hosterLabel.textColor = MXGrayColor;
    self.hosterLabel.numberOfLines = 1;
    [self.contentView addSubview:self.hosterLabel];
    [self.hosterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topicLabel.mas_bottom).offset(5.f);
        make.left.right.equalTo(self.topicLabel);
    }];
    
    self.joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.joinButton.layer.cornerRadius = 3.f;
    self.joinButton.layer.masksToBounds = YES;
    self.joinButton.backgroundColor = MXBrandingColor;
    self.joinButton.tintColor = MXMeetColor;
    [self.joinButton setContentEdgeInsets:UIEdgeInsetsMake(5.f, 12.f, 5.f, 12.f)];
    [self.joinButton setTitleColor:MXBrandingForegroundColor forState:UIControlStateNormal];
    [self.joinButton setTitleColor:MXBrandingForegroundColor forState:UIControlStateNormal];
    self.joinButton.titleLabel.font = MXRegularFont(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 15 : 12);
    [self.joinButton addTarget:self action:@selector(joinButtonBeTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.joinButton];
    [self.joinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-15.f);
        make.height.mas_equalTo(30.f);
        make.width.mas_equalTo(68.f);
    }];
    
    [self setupAvatarImageView];
}

- (void)setupAvatarImageView
{
    self.firstAvatarImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.firstAvatarImageView];
    [self.firstAvatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.hosterLabel);
        make.top.equalTo(self.hosterLabel.mas_bottom).offset(10.f);
        make.width.height.mas_equalTo(kImageSize);
    }];
    
    self.secondAvatarImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.secondAvatarImageView];
    [self.secondAvatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.firstAvatarImageView.mas_right).with.offset(-10.f);
        make.top.width.height.equalTo(self.firstAvatarImageView);
    }];
    
    self.thirdAvatarImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.thirdAvatarImageView];
    [self.thirdAvatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.secondAvatarImageView.mas_right).with.offset(-10.0f);
        make.top.width.height.equalTo(self.firstAvatarImageView);
    }];
    self.avatarImageArray = @[self.firstAvatarImageView,self.secondAvatarImageView,self.thirdAvatarImageView];
    
    self.membersNumberLabel = [UILabel new];
    [self.contentView addSubview:self.membersNumberLabel];
    self.membersNumberLabel.font = MXLightFont(12.0f);
    self.membersNumberLabel.textColor = MXGrayColor;
    self.membersNumberLabel.numberOfLines = 1;
    [self.membersNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.thirdAvatarImageView.mas_right).offset(10.0f);
        make.centerY.equalTo(self.thirdAvatarImageView).offset(0.0f);
        make.width.equalTo(@100.0f);
    }];
    
    //Set record play view
    self.recordView = [[MCMeetCellRecordView alloc] initWithPlayButtonTapped:self.handlePlayButtonTapped];
    [self.contentView addSubview:self.recordView];
    [self.recordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.firstAvatarImageView);
        make.top.equalTo(self.firstAvatarImageView.mas_bottom).offset(15.0f);
        make.right.equalTo(self.contentView).offset(-10.0f);
        make.height.equalTo(@24.0f);
    }];
    
    
    
    [self resetToDefaultConfig];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self resetToDefaultConfig];
}

- (void)resetToDefaultConfig
{
    //Reset some info view to hide
    self.recordView.hidden = YES;
    self.joinButton.hidden = YES;
    self.membersNumberLabel.hidden = YES;
    for (UIImageView *avatarImageView in self.avatarImageArray) {
        avatarImageView.hidden = YES;
        avatarImageView.image = nil;
    }
    //Rest cell "tintcolor" to gray 
    self.seperator.backgroundColor = MXGrayColor;
    self.timeLabel.textColor = MXGrayColor;
    self.durationLabel.textColor = MXGrayColor;
    self.topicLabel.textColor = MXGrayColor;
    
    //TestInfo
    self.timeLabel.text = @"14:41";
    self.durationLabel.text = @"1 hr 2 mins";
    self.topicLabel.text = @"Jacob's Meet";
    self.hosterLabel.text = @"Hosted by Jacob";
}

- (void)setupRightUtilityButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    UIImage *image = [[UIImage imageNamed:@"meetlist_cell_delete"] mc_renderImageWithColor:MXWhiteColor];
    [rightUtilityButtons sw_addUtilityButtonWithColor:MXRedColor icon:image];
    [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:70.0f];
}

#pragma mark - Public Setter
- (void)setMeetItem:(MXMeet *)meetItem
{
    _meetItem = meetItem;
    //Set Meet topic
    if(_meetItem.topic.length == 0)
        self.topicLabel.text =[NSString stringWithFormat:NSLocalizedString(@"%@'s Meet", @"%@'s Meet"), self.meetItem.host.firstname];
    else
        self.topicLabel.text = self.meetItem.topic;
    
    //Set avatar
    @WEAKSELF;
    [_meetItem.users enumerateObjectsUsingBlock:^(MXUserItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < 3)
        {
            [[MCMessageCenterInstance sharedInstance] getRoundedAvatarWithUser:obj completionHandler:^(UIImage *avatar, NSError *error) {
                [weakSelf.avatarImageArray[idx] setImage:avatar];
                weakSelf.avatarImageArray[idx].hidden = NO;
            }];
        }
        else
        {
            self.membersNumberLabel.hidden = NO;
            self.membersNumberLabel.text = [NSString stringWithFormat:@"+%zd",self.meetItem.users.count - 3];
        }
    }];
    
    //Set host label
    [self.hosterLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topicLabel.mas_bottom).offset(5.0f);
        make.left.equalTo(self.topicLabel).offset(0.0f);
        make.right.equalTo(self.topicLabel).offset(0.0f);
        make.height.mas_equalTo(18.f);
    }];
    self.hosterLabel.hidden = _meetItem.isUCMeet;
    self.hosterLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Hosted by %@", @"Hosted by %@"), _meetItem.host.firstname];
    
    //Set record play view
    if (_meetItem.recordingUrl)
    {
        self.recordView.hidden = NO;
    }
    
    //Change color depend on date
    BOOL isFurtureMeet = [self.meetItem.scheduledEndTime compare:[NSDate date]] == NSOrderedDescending;
    if (self.meetItem.isInProgress || isFurtureMeet)
    {
        self.timeLabel.textColor = MXBlackColor;
        self.topicLabel.textColor = MXBlackColor;
        self.durationLabel.textColor = MXBlackColor;
        self.seperator.backgroundColor = MXBrandingColor;
    }
    
    //Calculate time
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *startMeetDate = self.meetItem.startTime ? self.meetItem.startTime : self.meetItem.scheduledStartTime;
    self.timeLabel.text = [startMeetDate mc_timeOfHourAndMinuteOnCalendar:calendar];
    if(self.meetItem.endTime != nil && self.meetItem.startTime != nil)
    {
        if (isFurtureMeet)
        {
            NSDate *endDate = self.meetItem.scheduledEndTime;
            self.durationLabel.text = [NSString stringWithFormat:@"-%@", [endDate mc_timeOfHourAndMinuteOnCalendar:calendar]];
        }
        else
        {
            NSTimeInterval meetDuration = [self.meetItem.endTime timeIntervalSinceDate:self.meetItem.startTime];
            self.durationLabel.text = [NSString stringWithFormat:@"%@", [NSDate mc_formatTimeLengthString:(meetDuration)]];
        }
    }
    else
    {
        
        NSDate *endDate = self.meetItem.scheduledEndTime;
        if (endDate != nil)
        {
            self.durationLabel.text = [NSString stringWithFormat:@"-%@", [endDate mc_timeOfHourAndMinuteOnCalendar:calendar]];
        }
        else
        {
            self.durationLabel.text = @"";
        }
    }
    
    //Join|Start meet
    NSInteger duration = [self.meetItem.scheduledStartTime timeIntervalSinceDate:[NSDate date]];
    BOOL canJoinBeforeHost = duration < 1800 && isFurtureMeet && self.meetItem.isInProgress == NO && self.meetItem.isAccepted == YES;
    BOOL isOwner = NO;
    
    for (id userItem in self.meetItem.users) {
        
        if ([userItem isKindOfClass:[MXUserItem class]]) {
            if ([userItem isMyself] && [userItem isEqual:self.meetItem.host]) {
                isOwner = YES;
            }
        }
    }
    if(self.meetItem.isInProgress == YES || (isOwner == NO && canJoinBeforeHost))
    {
        self.joinButton.hidden = NO;
        [self.joinButton setTitle:( self.isJoin ? NSLocalizedString(@"Return", @"Return") : NSLocalizedString(@"Join", @"Join") ) forState:UIControlStateNormal];
        self.joinButton.tag = 22;
    }
    else if(isOwner == YES && self.meetItem.isInProgress == NO && isFurtureMeet)
    {
        self.joinButton.hidden = NO;
        [self.joinButton setTitle:NSLocalizedString(@"Start", @"Start") forState:UIControlStateNormal];
        self.joinButton.tag = 11;
    }
    else if(self.meetItem.isAccepted == NO && isFurtureMeet )
    {
        self.joinButton.hidden = YES;
    }
}

- (void)setHandlePlayButtonTapped:(void (^)(UIButton *))handlePlayButtonTapped
{
    _handlePlayButtonTapped = handlePlayButtonTapped;
    self.recordView.handlePlayButtonTapped = handlePlayButtonTapped;
}

#pragma mark - Widgets Action
- (void)joinButtonBeTapped:(UIButton *)sender
{
    switch (sender.tag)
    {
        case 11:
            //Start
        {
            if (self.handleStartOrJoinMeet)
            {
                self.handleStartOrJoinMeet(YES,nil);
            }
        }
            break;
        case 22:
            //Join
        {
            if (self.handleStartOrJoinMeet)
            {
                self.handleStartOrJoinMeet(NO,nil);
            }
        }
            break;
        default:
            break;
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
