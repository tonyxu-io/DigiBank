//
//  MCMeetRingCallViewController.m
//  MessageCenter
//
//  Created by jacob on 12/28/16.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import "MCMeetRingCallViewController.h"
#import "MXUserItem+MCHelper.h"
#import <Masonry.h>

@interface MCMeetRingCallViewController ()

@property(nonatomic, readwrite, strong) MXMeet *meetItem;
@property(nonatomic, readwrite, strong) UIView *panelView;
@property(nonatomic, readwrite, strong) UIImageView *avatarImageView;
@property(nonatomic, readwrite, strong) UILabel     *callerLabel;
@property(nonatomic, readwrite, strong) UILabel     *callStatusLabel;
@property(nonatomic, readwrite, strong) UIButton    *declineButton;
@property(nonatomic, readwrite, strong) UIButton    *acceptButton;
@property(nonatomic, readwrite, strong)AVAudioPlayer *audioPlayer;
@end

@implementation MCMeetRingCallViewController

#pragma mark - LifeCycle

- (instancetype)initWithMeetItem:(MXMeet *)meetItem
{
    if (self = [super init])
    {
        self.meetItem = meetItem;
        if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        {
            [self startRingcall];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterFront:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:[UIApplication sharedApplication]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:[UIApplication sharedApplication]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0x2D/255.0f green:0x9C/255.0f blue:0xF5/255.0f alpha:1.0f];
    if (self.panelView == nil)
    {
        BOOL isIpad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
        
        self.panelView = [UIView new];
        [self.view addSubview:self.panelView];
        [self.panelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).mas_offset(60);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view).mas_offset(-60);
        }];
        self.panelView.backgroundColor = [UIColor clearColor];
        
        MXUserItem *host = [self.meetItem host];
        self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 130.0f, 130.0f)];
        [self.panelView addSubview:self.avatarImageView];
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.panelView).offset(isIpad ? 54.0f : 0.0f);
            make.centerX.equalTo(self.panelView);
            make.width.equalTo(@130.0f);
            make.height.equalTo(@130.0f);
        }];
        
        self.avatarImageView.layer.masksToBounds = YES;
        self.avatarImageView.layer.cornerRadius = 130.0f / 2.0f;
        [host fetchAvatarWithCompletionHandler:^(NSError * _Nullable errorOrNil, NSString * _Nullable localPathOrNil) {
            if(localPathOrNil.length > 0)
                [self.avatarImageView setImage:[UIImage imageWithContentsOfFile:localPathOrNil]];
        }];
        
        UIView *rippleView = [UIView new];
        [self.panelView insertSubview:rippleView belowSubview:self.avatarImageView];
        [rippleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.avatarImageView).insets(UIEdgeInsetsMake(4.0f, 4.0f, 4.0f, 4.0f));
        }];
        
        self.callerLabel = [UILabel new];
        [self.panelView addSubview:self.callerLabel];
        self.callerLabel.textColor = [UIColor whiteColor];
        self.callerLabel.font = [UIFont systemFontOfSize:25.0f];
        self.callerLabel.text = host.fullName;
        [self.callerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarImageView.mas_bottom).offset(30.0f);
            make.centerX.equalTo(self.panelView);
        }];

        self.callStatusLabel = [UILabel new];
        [self.panelView addSubview:self.callStatusLabel];
        self.callStatusLabel.textColor = [UIColor whiteColor];
        self.callStatusLabel.font = [UIFont systemFontOfSize:18.0f];
        self.callStatusLabel.text = NSLocalizedString(@"Calling...", @"");
        [self.callStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarImageView.mas_bottom).offset(64.0f);
            make.centerX.equalTo(self.panelView);
        }];
        
        CGFloat imageWidth = isIpad ? 86.0f : 86.0f;
        CGRect buttonBounds = CGRectMake(0.0f, 0.0f, 100.0f, 138.0f);
        self.declineButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.panelView addSubview:self.declineButton];
        [self.declineButton setImage:[UIImage imageNamed:@"ring_decline_meet.png"] forState:UIControlStateNormal];
        [self.declineButton setTitle:NSLocalizedString(@"Dismiss", @"") forState:UIControlStateNormal];
        [self.declineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.declineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.declineButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        self.declineButton.titleLabel.numberOfLines = 0;
        self.declineButton.titleLabel.font = [UIFont systemFontOfSize:(isIpad? 22.0f:18.0f)];
        self.declineButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.declineButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.declineButton setTitleEdgeInsets:UIEdgeInsetsMake(imageWidth, -imageWidth, 0.0, 0.0)];
        [self.declineButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, (buttonBounds.size.width - imageWidth) / 2.0f, buttonBounds.size.height - imageWidth, (buttonBounds.size.width - imageWidth) / 2.0f)];
        [self.declineButton addTarget:self action:@selector(declineButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.declineButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.panelView).offset(isIpad?-8.0f:0.0f);
            make.right.equalTo(self.panelView.mas_centerX).offset(-23.0f);
            make.width.equalTo(@100.0f);
            make.height.equalTo(@138.0f);
        }];
        
        self.acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.panelView addSubview:self.acceptButton];
        [self.acceptButton setImage:[UIImage imageNamed:@"ring_join_meet.png"] forState:UIControlStateNormal];
        [self.acceptButton setTitle:NSLocalizedString(@"Accept", @"Accept") forState:UIControlStateNormal];
        [self.acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.acceptButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        self.acceptButton.titleLabel.numberOfLines = 0;
        self.acceptButton.titleLabel.font = [UIFont systemFontOfSize:(isIpad? 22.0f:18.0f)];
        self.acceptButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.acceptButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.acceptButton setTitleEdgeInsets:UIEdgeInsetsMake(imageWidth, -imageWidth, 0.0, 0.0)];
        [self.acceptButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, (buttonBounds.size.width - imageWidth) / 2.0f, buttonBounds.size.height - imageWidth, (buttonBounds.size.width - imageWidth) / 2.0f)];
        [self.acceptButton addTarget:self action:@selector(acceptButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.acceptButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.panelView).offset(isIpad?-8.0f:0.0f);
            make.left.equalTo(self.panelView.mas_centerX).offset(23.0f);
            make.width.equalTo(@100.0f);
            make.height.equalTo(@138.0f);
        }];
        
        
        NSTimeInterval beginTime = CACurrentMediaTime();
        for (NSInteger i=0; i<2; i+=1)
        {
            CALayer *circle = [CALayer layer];
            circle.frame = CGRectMake(0.0f, 0.0f, 122.0f, 122.0f);
            circle.backgroundColor = [UIColor clearColor].CGColor;
            circle.borderWidth = 10.0f;
            circle.borderColor = [UIColor whiteColor].CGColor;
            circle.anchorPoint = CGPointMake(0.5, 0.5);
            circle.opacity = 1.0;
            circle.cornerRadius = CGRectGetHeight(circle.bounds) * 0.5;
            circle.transform = CATransform3DMakeScale(0.0, 0.0, 0.0);
            
            CAKeyframeAnimation *scaleAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
            scaleAnim.values = @[
                                 [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 0.0)],
                                 [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.8, 1.8, 0.0)]
                                 ];
            
            CAKeyframeAnimation *opacityAnim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
            opacityAnim.values = @[@(1.0), @(0.0)];
            
            CAKeyframeAnimation *boarderWidthAnim = [CAKeyframeAnimation animationWithKeyPath:@"borderWidth"];
            boarderWidthAnim.values = @[@6, @1];
            
            CAAnimationGroup *animGroup = [CAAnimationGroup animation];
            animGroup.removedOnCompletion = NO;
            animGroup.beginTime = beginTime - (2.2 - (0.5 * i));
            animGroup.repeatCount = HUGE_VALF;
            animGroup.duration = 1.0;
            animGroup.animations = @[scaleAnim, opacityAnim, boarderWidthAnim];
            animGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            
            [rippleView.layer addSublayer:circle];
            [circle addAnimation:animGroup forKey:@"spinkit-anim"];
        }
    }
}

