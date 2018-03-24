//
//  MCHomeInvestmentCell.m
//  MessageCenter
//
//  Created by wubright on 2016/12/15.
//  Copyright © 2016年 moxtra. All rights reserved.
//

#import "MCHomeInvestmentCell.h"
#import <Masonry.h>

@implementation MCHomeInvestmentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.layoutMargins = UIEdgeInsetsZero;
        self.separatorInset = UIEdgeInsetsZero;
        self.preservesSuperviewLayoutMargins = NO;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        self.nameLabel = [UILabel new];
        self.nameLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:self.nameLabel];
        
        self.accountLabel = [UILabel new];
        self.accountLabel.font = [UIFont systemFontOfSize:14];
        self.accountLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.accountLabel];
        
        self.priceLabel = [UILabel new];
        self.priceLabel.font = [UIFont systemFontOfSize:14];
        self.priceLabel.textColor = MCColorMain;
        [self.contentView addSubview:self.priceLabel];
        
        self.rateLabel = [UILabel new];
        self.rateLabel.font = [UIFont systemFontOfSize:14];
        self.rateLabel.textColor = [UIColor colorWithRed:249.0/255.0f green:166.0/255.0f blue:35.0/255.0f alpha:1.0f];;
        [self.contentView addSubview:self.rateLabel];
        
        [self.nameLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self.nameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(25.0f);
            make.left.equalTo(self.contentView).offset(12.0f);
            make.right.equalTo(self.priceLabel.mas_left).offset(-6.0f);
        }];
        
        [self.accountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(8.0f);
            make.left.equalTo(self.nameLabel);
            make.right.equalTo(self.nameLabel);
            make.bottom.equalTo(self.contentView).offset(-25.0f);
        }];
        
        [self.priceLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.priceLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(0.0);
            make.bottom.equalTo(self.contentView.mas_centerY).offset(-2.0f);
        }];
        
        [self.rateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.priceLabel).offset(0.0);
            make.top.equalTo(self.contentView.mas_centerY).offset(2.0f);
        }];
        
    }
    
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
