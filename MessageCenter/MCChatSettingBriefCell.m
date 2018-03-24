//
//  MCChatSettingBriefCell.m
//  DigiBank
//
//  Created by Moxtra on 2017/4/14.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCChatSettingBriefCell.h"

@interface MCChatSettingBriefCell ()

@property (nonatomic, strong) UILabel *editCoverLabel;

@end

static CGFloat const kCoverImageInsets = 16.f;
static CGFloat const kCoverImageSize = 60.f;
static CGFloat const kTopicInsetsLeft = 10.f;
static CGFloat const kTopicInsetsRight = 40.f;
static CGFloat const kDescribeInsetsTop = 5.f;

@implementation MCChatSettingBriefCell 

#pragma mark - LifeCycle

- (instancetype)initWithType:(MCChatSettingBriefCellType)type reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _type = type;
        [self setupUserInterface];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [self initWithType:MCChatSettingBriefCellTypeDisplay reuseIdentifier:reuseIdentifier];
}

#pragma mark - UserInterface

- (void)setupUserInterface
{
    self.chatCoverImageView = [UIImageView new];
    self.chatCoverImageView.layer.cornerRadius = 3.0f;
    self.chatCoverImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.chatCoverImageView];
    [self.chatCoverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(kCoverImageInsets);
        make.top.equalTo(self.contentView).offset(kCoverImageInsets);
        make.width.height.mas_equalTo(kCoverImageSize);
    }];
    
    self.topicLabel = [UILabel new];
    self.topicLabel.font =  [UIFont systemFontOfSize:20];
    self.topicLabel.textColor = [UIColor blackColor];
    self.topicLabel.textAlignment = NSTextAlignmentLeft;
    self.topicLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.topicLabel.numberOfLines = 2;
    [self.contentView addSubview:self.topicLabel];
    [self.topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.chatCoverImageView.mas_right).offset(kTopicInsetsLeft);
        make.right.equalTo(self).offset(-kTopicInsetsRight);
        make.top.equalTo(self.chatCoverImageView.mas_top);
        make.height.greaterThanOrEqualTo(@0.0f).priorityHigh();
    }];
    
    self.descriptionLabel = [UILabel new];
    self.descriptionLabel.textColor = MXGray40Color;
    self.descriptionLabel.font = [UIFont systemFontOfSize:12];
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:self.descriptionLabel];
    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topicLabel);
        make.top.equalTo(self.topicLabel.mas_bottom).offset(kDescribeInsetsTop);
        make.right.equalTo(self.topicLabel.mas_right);
    }];
    
    self.editCoverLabel = [[UILabel alloc] init];
    self.editCoverLabel.font = [UIFont systemFontOfSize:14];
    self.editCoverLabel.textColor = MXBlueColor;
    self.editCoverLabel.text = NSLocalizedString(@"Edit Cover Image", @"Edit Cover Image");
    [self.contentView addSubview:self.editCoverLabel];
    [self.editCoverLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.chatCoverImageView.mas_right).with.offset(kCoverImageInsets);
        make.height.mas_equalTo(kCoverImageInsets);
        make.right.equalTo(self).offset(-kTopicInsetsRight);
    }];
    
    self.type = _type;
}

#pragma mark - PublicSetter

- (void)setType:(MCChatSettingBriefCellType)type
{
    _type = type;
    if (_type == MCChatSettingBriefCellTypeDisplay)
    {
        self.editCoverLabel.hidden = YES;
        self.descriptionLabel.hidden = NO;
        self.topicLabel.hidden = NO;
    }
    else
    {
        self.editCoverLabel.hidden = NO;
        self.descriptionLabel.hidden = YES;
        self.topicLabel.hidden = YES;
    }
}

- (void)setChat:(MXChat *)chat
{
    _chat = chat;
    [self updateContent];
}

- (void)updateContent
{
    //Set accessory type
    if (self.chat.owner.isMyself)
    {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
    @WEAKSELF;
    //Topic content
    self.topicLabel.text = _chat.topic;
    
    //Describe content
    NSDate *feedDate = _chat.lastFeedTime;
    NSDateFormatter *fullDateFormatter = [[NSDateFormatter alloc] init];
    [fullDateFormatter setDateStyle:NSDateFormatterLongStyle];
    [fullDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSString * description;
    MXChatSession *chatSession = [[MXChatSession alloc] initWithChat:_chat];
    if (chatSession.descriptionString.length)
    {
        description = chatSession.descriptionString;
    }
    else
    {
        description = [NSString stringWithFormat:NSLocalizedString(@"Created by %@ %@ on %@.", @""),_chat.owner.firstname, _chat.owner.lastname, [fullDateFormatter stringFromDate:feedDate]];
    }
    self.descriptionLabel.text = description;
    
    //Cover content
    [[MCMessageCenterInstance sharedInstance] getChatCoverWithChatItem:_chat completionHandler:^(UIImage *image, NSError *error) {
        if (image)
        {
            weakSelf.chatCoverImageView.image = image;
        }
    }];
}

@end
