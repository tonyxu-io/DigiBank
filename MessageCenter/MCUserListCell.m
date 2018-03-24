//
//  MCUserListCell.m
//  DigiBank
//
//  Created by Moxtra on 2017/3/13.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCUserListCell.h"

#import <Masonry.h>
#import "MCCheckBox.h"

@interface MCUserListCell()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *lblName;
@property (nonatomic, strong) UIButton *btnCall;
@property (nonatomic, strong) UIImageView *imgOnline;
@property (nonatomic, assign) MCUserListCellType type;
@property (nonatomic, strong) MCCheckBox *checkBox;

@property (nonatomic, copy) void(^handleWidgetOnTapped)(MCUserListCell *cell, id sender);

@end

static CGFloat const kAvatarHeight = 45.f;
static CGFloat const kBtnInsetsHor = 15.f;
static CGFloat const kBtnInsetsVer = 5.f;
static CGFloat const kCheckBoxSize = 20.f;

@implementation MCUserListCell

- (instancetype)initWithReuseIdentifier:(NSString *)identifier
                               cellType:(MCUserListCellType)type
                           widgetAction:(void (^)(MCUserListCell *, id))action
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier])
    {
        _handleWidgetOnTapped = action;
        self.type = type;
        self.separatorInset = UIEdgeInsetsMake(0, kAvatarHeight + kBtnInsetsHor, 0, 0);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    //Layout
    self.avatarView = [[UIImageView alloc] init];
    self.avatarView.layer.cornerRadius = kAvatarHeight/2.0f;
    self.avatarView.layer.masksToBounds = YES;
    self.avatarView.image = [UIImage mc_imageWithColor:[UIColor whiteColor] andSize:CGSizeMake(kAvatarHeight, kAvatarHeight)];
    [self.contentView addSubview:self.avatarView];
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kBtnInsetsHor);
        make.centerY.equalTo(self.contentView);
        make.height.width.mas_equalTo(kAvatarHeight);
    }];
    
    UIView *layoutTargetView;
    if (self.type == MCUserListCellTypeCall)
    {
        self.btnCall = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *callImage = [UIImage imageNamed:@"ChatSDKResource.bundle/contact_cell_call"];
        [self.btnCall setImage:callImage forState:UIControlStateNormal];
        [self.contentView addSubview:self.btnCall];
        //Add target
        [self.btnCall addTarget:self action:@selector(handleBtnCallOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnCall mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).with.offset(0.0f);
            make.top.equalTo(self.contentView.mas_top).with.offset(kBtnInsetsVer);
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-kBtnInsetsVer);
            make.width.mas_equalTo(kAvatarHeight);
        }];
        layoutTargetView = self.btnCall;
    }
    else
    {
        self.checkBox = [[MCCheckBox alloc] initWithFrame:CGRectMake(0, 0, kCheckBoxSize, kCheckBoxSize)];
        self.checkBox.fillColor = MXBrandingColor;
        self.checkBox.borderColor = MXGray08Color;
        self.checkBox.circleBorderWidth = 1.f;
        [self.contentView addSubview:self.checkBox];
        [self.checkBox addTarget:self action:@selector(handleCheckBoxSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self.checkBox mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).with.offset(0.0f);
            make.centerY.equalTo(self.contentView);
            make.height.width.mas_equalTo(kCheckBoxSize);
        }];
        layoutTargetView = self.checkBox;
    }

    self.lblName = [[UILabel alloc] init];
    [self.contentView addSubview:self.lblName];
    [self.lblName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarView.mas_right).with.offset(kBtnInsetsHor);
        make.right.equalTo(layoutTargetView.mas_left).with.offset(-kBtnInsetsHor);
        make.centerY.equalTo(self.contentView);
        make.height.mas_equalTo(kAvatarHeight);
    }];

//    //Set Online View
//    self.imgOnline = [[UIImageView alloc] init];
//    self.imgOnline.backgroundColor = [UIColor greenColor];
//    [self.avatarView addSubview:self.imgOnline];
//    [self.imgOnline mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.height.mas_equalTo(kBtnInsetsHor);
//        make.right.bottom.equalTo(self.avatarView);
//    }];
//
//    [self.btnChat addTarget:self action:@selector(handleBtnChatOnClick:) forControlEvents:UIControlEventTouchUpInside];

}

#pragma mark - Getter

- (UIControl *)control
{
    if (self.type == MCUserListCellTypeCall)
    {
        return self.btnCall;
    }
    else
    {
        return self.checkBox;
    }
}

#pragma mark - Setter

- (void)setUser:(MXUserItem *)user
{
    _user = user;
    self.lblName.text = [NSString stringWithFormat:@"%@ %@",user.firstname,user.lastname];
    __weak typeof(self) weakSelf = self;
    //Get avatar
    [user fetchAvatarWithCompletionHandler:^(NSError * _Nullable errorOrNil, NSString * _Nullable localPathOrNil) {
        weakSelf.avatarView.image = [UIImage imageWithContentsOfFile:localPathOrNil];
    }];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Widgets Actions

- (void)handleBtnCallOnClick:(UIButton *)sender
{
    @WEAKSELF;
    if (self.handleWidgetOnTapped)
    {
        self.handleWidgetOnTapped(weakSelf,sender);
    }
}

- (void)handleCheckBoxSelected:(MCCheckBox *)sender
{
    @WEAKSELF;
    sender.selected = !sender.selected;
    if (self.handleWidgetOnTapped) {
        self.handleWidgetOnTapped(weakSelf,sender);
    }
}

@end
