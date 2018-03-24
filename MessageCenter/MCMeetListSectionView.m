//
//  MCMeetListSectionView.m
//  DigiBank
//
//  Created by Moxtra on 2017/3/27.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCMeetListSectionView.h"
@interface MCMeetListSectionView()

@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, strong) UILabel *meetInfoLabel;

@end

@implementation MCMeetListSectionView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier])
    {
        self.isToday = NO;
        self.hasMeeting = YES;
        self.contentView.backgroundColor = MXWhiteColor;
        [self setupUserInterface];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.sectionDate = nil;
    _isToday = NO;
    _hasMeeting = YES;
}

- (void)setupUserInterface
{
    //Setup Labels
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.textColor = MXGrayColor;
    self.dateLabel.textAlignment = NSTextAlignmentLeft;
    self.dateLabel.font = MXRegularFont(12.0f);
    self.dateLabel.numberOfLines = 1;
    [self.contentView addSubview:self.dateLabel];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self).offset(5.0f);
        make.left.equalTo(self).offset(15.0f);
    }];
    
    self.meetInfoLabel = [[UILabel alloc] init];
    self.meetInfoLabel.textColor = MXGrayColor;
    self.meetInfoLabel.textAlignment = NSTextAlignmentLeft;
    self.meetInfoLabel.font = MXRegularFont(12.0f);
    self.meetInfoLabel.numberOfLines = 1;
    [self.contentView addSubview:self.meetInfoLabel];
    [self.meetInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self).offset(5.0f);
        make.right.equalTo(self).offset(-15.0f);
    }];
}

#pragma mark - Public Setter

- (void)setSectionDate:(NSDate *)sectionDate
{
    _sectionDate = sectionDate;
    
    NSDate *currentDate = self.sectionDate;
    NSDateFormatter *dayAndMonthFormatter = [[NSDateFormatter alloc] init];
    [dayAndMonthFormatter setDateFormat:@"EEEE MMM, dd"];
    NSString *dayAndMonthString = [dayAndMonthFormatter stringFromDate:currentDate];
    NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
    [yearFormatter setDateFormat:@"yyyy"];
    NSString *yearString = [yearFormatter stringFromDate:currentDate];
    
    if (self.isToday)
    {
        self.dateLabel.textColor = MXBrandingColor;
        self.meetInfoLabel.textColor = MXBrandingColor;
        //Change dateLabel's content
        NSDateFormatter *dayAndMonthFormatter = [[NSDateFormatter alloc] init];
        [dayAndMonthFormatter setDateFormat:@"MMM, dd"];
        NSString *dayAndMonthString = [dayAndMonthFormatter stringFromDate:self.sectionDate];
        self.dateLabel.text = [NSString stringWithFormat:@"Today %@th %@",dayAndMonthString,yearString];
    }
    else
    {
        self.dateLabel.text = [NSString stringWithFormat:@"%@th %@",dayAndMonthString,yearString];
        self.dateLabel.textColor = MXGrayColor;
        self.meetInfoLabel.textColor = MXGrayColor;
    }
    //Show "No meetings" if today has no meeting
    if (self.hasMeeting)
    {
        self.meetInfoLabel.text = NSLocalizedString(@"", @"");
    }
    else
    {
        self.meetInfoLabel.text = NSLocalizedString(@"No meetings", @"No meetings");
    }
    
}
- (void)setIsToday:(BOOL)isToday
{
    _isToday = isToday;
    
    //Refresh content
    if (self.sectionDate)
    {
        [self setSectionDate:self.sectionDate];
    }
}

- (void)setHasMeeting:(BOOL)hasMeeting
{
    _hasMeeting = hasMeeting;
    
    //Refresh content
    if (self.sectionDate)
    {
        [self setSectionDate:self.sectionDate];
    }
}
@end
