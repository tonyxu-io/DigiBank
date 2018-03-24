//
//  MCMeetListHeadView.m
//  DigiBank
//
//  Created by Moxtra on 2017/3/27.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCMeetListHeadView.h"

@interface MCMeetListHeadView()

@property (nonatomic, copy) void(^centerButtonHandler)(UIButton *sender);

@property (nonatomic, copy) NSString *buttonTitle;

@end

@implementation MCMeetListHeadView

- (instancetype)initWithTitle:(NSString *)title
                 buttonTapped:(void (^)(UIButton *))handler
{
    if (self = [super init])
    {
        self.centerButtonHandler = handler;
        self.backgroundColor = [UIColor whiteColor];
        self.buttonTitle = title;
        [self setupUserInterface];
    }
    return self;
}

- (void)setupUserInterface
{
    UIButton *centerButton = [UIButton buttonWithType:UIButtonTypeSystem];
    centerButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    centerButton.layer.masksToBounds = YES;
    centerButton.layer.cornerRadius = 3.0f;
    [centerButton.layer setBorderWidth:1.0f];
    [centerButton.layer setBorderColor:MXBrandingColor.CGColor];
    [centerButton setTitleColor:MXBrandingColor forState:UIControlStateNormal];
    [centerButton setTitle:NSLocalizedString(self.buttonTitle, @"button") forState:UIControlStateNormal];
    [self addSubview:centerButton];
    [centerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
        make.width.equalTo(@220.0f);
        make.height.equalTo(@30.0f);
    }];
    [centerButton addTarget:self action:@selector(centerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *separatorH = [UIView new];
    separatorH.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:separatorH];
    [separatorH mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
}

#pragma mark - Widgets Action

- (void)centerButtonTapped:(UIButton *)sender
{
    if (self.centerButtonHandler)
    {
        self.centerButtonHandler(sender);
    }
}

@end
