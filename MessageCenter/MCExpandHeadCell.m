//
//  MCTodoChatHeadCell.m
//  MessageCenter
//
//  Created by Rookie on 16/12/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import "MCExpandHeadCell.h"
#import <Masonry.h>

@interface MCExpandHeadCell ()

@property (nonatomic, strong) UILabel *topicLabel;
@property (nonatomic, strong) UILabel *openCountLabel;
@property (nonatomic, strong) UIImageView *expandIndicator;
@property (nonatomic, strong) UIView *splitLineView;

@end

@implementation MCExpandHeadCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = MCColorBackground;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.topicLabel = [UILabel new];
        self.topicLabel.font = [UIFont systemFontOfSize:15];
        self.topicLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.topicLabel];
        
        self.openCountLabel = [UILabel new];
        self.openCountLabel.font = [UIFont boldSystemFontOfSize:13];
        self.openCountLabel.textColor = MCColorFontBlack;
        self.openCountLabel.backgroundColor = [UIColor whiteColor];
        self.openCountLabel.layer.cornerRadius = 10;
        self.openCountLabel.clipsToBounds = YES;
        self.openCountLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.openCountLabel];

        UIImage *expandImage = [[UIImage imageNamed:@"expand_arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.expandIndicator = [[UIImageView alloc] initWithImage:expandImage];
        self.expandIndicator.tintColor = [UIColor blackColor];
        [self.contentView addSubview:self.expandIndicator];
        
        self.splitLineView = [UIView new];
        self.splitLineView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.splitLineView];
        
        [self.topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(8);
            make.bottom.mas_equalTo(-10);
            make.left.mas_equalTo(15);
        }];
        
        [self.openCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.equalTo(self.expandIndicator.mas_left).offset(-10);
            make.width.mas_equalTo(30);
            make.height.mas_equalTo(20);
        }];
        
        [self.expandIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.mas_equalTo(-15);
        }];
        
        [self.splitLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView);
            make.height.equalTo(@2.0f);
        }];
        
        [self setExpanded:NO animated:NO];
    }
    
    return self;
}

#pragma mark - Public Method

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.topicLabel.text = title;
}

- (void)setBadgeNumber:(NSUInteger )badgeNumber
{
    _badgeNumber = badgeNumber;
    if (badgeNumber > 0)
    {
        self.openCountLabel.hidden = NO;
        self.openCountLabel.text = badgeNumber > 99 ? @"99+" : @(badgeNumber).description;
    }
    else
    {
        self.openCountLabel.hidden = YES;
    }
}

- (void)setExpanded:(BOOL)expanded animated:(BOOL)animated {
    NSTimeInterval duration = animated ? 0.25 : 0;
    [UIView animateWithDuration:duration animations:^{
        self.expandIndicator.transform = expanded ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(M_PI);
    }];
    
    self.splitLineView.hidden = expanded;
}



@end
