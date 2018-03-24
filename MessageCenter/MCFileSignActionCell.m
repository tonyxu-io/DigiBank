//
//  MCFileSignActionCell.m
//  DigiBank
//
//  Created by Moxtra on 2017/3/31.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCFileSignActionCell.h"

@interface MCFileSignActionCell()

@property (nonatomic, strong) UIButton *declineButton;
@property (nonatomic, strong) UIButton *signButton;

@end

static CGFloat const kSignButtonInsetsRight = 16.f;
static CGFloat const kSignButtonHeight = 30.f;
static CGFloat const kSignButtonWidth = 140.f;

@implementation MCFileSignActionCell

#pragma mark - LifeCycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupUserInterface];
    }
    return self;
}

#pragma mark - User Interface

- (void)setupUserInterface
{
    self.signButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.signButton setBackgroundImage:[UIImage mc_imageWithColor:MXBlueColor andSize:CGSizeMake(self.bounds.size.height, self.bounds.size.height)] forState:UIControlStateNormal];
    self.signButton.titleLabel.font = [UIFont systemFontOfSize:15];
    self.signButton.layer.cornerRadius = 3.f;
    self.signButton.layer.masksToBounds = YES;
    [self.signButton setTitle:@"Sign" forState:UIControlStateNormal];
    [self.contentView addSubview:self.signButton];
    [self.signButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-kSignButtonInsetsRight);
        make.height.mas_equalTo(kSignButtonHeight);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(kSignButtonWidth);
    }];
    
    self.declineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.declineButton setBackgroundImage:[UIImage mc_imageWithColor:MXRedColor andSize:CGSizeMake(self.bounds.size.height, self.bounds.size.height)] forState:UIControlStateNormal];
    self.declineButton.titleLabel.font = [UIFont systemFontOfSize:15];
    self.declineButton.layer.cornerRadius = 3.f;
    self.declineButton.layer.masksToBounds = YES;
    [self.declineButton setTitle:@"Decline" forState:UIControlStateNormal];
    [self.contentView addSubview:self.declineButton];
    [self.declineButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.signButton.mas_left).with.offset(-kSignButtonInsetsRight);
        make.height.mas_equalTo(kSignButtonHeight);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(kSignButtonWidth);
    }];
    
    [self.signButton addTarget:self action:@selector(signButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.declineButton addTarget:self action:@selector(declineButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - WidgetsActions

- (void)signButtonTapped:(UIButton *)sender
{
    if (self.signButtonTapped)
    {
        self.signButtonTapped();
    }
}

- (void)declineButtonTapped:(UIButton *)sender
{
    if (self.declineButtonTapped)
    {
        self.declineButtonTapped();
    }
}

@end
