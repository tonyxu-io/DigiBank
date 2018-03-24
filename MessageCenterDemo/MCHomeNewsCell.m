//
//  MCHomeNewsCell.m
//  MessageCenter
//
//  Created by wubright on 2016/12/15.
//  Copyright © 2016年 moxtra. All rights reserved.
//

#import "MCHomeNewsCell.h"
#import <Masonry.h>

@implementation MCHomeNewsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.layoutMargins = UIEdgeInsetsZero;
        self.separatorInset = UIEdgeInsetsZero;
        self.preservesSuperviewLayoutMargins = NO;
        
        self.topicLabel = [UILabel new];
        self.topicLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:self.topicLabel];
        
        self.detailLabel = [UILabel new];
        self.detailLabel.font = [UIFont systemFontOfSize:14];
        self.detailLabel.textColor = [UIColor grayColor];
        self.detailLabel.numberOfLines = 5;
        [self.contentView addSubview:self.detailLabel];
        
        [self.topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(8.0f);
            make.left.equalTo(self.contentView).offset(12.0f);
            make.right.equalTo(self.contentView).offset(-12.0f);
        }];
        
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topicLabel.mas_bottom).offset(4.0f);
            make.left.equalTo(self.topicLabel);
            make.right.equalTo(self.topicLabel);
            make.bottom.equalTo(self.contentView).offset(-6.0f);
        }];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
