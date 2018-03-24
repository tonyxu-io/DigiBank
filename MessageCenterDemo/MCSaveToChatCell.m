//
//  MCSaveToChatCell.m
//  MessageCenter
//
//  Created by wubright on 2016/12/15.
//  Copyright © 2016年 moxtra. All rights reserved.
//

#import "MCSaveToChatCell.h"

#import <Masonry.h>

@implementation MCSaveToChatCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.layoutMargins = UIEdgeInsetsZero;
        self.separatorInset = UIEdgeInsetsZero;
        self.preservesSuperviewLayoutMargins = NO;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.selectImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uncheck_button"]];
        [self.contentView addSubview:self.selectImageView];
        [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-12.0f);
            make.centerY.equalTo(self.contentView);
        }];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
