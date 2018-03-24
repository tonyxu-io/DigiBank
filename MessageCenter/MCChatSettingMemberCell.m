//
//  MCChatSettingMemberCell.m
//  DigiBank
//
//  Created by Moxtra on 2017/4/14.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCChatSettingMemberCell.h"

@interface MCChatSettingMemberCell()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *roleLabel;

@end

static CGFloat const kNameLabelInsetsLeft = 5.f;
static CGFloat const kImageViewSize = 30.f;

@implementation MCChatSettingMemberCell

#pragma mark - LifeCycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier])
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.imageView.frame = CGRectMake(10, 5, kImageViewSize, kImageViewSize);
        [self setupUserInterface];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.imageView.frame = CGRectMake(10, 5, kImageViewSize, kImageViewSize);
}

#pragma mark - UserInterface

- (void)setupUserInterface
{
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = [UIImage mc_imageWithColor:[UIColor whiteColor] andSize:CGSizeMake(kImageViewSize, kImageViewSize)];
    
    @WEAKSELF;
    self.nameLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.nameLabel];
    self.nameLabel.font = [UIFont systemFontOfSize:15];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imageView.mas_right).with.offset(kNameLabelInsetsLeft);
        make.top.equalTo(weakSelf.imageView.mas_top);
        make.height.mas_equalTo(17.f);
        make.width.equalTo(self.contentView);
    }];
    
    self.roleLabel = [[UILabel alloc] init];
    self.roleLabel.textColor = MXGray40Color;
    self.roleLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:self.roleLabel];
    [self.roleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.height.equalTo(weakSelf.nameLabel);
        make.top.equalTo(weakSelf.nameLabel.mas_bottom);
        make.width.equalTo(self.contentView);
    }];
}

#pragma mark - PublicSetter

- (void)setUserItem:(MXUserItem *)userItem
{
    _userItem = userItem;
    [self updateContent];
}

- (void)setAccessType:(MXChatMemberAccessType)accessType
{
    _accessType = accessType;
    [self updateContent];
}

- (void)updateContent
{
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",_userItem.firstname,_userItem.lastname];
    if (_userItem.isMyself)
    {
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@ (Me)",_userItem.firstname, _userItem.lastname];
    }
    NSString *accessText;
    switch (self.accessType) {
        case MXChatMemberAccessTypeEditor:
            accessText = NSLocalizedString(@"Editor", @"Editor");
            break;
        case MXChatMemberAccessTypeOwner:
            accessText = NSLocalizedString(@"Owner", @"Owner");
            break;
        case MXChatMemberAccessTypeViewer:
            accessText = NSLocalizedString(@"Viewer", @"Viewer");
            break;
        default:
            accessText = @"";
            break;
    }
    self.roleLabel.text = _userItem.title;
    self.detailTextLabel.text = accessText;
}

#pragma mark - PrivateMethod

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(10, 5, 30, 30);
}

@end
