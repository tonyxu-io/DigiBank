//
//  MCHomeAccountCell.m
//  MessageCenter
//
//  Created by wubright on 2016/12/15.
//  Copyright © 2016年 moxtra. All rights reserved.
//

#import "MCHomeAccountCell.h"

#import <Masonry.h>

@implementation MCHomeAccountCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.layoutMargins = UIEdgeInsetsZero;
        self.separatorInset = UIEdgeInsetsZero;
        self.preservesSuperviewLayoutMargins = NO;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        self.indicatorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"visa_logo"]];
        [self.contentView addSubview:self.indicatorView];
        [self.indicatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
  
        self.cardTypeLabel = [UILabel new];
        self.cardTypeLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:self.cardTypeLabel];
        
        self.cardAccountLabel = [UILabel new];
        self.cardAccountLabel.font = [UIFont systemFontOfSize:14];
        self.cardAccountLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.cardAccountLabel];
        
        self.cardAmountLabel = [UILabel new];
        self.cardAmountLabel.font = [UIFont systemFontOfSize:14];
        self.cardAmountLabel.textColor = MCColorMain;
        [self.contentView addSubview:self.cardAmountLabel];
        
        [self.indicatorView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.indicatorView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(12.0f);
        }];
        
        [self.cardTypeLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self.cardTypeLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self.cardTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(25.0f);
            make.left.equalTo(self.indicatorView.mas_right).offset(20.0f);
            make.right.equalTo(self.cardAmountLabel.mas_left).offset(-6.0f);
        }];
        
        [self.cardAccountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.cardTypeLabel.mas_bottom).offset(8.0f);
            make.left.equalTo(self.cardTypeLabel);
            make.right.equalTo(self.cardTypeLabel);
            make.bottom.equalTo(self.contentView).offset(-25.0f);
        }];
        
        [self.cardAmountLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.cardAmountLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.cardAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(0.0);
            make.centerY.equalTo(self.contentView);
            
        }];
        
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
