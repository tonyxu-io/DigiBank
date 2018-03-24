//
//  MCChatListCell.m
//  MessageCenter
//
//  Created by Rookie on 30/11/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import "MCChatListCell.h"

@interface MCChatListCell ()

@property (nonatomic, strong) UILabel *topicLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *badgeImgView;
@property (nonatomic, strong) UILabel *lastFeedLabel;
@property (nonatomic, strong) UIImageView *avatarImgView;

@property (nonatomic, assign) CGFloat badgeHeight;

@end

static const CGFloat kBadgePadding = 3;

@implementation MCChatListCell

#pragma mark - LifeCycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor whiteColor];
        [self setupUserInterface];
    }
    return self;
}

#pragma mark - UserInterface

- (void)setupUserInterface
{
    self.layoutMargins = UIEdgeInsetsZero;
    self.separatorInset = UIEdgeInsetsZero;
    self.preservesSuperviewLayoutMargins = NO;
    
    self.topicLabel = [UILabel new];
    self.topicLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
    self.topicLabel.numberOfLines = 1;
    self.topicLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:self.topicLabel];
    
    self.timeLabel = [UILabel new];
    self.timeLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightThin];
    self.timeLabel.textColor = [UIColor lightGrayColor];
    [self.timeLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:self.timeLabel];
    
    self.badgeImgView = [UIImageView new];
    [self.contentView addSubview:self.badgeImgView];
    
    UIFont *feedFont = [UIFont systemFontOfSize:14];
    self.lastFeedLabel = [UILabel new];
    self.lastFeedLabel.font = [UIFont systemFontOfSize:14];
    self.lastFeedLabel.numberOfLines = 2;
    [self.contentView addSubview:self.lastFeedLabel];
    
    self.avatarImgView = [[UIImageView alloc] init];
    self.avatarImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.avatarImgView];
    
    [self.topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(10);
        make.right.equalTo(self.timeLabel.mas_left).offset(-10);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.topicLabel);
        make.right.mas_equalTo(-10);
    }];
    [self.badgeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timeLabel.mas_bottom).offset(10);
        make.right.equalTo(self.timeLabel);
    }];
    [self.avatarImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(25);
        make.left.mas_equalTo(15);
        make.top.equalTo(self.topicLabel.mas_bottom).with.offset(10);
    }];
    [self.lastFeedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topicLabel.mas_bottom);
        make.left.equalTo(self.avatarImgView.mas_right).offset(10);
        make.right.equalTo(self.topicLabel);
        make.centerY.equalTo(self.avatarImgView);
        make.height.mas_equalTo(feedFont.lineHeight * 2);
        make.bottom.mas_lessThanOrEqualTo(-5);
    }];
    
    CGSize textSize = [@"88" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}
                                          context:nil].size;
    self.badgeHeight = MAX(textSize.height, textSize.width) + 2 * kBadgePadding;
}

#pragma mark - Public Setter

- (void)setChat:(MXChat *)chat
{
    _chat = chat;
    
    __weak typeof (self) weakSelf = self;

    self.topicLabel.text = chat.topic;
    
    //Config last feed time
    NSDate *now = [NSDate date];
    NSDate *lastFeedDate = chat.lastFeedTime;
    
    if ([now mc_isSameDay:lastFeedDate])
    {
        self.timeLabel.text = [NSDate mc_getLocalizedShortDateString:lastFeedDate];
    }
    else if ([now mc_isSameWeek:lastFeedDate])
    {
        static NSDateFormatter *dateFormatter = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateFormat:@"EEEE"];
        });
        self.timeLabel.text = [dateFormatter stringFromDate:lastFeedDate];
    }
    else
    {
        self.timeLabel.text = [NSDate mc_getLocalizedShortDateString:lastFeedDate];
    }
    
    self.lastFeedLabel.text = chat.lastFeedContent;
    
    //Config badge
    if (chat.unreadFeedsCount)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *badgeImage = [UIImage mc_badgeImageWithNumber:chat.unreadFeedsCount];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.badgeImgView.image = badgeImage;
                weakSelf.badgeImgView.hidden = NO;
            });
        });
    }
    else
    {
        self.badgeImgView.hidden = YES;
    }
    
    //Default avatar
    CGFloat length = 25;
    static UIImage *defaultAvatar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(length, length), NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextAddRect(context, CGRectMake(0, 0, length, length));
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
        CGContextFillPath(context);
        CGContextAddEllipseInRect(context, CGRectMake(0, 0, length, length));
        CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
        CGContextFillPath(context);
        defaultAvatar = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    self.avatarImgView.image = defaultAvatar;
    
    [[MCMessageCenterInstance sharedInstance] getRoundedAvatarWithUser:chat.lastFeedUser completionHandler:^(UIImage *avatar, NSError *error) {        
        if (avatar)
        {
            self.avatarImgView.image = avatar;
        }
    }];
}

@end
