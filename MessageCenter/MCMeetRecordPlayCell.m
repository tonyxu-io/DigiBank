//
//  MCMeetRecordPlayCell.m
//  DigiBank
//
//  Created by Moxtra on 2017/4/20.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCMeetRecordPlayCell.h"

@interface MCMeetRecordPlayCell()

@property (nonatomic, strong) UILabel *topicLabel;

@end

@implementation MCMeetRecordPlayCell

#pragma mark - LifeCycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self setupUserInterface];
    }
    return self;
}

- (void)setupUserInterface
{
    UIImageView *recordIndicator = [[UIImageView alloc] initWithFrame:CGRectZero];
    recordIndicator.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:recordIndicator];
    [recordIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15.0f);
        make.centerY.equalTo(self.contentView);
        make.width.equalTo(@24.0f);
        make.height.equalTo(@24.0f);
    }];
    recordIndicator.image  = [[UIImage imageNamed:@"meetlist_recording_indicator"] mc_renderImageWithColor:MXGray40Color];
    
    UILabel *recordTipLabel = [UILabel new];
    [self.contentView addSubview:recordTipLabel];
    recordTipLabel.font = [UIFont systemFontOfSize:15];
    recordTipLabel.textColor = MXGray60Color;
    [recordTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(recordIndicator.mas_right).offset(10.0f);
        make.bottom.equalTo(self.contentView.mas_centerY);
        make.width.equalTo(@150.0f);
    }];
    recordTipLabel.text = NSLocalizedString(@"Recording available", nil);
    
    self.topicLabel = [UILabel new];
    [self.contentView addSubview:self.topicLabel];
    self.topicLabel.text = self.fileName;
    self.topicLabel.font = [UIFont systemFontOfSize:12];
    self.topicLabel.textColor = MXGray40Color;
    self.topicLabel.numberOfLines = 1;
    [self.topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(recordIndicator.mas_right).offset(10.0f);
        make.top.equalTo(self.contentView.mas_centerY);
        make.width.equalTo(@200.0f);
    }];
    
    UIImageView *playIndicator = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"meetlist_record_play"] mc_renderImageWithColor:MXBrandingColor]];
    playIndicator.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:playIndicator];
    [playIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-65.f);
        make.centerY.equalTo(self.contentView);
        make.height.equalTo(@24.0f);
        make.width.equalTo(@24.0f);
    }];
    
    UILabel *playTipLabel = [UILabel new];
    [self.contentView addSubview:playTipLabel];
    playTipLabel.font = [UIFont systemFontOfSize:12];
    playTipLabel.textColor = MXBrandingColor;
    [playTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(playIndicator.mas_right);
        make.height.mas_equalTo(12);
    }];
    playTipLabel.text = NSLocalizedString(@"PLAY", nil);
}

- (void)setFileName:(NSString *)fileName
{
    _fileName = fileName;
    self.topicLabel.text = fileName;
}

@end
