//
//  MCExpandCompleteCell.m
//  DigiBank
//
//  Created by Moxtra on 2017/3/31.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCExpandCompleteCell.h"

@interface MCExpandCompleteCell()

@property (nonatomic, strong) UILabel *accessoryLabel;
@property (nonatomic, strong) UIView *seperatorTop;
@property (nonatomic, strong) UIView *seperatorBottom;

@end

static CGFloat const kAccessoryLabelInsetsRight = 20.f;
static CGFloat const kAccessoryLabelHeight = 16.f;
@implementation MCExpandCompleteCell

#pragma mark - Life Cycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self setupUserInterface];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - User Interface

- (void)setupUserInterface
{
    self.textLabel.textColor = MCColorMain;
    self.textLabel.font = [UIFont systemFontOfSize:12];
    self.separatorInset = UIEdgeInsetsMake(0, 12, 0, 12);
    
    self.accessoryLabel = [[UILabel alloc] init];
    self.accessoryLabel.font = [UIFont boldSystemFontOfSize:14];
    self.accessoryLabel.textAlignment = NSTextAlignmentLeft;
    self.accessoryLabel.textColor = MCColorMain;
    self.accessoryLabel.text = @"-";
    [self.contentView addSubview:self.accessoryLabel];
    [self.accessoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.textLabel);
        make.right.equalTo(self.contentView).with.offset(- kAccessoryLabelInsetsRight);
        make.height.mas_equalTo(kAccessoryLabelHeight);
    }];
    
    self.seperatorTop = [[UIView alloc] init];
    self.seperatorTop.backgroundColor = MXGray08Color;
    CGFloat scale = [UIScreen mainScreen].scale;
    [self.contentView addSubview:self.seperatorTop];
    [self.seperatorTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1/scale);
        make.top.equalTo(self.contentView);
        make.left.equalTo(self.contentView).with.offset(kAccessoryLabelHeight);
        make.right.equalTo(self.contentView).with.offset(-kAccessoryLabelHeight);
    }];
    
    self.seperatorBottom = [[UIView alloc] init];
    self.seperatorBottom.backgroundColor = MXGray08Color;
    [self.contentView addSubview:self.seperatorBottom];
    [self.seperatorBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1/scale);
        make.bottom.equalTo(self.contentView);
        make.left.equalTo(self.contentView).with.offset(kAccessoryLabelHeight);
        make.right.equalTo(self.contentView).with.offset(-kAccessoryLabelHeight);
    }];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.textLabel.text = title;
}

- (void)setExpand:(BOOL)expand
{
    _expand = expand;
    self.accessoryLabel.text = expand ? @"-" : @"+";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
