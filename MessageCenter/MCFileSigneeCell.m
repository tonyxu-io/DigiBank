//
//  MCFileSigneeCell.m
//  DigiBank
//
//  Created by Moxtra on 2017/3/31.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCFileSigneeCell.h"

@interface MCFileSigneeCell()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *signStateLabel;
@property (nonatomic, strong) UIImageView *indicatorImageView;

@end

static CGFloat const kAvatarInsetsTop = 12.f;
static CGFloat const kAvatatInsetsLeft = 60.f;
static CGFloat const kAvatatSize = 28.f;

static CGFloat const kUserNameLabelHeight = 18.f;
static CGFloat const kUserNameLabelMargin = 10.f;
static CGFloat const kSignStateLabelMagrgin = 8.f;

static CGFloat const kIndicatorSize = 24.f;

@implementation MCFileSigneeCell

#pragma mark - LifeCycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self setupUserInterface];
    }
    return self;
}

#pragma mark - User Interface

- (void)setupUserInterface
{
    self.avatarImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.avatarImageView];
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).with.offset(kAvatarInsetsTop);
        make.height.width.mas_equalTo(kAvatatSize);
        make.left.equalTo(self.contentView).with.offset(kAvatatInsetsLeft);
    }];
    
    self.userNameLabel = [[UILabel alloc] init];
    self.userNameLabel.font = [UIFont systemFontOfSize:15];
    self.userNameLabel.textColor = MXGray60Color;
    [self.contentView addSubview:self.userNameLabel];
    [self.userNameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.avatarImageView);
        make.height.mas_equalTo(kUserNameLabelHeight);
        make.left.equalTo(self.avatarImageView.mas_right).with.offset(kUserNameLabelMargin);
    }];
    
    self.indicatorImageView = [[UIImageView alloc] init];
    self.indicatorImageView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:self.indicatorImageView];
    [self.indicatorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.avatarImageView);
        make.height.width.mas_equalTo(kIndicatorSize);
        make.right.equalTo(self.contentView.mas_right).with.offset(- kAvatarInsetsTop);
    }];
    self.indicatorImageView.hidden = YES;
    
    self.signStateLabel = [[UILabel alloc] init];
    self.signStateLabel.font = [UIFont systemFontOfSize:10];
    [self.contentView addSubview:self.signStateLabel];
    [self.signStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.indicatorImageView);
        make.height.mas_equalTo(self.indicatorImageView);
        make.right.equalTo(self.indicatorImageView.mas_left).with.offset( - kSignStateLabelMagrgin);
        make.left.greaterThanOrEqualTo(self.userNameLabel.mas_right);
    }];
}

#pragma mark - Public Setter

- (void)setFileSigner:(MXUserItem *)fileSigner
{
    @WEAKSELF;
    _fileSigner = fileSigner;
    self.userNameLabel.text = [NSString stringWithFormat:@"%@ %@",fileSigner.firstname, fileSigner.lastname];
    
    //Get avatar
    [[MCMessageCenterInstance sharedInstance] getRoundedAvatarWithUser:fileSigner completionHandler:^(UIImage *avatar, NSError *error) {
        weakSelf.avatarImageView.image = avatar;
    }];
}

- (void)setSignState:(MXFileSigneeState )signState
{
    _signState = signState;
    
    //Config textColor
    self.signStateLabel.textColor = MXGray20Color;
    self.indicatorImageView.hidden = YES;
    
    switch (signState)
    {
        case MXFileSigneeStateSigning:
        {
            if (_fileSigner.isMyself)
            {
                self.signStateLabel.textColor = MXGray40Color;
                self.indicatorImageView.tintColor = MXGray40Color;
                self.indicatorImageView.image = [[UIImage imageNamed:@"file_uturn"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                self.indicatorImageView.hidden = NO;
                self.signStateLabel.text = NSLocalizedString(@"YOU TURN", @"YOU TURN");
            }
            else
            {
                self.signStateLabel.text = NSLocalizedString(@"SIGNING", @"SIGNING");
            }
        }
            break;
        case MXFileSigneeStatePending:
        {
            self.signStateLabel.text = NSLocalizedString(@"WAITING TO SIGN", @"WAITING TO SIGN");
        }
            break;
        case MXFileSigneeStateSigned:
            self.signStateLabel.text = NSLocalizedString(@"SIGNED", @"SIGNED");
            break;
        case MXFileSigneeStateCanceled:
            self.signStateLabel.text = NSLocalizedString(@"CANCELED", @"CANCELED");
            self.signStateLabel.textColor = MXGray08Color;
            break;
        case MXFileSigneeStateDeclined:
            self.signStateLabel.text = NSLocalizedString(@"DECLINED", @"DECLINED");
            break;
        default:
            break;
    }
}

@end