- (void)dealloc
{
    [self.audioPlayer stop];
    self.audioPlayer = nil;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    BOOL isIpad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    if (isIpad)
        return UIInterfaceOrientationMaskAll;
    else
        return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - Private Method

- (void)startRingcall
{
    if( self.audioPlayer )
        [self.audioPlayer stop];
    NSURL* musicFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"meetcalling" ofType:@"caf"]];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile error:nil];
    [self.audioPlayer play];
    self.audioPlayer.numberOfLoops = 1;
}

- (void)stopRingcall
{
    if( self.audioPlayer )
        [self.audioPlayer stop];
    self.audioPlayer = nil;
}

#pragma mark - WidgetsActions

- (IBAction)declineButtonPressed:(id)sender;
{
    if([self.delegate respondsToSelector:@selector(meetRingCallView:didDeclineWithMeetItem:)])
        [self.delegate meetRingCallView:self didDeclineWithMeetItem:self.meetItem];
}

- (IBAction)acceptButtonPressed:(id)sender;
{
    if([self.delegate respondsToSelector:@selector(meetRingCallView:didAcceptWithMeetItem:)])
        [self.delegate meetRingCallView:self didAcceptWithMeetItem:self.meetItem];
    
}

#pragma mark - Notification

- (void)applicationDidEnterFront:(NSNotification*)aNotification
{
    [self startRingcall];
}

- (void)applicationDidEnterBackground:(NSNotification *)aNotification
{
    [self stopRingcall];
}

@end
