//
//  MXTelCallController.m
//  MoxtraBinder
//
//  Created by mac on 16/10/8.
//
//

#import <AVFoundation/AVFoundation.h>

#import "MCCallController.h"
#import "NSTimer+MCHelper.h"
#import "MXUserItem+MCHelper.h"

#define TEL_CALL_VIEW_BTN_WIDTH 75
#define TEL_CALL_VIEW_BTN_BORDER_WIDTH 1.0f
#define TEL_BUTTON_LABEL_GAP ([self deviceIsIPad] ? 10.0f : 4.5f)
#define TEL_BUTTON_GAP ([self deviceIsIPad] ? 60.0f : ([self deviceIsIPhone5] ? 23.0f : 28.0f) )
#define TEL_CIRCLE_COLOR [UIColor colorWithWhite:1.0f alpha:0.8f]

@interface MCCallController ()<UICollectionViewDelegate, UICollectionViewDataSource>{
    int second;
    int minute;
    int hour;
    int allSecond;
    BOOL isShowingKeyPad;
    BOOL isJoiningMeet;
    BOOL hasCallConfirmed;
}

@property (nonatomic, strong) UIImageView* avatarImgView;
@property (nonatomic, strong) UIImageView* bigAvatarImgView;
@property (nonatomic, strong) UIView* rippleView;
@property (nonatomic, strong) UIView* bigRippleView;
@property (nonatomic, strong) UILabel* nameLabel;
@property (nonatomic, strong) UILabel* callStatusLabel;
@property (nonatomic, strong) UILabel* callTimeLabel;

@property (nonatomic, strong) UIButton* shareFileBtn;
@property (nonatomic, strong) UIButton* shareScreenBtn;
@property (nonatomic, strong) UIButton* whiteBoardbtn;
@property (nonatomic, strong) UIButton* addBtn;
@property (nonatomic, strong) UIButton* videoBtn;
@property (nonatomic, strong) UIButton* keypadBtn;
@property (nonatomic, strong) UILabel* shareFileLabel;
@property (nonatomic, strong) UILabel* shareScreenLabel;
@property (nonatomic, strong) UILabel* whiteBoardLabel;
@property (nonatomic, strong) UILabel* addLabel;
@property (nonatomic, strong) UILabel* videoLabel;
@property (nonatomic, strong) UILabel* keypadLabel;

@property (nonatomic, strong) UIButton* endBtn;
@property (nonatomic, strong) UIButton* audioBtn;
@property (nonatomic, strong) UILabel* audioLabel;
@property (nonatomic, strong) UIButton* speakerBtn;
@property (nonatomic, strong) UILabel* speakerLabel;

//key pad view
@property (nonatomic, strong) UIButton* hideBtn;
@property (nonatomic, strong) UILabel* inputLabel;
@property (nonatomic, strong) UICollectionView* keypadCollectionView;

//call in view
@property (nonatomic, strong) UIButton* declineBtn;
@property (nonatomic, strong) UIButton* acceptBtn;
@property (nonatomic, strong) UILabel* declineLabel;
@property (nonatomic, strong) UILabel* acceptLabel;

//other
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSTimer* timer;

//pannel
@property (nonatomic, strong) UIView* callViewPanel;

@end

static NSString* cellID = @"keyPadCell";


@implementation MCCallController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterFront:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:[UIApplication sharedApplication]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:[UIApplication sharedApplication]];
    
    //panel
    self.callViewPanel = [[UIView alloc] initWithFrame:self.view.bounds];
    self.callViewPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.callViewPanel.clipsToBounds = YES;
    self.callViewPanel.backgroundColor = [self colorWithHex:0x387FB7 alpha:1.0f];
    [self.view addSubview:self.callViewPanel];

    //Action buttons and labels
    self.shareScreenLabel = [[UILabel alloc] init];
    self.shareScreenLabel.text = NSLocalizedString(@"Share Screen", @"button title");
    [self.callViewPanel addSubview:self.shareScreenLabel];
    [self.shareScreenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_centerY).offset(15.0f);
        make.height.mas_equalTo(14.0f);
        make.width.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH*1.2f);
    }];
    
    self.shareScreenBtn = [[UIButton alloc] init];
    [self.shareScreenBtn setImage:[[UIImage imageNamed:@"tel_screen_share"] mc_branding] forState:UIControlStateNormal];
    [self.shareScreenBtn setImage:[UIImage imageNamed:@"tel_screen_share_black"] forState:UIControlStateHighlighted];
    [self.shareScreenBtn addTarget:self action:@selector(clickShareScreen:) forControlEvents:UIControlEventTouchUpInside];
    [self.callViewPanel addSubview:self.shareScreenBtn];
    [self.shareScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
        make.height.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
        make.centerX.equalTo(self.shareScreenLabel.mas_centerX);
        make.bottom.equalTo(self.shareScreenLabel.mas_top).offset(-TEL_BUTTON_LABEL_GAP);
    }];
    
    self.shareFileBtn = [[UIButton alloc] init];
    [self.shareFileBtn setImage:[[UIImage imageNamed:@"tel_share_file"] mc_branding] forState:UIControlStateNormal];
    [self.shareFileBtn setImage:[UIImage imageNamed:@"tel_share_file_black"] forState:UIControlStateHighlighted];
    [self.shareFileBtn addTarget:self action:@selector(clickShareFile:) forControlEvents:UIControlEventTouchUpInside];
    [self.callViewPanel addSubview:self.shareFileBtn];
    [self.shareFileBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
        make.height.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
        make.centerY.equalTo(self.shareScreenBtn.mas_centerY);
        make.left.equalTo(self.shareScreenBtn.mas_right).offset(TEL_BUTTON_GAP);
    }];
    
    self.shareFileLabel = [[UILabel alloc] init];
    self.shareFileLabel.text = NSLocalizedString(@"Share File", @"button title");
    [self.callViewPanel addSubview:self.shareFileLabel];
    [self.shareFileLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.shareFileBtn.mas_centerX);
        make.top.equalTo(self.shareFileBtn.mas_bottom).offset(TEL_BUTTON_LABEL_GAP);
        make.height.mas_equalTo(14.0f);
        make.width.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH*1.2f);
    }];
    
    self.whiteBoardbtn = [[UIButton alloc] init];
    [self.whiteBoardbtn setImage:[[UIImage imageNamed:@"tel_whiteboard"] mc_branding] forState:UIControlStateNormal];
    [self.whiteBoardbtn setImage:[UIImage imageNamed:@"tel_whiteboard_black"] forState:UIControlStateHighlighted];
    [self.whiteBoardbtn addTarget:self action:@selector(clickWhiteboard:) forControlEvents:UIControlEventTouchUpInside];
    [self.callViewPanel addSubview:self.whiteBoardbtn];
    [self.whiteBoardbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
        make.height.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
        make.right.equalTo(self.shareScreenBtn.mas_left).offset(-TEL_BUTTON_GAP);
        make.centerY.equalTo(self.shareScreenBtn.mas_centerY);
    }];
    
    self.whiteBoardLabel = [[UILabel alloc] init];
    self.whiteBoardLabel.text = NSLocalizedString(@"Whiteboard", @"button title");
    [self.callViewPanel addSubview:self.whiteBoardLabel];
    [self.whiteBoardLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.whiteBoardbtn.mas_centerX);
        make.top.equalTo(self.whiteBoardbtn.mas_bottom).offset(TEL_BUTTON_LABEL_GAP);
        make.height.mas_equalTo(14.0f);
        make.width.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH*1.2f);
    }];
    
    self.videoBtn = [[UIButton alloc] init];
    [self.videoBtn setImage:[[UIImage imageNamed:@"tel_video"] mc_branding] forState:UIControlStateNormal];
    [self.videoBtn setImage:[UIImage imageNamed:@"tel_video_black"] forState:UIControlStateHighlighted];
    [self.videoBtn addTarget:self action:@selector(clickVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.callViewPanel addSubview:self.videoBtn];
    [self.videoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
        make.height.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
        make.centerX.equalTo(self.shareScreenBtn.mas_centerX);
        make.top.equalTo(self.shareFileLabel.mas_bottom).offset(17.0f);
    }];
    
    self.videoLabel = [[UILabel alloc] init];
    self.videoLabel.text = NSLocalizedString(@"Video", @"button title");
    [self.callViewPanel addSubview:self.videoLabel];
    [self.videoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.videoBtn.mas_centerX);
        make.top.equalTo(self.videoBtn.mas_bottom).offset(TEL_BUTTON_LABEL_GAP);
        make.height.mas_equalTo(14.0f);
        make.width.equalTo(self.videoBtn.mas_width).multipliedBy(1.2);
    }];
    
    self.addBtn = [[UIButton alloc] init];
    [self.addBtn setImage:[[UIImage imageNamed:@"tel_add_user"] mc_branding] forState:UIControlStateNormal];
    [self.addBtn setImage:[UIImage imageNamed:@"tel_add_user_black"] forState:UIControlStateHighlighted];
    [self.addBtn addTarget:self action:@selector(clickAdd:) forControlEvents:UIControlEventTouchUpInside];
    [self.callViewPanel addSubview:self.addBtn];
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
        make.height.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
        make.centerY.equalTo(self.videoBtn.mas_centerY);
        make.right.equalTo(self.videoBtn.mas_left).offset(-TEL_BUTTON_GAP);
    }];
    
    self.addLabel = [[UILabel alloc] init];
    self.addLabel.text = NSLocalizedString(@"Invite", @"button title");
    [self.callViewPanel addSubview:self.addLabel];
    [self.addLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.addBtn.mas_centerX);
        make.top.equalTo(self.addBtn.mas_bottom).offset(TEL_BUTTON_LABEL_GAP);
        make.height.mas_equalTo(14.0f);
        make.width.equalTo(self.addBtn.mas_width).multipliedBy(1.2);
    }];
    
    self.keypadBtn = [[UIButton alloc] init];
    [self.keypadBtn setImage:[[UIImage imageNamed:@"tel_keypad_line"] mc_branding] forState:UIControlStateNormal];
    [self.keypadBtn setImage:[UIImage imageNamed:@"tel_keypad_line_black"] forState:UIControlStateHighlighted];
    [self.keypadBtn addTarget:self action:@selector(clickKeypad:) forControlEvents:UIControlEventTouchUpInside];
    [self.callViewPanel addSubview:self.keypadBtn];
    [self.keypadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
        make.height.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
        make.centerY.equalTo(self.videoBtn.mas_centerY);
        make.left.equalTo(self.videoBtn.mas_right).offset(TEL_BUTTON_GAP);
    }];
    
    self.keypadLabel = [[UILabel alloc] init];
    self.keypadLabel.text = NSLocalizedString(@"Keypad", @"button title");
    [self.callViewPanel addSubview:self.keypadLabel];
    [self.keypadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.keypadBtn.mas_centerX);
        make.top.equalTo(self.keypadBtn.mas_bottom).offset(TEL_BUTTON_LABEL_GAP);
        make.height.mas_equalTo(14.0f);
        make.width.equalTo(self.keypadBtn.mas_width).multipliedBy(1.2);
    }];
    
    //config action buttons
    NSArray* buttons = @[self.shareFileBtn,self.shareScreenBtn,self.whiteBoardbtn,self.addBtn,self.videoBtn,self.keypadBtn];
    for (UIButton* btn in buttons)
    {
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = TEL_CALL_VIEW_BTN_WIDTH/2.0f;
        btn.layer.borderWidth = TEL_CALL_VIEW_BTN_BORDER_WIDTH;
        btn.layer.borderColor = TEL_CIRCLE_COLOR.CGColor;
        btn.tintColor = [UIColor whiteColor];
        [btn setBackgroundImage:[UIImage mc_imageWithColor:[UIColor whiteColor] andSize:CGSizeMake(TEL_CALL_VIEW_BTN_WIDTH, TEL_CALL_VIEW_BTN_WIDTH)] forState:UIControlStateHighlighted];
    }
    
    //config button labels
    NSArray* labels = @[self.shareFileLabel,self.shareScreenLabel,self.whiteBoardLabel,self.addLabel,self.videoLabel,self.keypadLabel];
    for (UILabel* label in labels)
    {
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:12.0f];
        label.textAlignment = NSTextAlignmentCenter;
    }
    
    //Avatar , name and statues label
    self.callStatusLabel = [[UILabel alloc] init];
    self.callStatusLabel.backgroundColor = [self colorWithHex:0x387FB7 alpha:1.0f];
    self.callStatusLabel.textAlignment = NSTextAlignmentCenter;
    self.callStatusLabel.font = [UIFont systemFontOfSize:16.0f];
    self.callStatusLabel.textColor = [UIColor whiteColor];
    [self.callViewPanel addSubview:self.callStatusLabel];
    [self.callStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(18.5f);
        make.width.equalTo(self.view.mas_width);
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.shareScreenBtn.mas_top).offset([self deviceIsIPhone5] ? -17.0f : -45.5f);
    }];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.font = [UIFont systemFontOfSize:24.0f];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.text = self.user.fullName;
    [self.callViewPanel addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(28.0f);
        make.width.equalTo(self.view.mas_width);
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.callStatusLabel.mas_top).offset([self deviceIsIPhone5] ? 8.0f : 10.0f);
    }];
    
    self.avatarImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 86, 86)];
    self.avatarImgView.layer.masksToBounds = YES;
    self.avatarImgView.layer.cornerRadius = CGRectGetWidth(self.avatarImgView.bounds) / 2.0f;
    [self.callViewPanel addSubview:self.avatarImgView];
    [self.avatarImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(86.0f);
        make.height.mas_equalTo(86.0f);
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.nameLabel.mas_top).offset([self deviceIsIPhone5] ? -8.0f : -13.0f);
    }];
    
    self.rippleView = [UIView new];
    [self.callViewPanel insertSubview:self.rippleView belowSubview:self.avatarImgView];
    [self.rippleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.avatarImgView).insets(UIEdgeInsetsMake(4.0f, 4.0f, 4.0f, 4.0f));
    }];
    
    self.bigAvatarImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 130, 130)];
    self.bigAvatarImgView.layer.masksToBounds = YES;
    self.bigAvatarImgView.layer.cornerRadius = CGRectGetWidth(self.bigAvatarImgView.bounds) / 2.0f;
    [self.callViewPanel addSubview:self.bigAvatarImgView];
    [self.bigAvatarImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY).multipliedBy(0.5);
        make.height.mas_equalTo(130.0f);
        make.width.mas_equalTo(130.0f);
    }];
    
    self.bigRippleView = [UIView new];
    [self.callViewPanel insertSubview:self.bigRippleView belowSubview:self.bigAvatarImgView];
    [self.bigRippleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.bigAvatarImgView).insets(UIEdgeInsetsMake(4.0f, 4.0f, 4.0f, 4.0f));
    }];
    
    self.callTimeLabel = [[UILabel alloc]init];
    self.callTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.callTimeLabel.font = [UIFont systemFontOfSize:16.0f];
    self.callTimeLabel.textColor = [UIColor whiteColor];
    self.callTimeLabel.hidden = YES;
    self.callTimeLabel.text = @"00:00";
    self.callTimeLabel.hidden = YES;
    [self.callViewPanel addSubview:self.callTimeLabel];
    [self.callTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(18.0f);
        make.width.equalTo(self.view.mas_width);
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.callStatusLabel.mas_bottom).offset(10);
    }];
    
    //call in view
    self.declineBtn = [[UIButton alloc] init];
    self.declineBtn.layer.masksToBounds = YES;
    self.declineBtn.clipsToBounds = YES;
    self.declineBtn.layer.cornerRadius = TEL_CALL_VIEW_BTN_WIDTH/2.0f;
    self.declineBtn.tintColor = [self colorWithHex:0xFF3300 alpha:1.0f];
    [self.declineBtn setBackgroundImage:[[UIImage mc_imageNamed:@"tel_circle_solid"] mc_branding] forState:UIControlStateNormal];
    [self.declineBtn setImage:[UIImage imageNamed:@"tel_end_call"] forState:UIControlStateNormal];
    [self.declineBtn addTarget:self action:@selector(clickDecline:) forControlEvents:UIControlEventTouchUpInside];
    [self.callViewPanel addSubview:self.declineBtn];
    [self.declineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bigAvatarImgView.mas_left).offset(2.5);
        make.centerY.equalTo(self.view.mas_centerY).multipliedBy(1.5f);
        make.height.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
        make.width.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
    }];
    
    self.declineLabel = [[UILabel alloc]init];
    self.declineLabel.text = NSLocalizedString(@"Decline", @"button title");
    self.declineLabel.textAlignment = NSTextAlignmentCenter;
    self.declineLabel.textColor = [UIColor whiteColor];
    self.declineLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.callViewPanel addSubview:self.declineLabel];
    [self.declineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.declineBtn.mas_centerX);
        make.top.equalTo(self.declineBtn.mas_bottom).offset(6.0f);
        make.height.mas_equalTo(25.0f);
        make.width.equalTo(self.declineBtn.mas_width).multipliedBy(1.5);
    }];
    
    self.acceptBtn = [[UIButton alloc]init];
    self.acceptBtn.layer.masksToBounds = YES;
    self.acceptBtn.layer.cornerRadius = TEL_CALL_VIEW_BTN_WIDTH/2.0f;
    self.acceptBtn.tintColor = [self colorWithHex:0x4CD964 alpha:1.0f];
    [self.acceptBtn setBackgroundImage:[[UIImage mc_imageNamed:@"tel_circle_solid"] mc_branding] forState:UIControlStateNormal];
    [self.acceptBtn setImage:[UIImage imageNamed:@"tel_reg_call_button"] forState:UIControlStateNormal];
    [self.acceptBtn addTarget:self action:@selector(clickAccept:) forControlEvents:UIControlEventTouchUpInside];
    [self.callViewPanel addSubview:self.acceptBtn];
    [self.acceptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bigAvatarImgView.mas_right).offset(-2.5f);
        make.centerY.equalTo(self.view.mas_centerY).multipliedBy(1.5f);
        make.height.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
        make.width.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
    }];
    
    self.acceptLabel = [[UILabel alloc]init];
    self.acceptLabel.text = NSLocalizedString(@"Accept", @"button title");
    self.acceptLabel.textAlignment = NSTextAlignmentCenter;
    self.acceptLabel.textColor = [UIColor whiteColor];
    self.acceptLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.callViewPanel addSubview:self.acceptLabel];
    [self.acceptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.acceptBtn.mas_centerX);
        make.top.equalTo(self.acceptBtn.mas_bottom).offset(6.0f);
        make.height.mas_equalTo(25.0f);
        make.width.equalTo(self.acceptBtn.mas_width).multipliedBy(1.5);
    }];
    
    //keypad
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(TEL_CALL_VIEW_BTN_WIDTH, TEL_CALL_VIEW_BTN_WIDTH);
    layout.minimumLineSpacing = 17.0f;
    layout.minimumInteritemSpacing = [self deviceIsIPhone5] ? 23.0f : 28.0f;
    self.keypadCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, TEL_CALL_VIEW_BTN_WIDTH*3 + 56.0f, TEL_CALL_VIEW_BTN_WIDTH*4 + 51.0f) collectionViewLayout:layout];
    [self.keypadCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
    self.keypadCollectionView.center = self.view.center;
    self.keypadCollectionView.delegate = self;
    self.keypadCollectionView.dataSource = self;
    self.keypadCollectionView.alpha = 0.0f;
    self.keypadCollectionView.backgroundColor = [UIColor clearColor];
    self.keypadCollectionView.scrollEnabled = NO;
    [self.callViewPanel addSubview:self.keypadCollectionView];
    
    //input label
    self.inputLabel = [[UILabel alloc]init];
    self.inputLabel.text = @"";
    self.inputLabel.alpha = 0.0f;
    self.inputLabel.lineBreakMode = NSLineBreakByTruncatingHead;
    self.inputLabel.textAlignment = NSTextAlignmentCenter;
    self.inputLabel.textColor = [UIColor whiteColor];
    self.inputLabel.font = [UIFont fontWithName:@"ProximaNova-Light" size:38.0f];
    [self.callViewPanel addSubview:self.inputLabel];
    [self.inputLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH*3 + 50.0f);
        make.bottom.equalTo(self.keypadCollectionView.mas_top).offset([self deviceIsIPhone5] ? -25.0f : -55.5f);
        make.height.mas_equalTo(30.0f);
    }];
    
    //other buttons
    self.endBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.endBtn.layer.masksToBounds = YES;
    self.endBtn.layer.cornerRadius = TEL_CALL_VIEW_BTN_WIDTH/2.0f;
    [self.endBtn setBackgroundImage:[[UIImage imageNamed:@"tel_circle_solid"] mc_branding] forState:UIControlStateNormal];
    [self.endBtn setImage:[UIImage imageNamed:@"tel_end_call"] forState:UIControlStateNormal];
    [self.endBtn setTintColor:[self colorWithHex:0xFF3300 alpha:1.0f]];
    [self.endBtn addTarget:self action:@selector(clickEndCall:) forControlEvents:UIControlEventTouchUpInside];
    [self.callViewPanel addSubview:self.endBtn];
    [self.endBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
        make.height.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo([self deviceIsIPhone5]? self.videoLabel.mas_bottom : self.keypadCollectionView.mas_bottom).offset(25.0f);
    }];
    
    self.speakerBtn = [[UIButton alloc] init];
    self.speakerBtn.layer.masksToBounds = YES;
    self.speakerBtn.layer.cornerRadius = 60.0f/2.0f;
    self.speakerBtn.layer.borderWidth = TEL_CALL_VIEW_BTN_BORDER_WIDTH;
    self.speakerBtn.layer.borderColor = TEL_CIRCLE_COLOR.CGColor;
    [self.speakerBtn setImage:[[UIImage imageNamed:@"tel_speaker"] mc_branding] forState:UIControlStateNormal];
    [self.speakerBtn setImage:[UIImage imageNamed:@"tel_speaker_black"] forState:UIControlStateSelected];
    [self.speakerBtn setImage:[UIImage imageNamed:@"tel_speaker_black"] forState:UIControlStateHighlighted];
    [self.speakerBtn setBackgroundImage:[UIImage mc_imageWithColor:[UIColor whiteColor] andSize:CGSizeMake(TEL_CALL_VIEW_BTN_WIDTH, TEL_CALL_VIEW_BTN_WIDTH)] forState:UIControlStateSelected];
    [self.speakerBtn setBackgroundImage:[UIImage mc_imageWithColor:[UIColor whiteColor] andSize:CGSizeMake(TEL_CALL_VIEW_BTN_WIDTH, TEL_CALL_VIEW_BTN_WIDTH)] forState:UIControlStateHighlighted];
    [self.speakerBtn setTintColor:[UIColor whiteColor]];
    [self.speakerBtn addTarget:self action:@selector(clickSpeaker:) forControlEvents:UIControlEventTouchUpInside];
    [self.callViewPanel addSubview:self.speakerBtn];
    [self.speakerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(60.0f);
        make.height.mas_equalTo(60.0f);
        make.centerX.equalTo(self.keypadLabel.mas_centerX);
        make.centerY.equalTo(self.endBtn.mas_centerY);
    }];
    
    self.speakerLabel = [[UILabel alloc]init];
    self.speakerLabel.text = NSLocalizedString(@"Speaker", @"button title");
    self.speakerLabel.textAlignment = NSTextAlignmentCenter;
    self.speakerLabel.textColor = [UIColor whiteColor];
    self.speakerLabel.font = [UIFont systemFontOfSize:12.0f];
    [self.callViewPanel addSubview:self.speakerLabel];
    [self.speakerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.speakerBtn.mas_centerX);
        make.top.equalTo(self.speakerBtn.mas_bottom).offset(TEL_BUTTON_LABEL_GAP);
        make.height.mas_equalTo(14.0f);
        make.width.equalTo(self.speakerBtn.mas_width).multipliedBy(1.2f);
    }];
    
    self.audioBtn = [[UIButton alloc] init];
    self.audioBtn.layer.masksToBounds = YES;
    self.audioBtn.layer.cornerRadius = 60.0f/2.0f;
    self.audioBtn.layer.borderWidth = TEL_CALL_VIEW_BTN_BORDER_WIDTH;
    self.audioBtn.layer.borderColor = TEL_CIRCLE_COLOR.CGColor;
    [self.audioBtn setImage:[[UIImage imageNamed:@"tel_mute"] mc_branding] forState:UIControlStateNormal];
    [self.audioBtn setImage:[UIImage imageNamed:@"tel_mute_black"] forState:UIControlStateSelected];
    [self.audioBtn setImage:[UIImage imageNamed:@"tel_mute_black"] forState:UIControlStateHighlighted];
    [self.audioBtn setBackgroundImage:[UIImage mc_imageWithColor:[UIColor whiteColor] andSize:CGSizeMake(TEL_CALL_VIEW_BTN_WIDTH, TEL_CALL_VIEW_BTN_WIDTH)] forState:UIControlStateSelected];
    [self.audioBtn setBackgroundImage:[UIImage mc_imageWithColor:[UIColor whiteColor] andSize:CGSizeMake(TEL_CALL_VIEW_BTN_WIDTH, TEL_CALL_VIEW_BTN_WIDTH)] forState:UIControlStateHighlighted];
    [self.audioBtn setTintColor:[UIColor whiteColor]];
    [self.audioBtn addTarget:self action:@selector(clickAudio:) forControlEvents:UIControlEventTouchUpInside];
    [self.callViewPanel addSubview:self.audioBtn];
    [self.audioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(60.0f);
        make.height.mas_equalTo(60.0f);
        make.centerX.equalTo(self.addLabel.mas_centerX);
        make.centerY.equalTo(self.endBtn.mas_centerY);
    }];
    
    self.audioLabel = [[UILabel alloc]init];
    self.audioLabel.text = NSLocalizedString(@"Mute", @"button title");
    self.audioLabel.textAlignment = NSTextAlignmentCenter;
    self.audioLabel.textColor = [UIColor whiteColor];
    self.audioLabel.font = [UIFont systemFontOfSize:12.0f];
    [self.callViewPanel addSubview:self.audioLabel];
    [self.audioLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.audioBtn.mas_centerX);
        make.top.equalTo(self.audioBtn.mas_bottom).offset(TEL_BUTTON_LABEL_GAP);
        make.height.mas_equalTo(14.0f);
        make.width.equalTo(self.audioBtn.mas_width).multipliedBy(1.2f);
    }];
    
    self.hideBtn = [[UIButton alloc]init];
    self.hideBtn.alpha = 0.0f;
    self.hideBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.hideBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.hideBtn setTitle:NSLocalizedString(@"hide", @"button title") forState:UIControlStateNormal];
    [self.hideBtn addTarget:self action:@selector(clickHide:) forControlEvents:UIControlEventTouchUpInside];
    [self.callViewPanel addSubview:self.hideBtn];
    [self.hideBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
        make.height.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
        make.centerX.equalTo(self.endBtn.mas_centerX).offset(TEL_CALL_VIEW_BTN_WIDTH + 28.0f);
        make.centerY.equalTo(self.endBtn.mas_centerY);
    }];
    
    //meet function
    [self disableMeetFunction];
    
    //config view mode
    if (self.isCallOut)
    {
        [self showCallOutView];
        [self makeOutgoingCall];
        [self startAvatarAnimationWithRippleView:self.rippleView];
    }
    else
    {
        [self showCallInView];
        [self startAvatarAnimationWithRippleView:self.bigRippleView];
        //in case play ring call twice when receive a normal meeting.
        [self playRingtone];
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.user = _user;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.audioPlayer stop];
    self.audioPlayer = nil;
}

- (void)statusBarOrientationChange:(id)sender
{
    
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    self.keypadCollectionView.center = self.view.center;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UI Change

- (void)showKeypadView
{
    isShowingKeyPad = YES;
    [UIView animateWithDuration:0.2f animations:^{
        self.keypadCollectionView.alpha = 1.0f;
        self.hideBtn.alpha = 1.0f;
        self.inputLabel.alpha = 1.0f;
        
        self.avatarImgView.alpha = 0.0f;
        self.rippleView.alpha = 0.0f;
        self.nameLabel.alpha = 0.0f;
        self.callStatusLabel.alpha = 0.0f;
        self.shareFileBtn.alpha = 0.0f;
        self.shareFileLabel.alpha = 0.0f;
        self.shareScreenBtn.alpha = 0.0f;
        self.shareScreenLabel.alpha = 0.0f;
        self.whiteBoardbtn.alpha = 0.0f;
        self.whiteBoardLabel.alpha = 0.0f;
        self.addBtn.alpha = 0.0f;
        self.addLabel.alpha = 0.0f;
        self.videoBtn.alpha = 0.0f;
        self.videoLabel.alpha = 0.0f;
        self.keypadBtn.alpha = 0.0f;
        self.keypadLabel.alpha = 0.0f;
        self.speakerBtn.alpha = 0.0f;
        self.audioBtn.alpha = 0.0f;
        self.speakerLabel.alpha = 0.0f;
        self.audioLabel.alpha = 0.0f;
        
        if ([self deviceIsIPhone5])
        {
            [self.endBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
                make.height.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
                make.centerX.equalTo(self.view.mas_centerX);
                make.top.equalTo(self.keypadCollectionView.mas_bottom).offset(20.0f);
            }];
            [self.callViewPanel layoutIfNeeded];
        }
    }];
}

- (void)hideKeypadView
{
    isShowingKeyPad = NO;
    [UIView animateWithDuration:0.2f animations:^{
        self.keypadCollectionView.alpha = 0.0f;
        self.hideBtn.alpha = 0.0f;
        self.inputLabel.alpha = 0.0f;
        
        self.avatarImgView.alpha = 1.0f;
        self.rippleView.alpha = 1.0f;
        self.nameLabel.alpha = 1.0f;
        self.callStatusLabel.alpha = 1.0f;
        self.shareFileBtn.alpha = 1.0f;
        self.shareFileLabel.alpha = 1.0f;
        self.shareScreenBtn.alpha = 1.0f;
        self.shareScreenLabel.alpha = 1.0f;
        self.whiteBoardbtn.alpha = 1.0f;
        self.whiteBoardLabel.alpha = 1.0f;
        self.addBtn.alpha = 1.0f;
        self.addLabel.alpha = 1.0f;
        self.videoBtn.alpha = 1.0f;
        self.videoLabel.alpha = 1.0f;
        self.keypadBtn.alpha = 1.0f;
        self.keypadLabel.alpha = 1.0f;
        self.speakerBtn.alpha = 1.0f;
        self.audioBtn.alpha = 1.0f;
        self.speakerLabel.alpha =  1.0f;
        self.audioLabel.alpha = 1.0f;
        
        if ([self deviceIsIPhone5])
        {
            [self.endBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
                make.height.mas_equalTo(TEL_CALL_VIEW_BTN_WIDTH);
                make.centerX.equalTo(self.view.mas_centerX);
                make.top.equalTo(self.videoLabel.mas_bottom).offset(25.0f);
            }];
            [self.callViewPanel layoutIfNeeded];
        }
    }];
}

- (void)showCallInView
{
    
    self.callStatusLabel.alpha = 0.0f;
    self.shareFileBtn.alpha = 0.0f;
    self.shareFileLabel.alpha = 0.0f;
    self.shareScreenBtn.alpha = 0.0f;
    self.shareScreenLabel.alpha = 0.0f;
    self.whiteBoardbtn.alpha = 0.0f;
    self.whiteBoardLabel.alpha = 0.0f;
    self.addBtn.alpha = 0.0f;
    self.addLabel.alpha = 0.0f;
    self.videoBtn.alpha = 0.0f;
    self.videoLabel.alpha = 0.0f;
    self.keypadBtn.alpha = 0.0f;
    self.keypadLabel.alpha = 0.0f;
    self.endBtn.alpha = 0.0f;
    self.speakerBtn.alpha = 0.0f;
    self.audioBtn.alpha = 0.0f;
    self.speakerLabel.alpha = 0.0f;
    self.audioLabel.alpha = 0.0f;
    self.avatarImgView.alpha = 0.0f;
    self.rippleView.alpha = 0.0f;
    
    self.acceptBtn.alpha = 1.0f;
    self.declineBtn.alpha = 1.0f;
    self.acceptLabel.alpha = 1.0f;
    self.declineLabel.alpha = 1.0f;
    self.bigAvatarImgView.alpha = 1.0f;
    self.bigRippleView.alpha = 1.0f;
    
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(self.view.mas_width);
        make.height.mas_equalTo(28.0f);
        make.top.equalTo(self.bigAvatarImgView.mas_bottom).offset(36.5f);
    }];
}

- (void)showCallOutView
{
    
    self.callStatusLabel.alpha = 1.0f;
    self.shareFileBtn.alpha = 1.0f;
    self.shareFileLabel.alpha = 1.0f;
    self.shareScreenBtn.alpha = 1.0f;
    self.shareScreenLabel.alpha = 1.0f;
    self.whiteBoardbtn.alpha = 1.0f;
    self.whiteBoardLabel.alpha = 1.0f;
    self.addBtn.alpha = 1.0f;
    self.addLabel.alpha = 1.0f;
    self.videoBtn.alpha = 1.0f;
    self.videoLabel.alpha = 1.0f;
    self.keypadBtn.alpha = 1.0f;
    self.keypadLabel.alpha = 1.0f;
    self.endBtn.alpha = 1.0f;
    self.speakerBtn.alpha = 1.0f;
    self.audioBtn.alpha = 1.0f;
    self.audioLabel.alpha = 1.0f;
    self.speakerLabel.alpha = 1.0f;
    self.avatarImgView.alpha = 1.0f;
    self.rippleView.alpha = 1.0f;
    
    self.acceptBtn.alpha = 0.0f;
    self.declineBtn.alpha = 0.0f;
    self.acceptLabel.alpha = 0.0f;
    self.declineLabel.alpha = 0.0f;
    self.bigAvatarImgView.alpha = 0.0f;
    self.bigRippleView.alpha = 0.0f;
    
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(28.0f);
        make.width.equalTo(self.view.mas_width);
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.callStatusLabel.mas_top).offset(-10.0f);
    }];
}

- (void)showEndCallView
{
    
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(28.0f);
        make.width.equalTo(self.view.mas_width);
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.callStatusLabel.mas_top).offset(-10.0f);
    }];
    
    self.avatarImgView.alpha = 1.0f;
    self.rippleView.alpha = 1.0f;
    self.nameLabel.alpha = 1.0f;
    self.callStatusLabel.alpha = 1.0f;
    self.callTimeLabel.alpha = 1.0f;
    
    self.bigAvatarImgView.alpha = 0.0f;
    self.bigRippleView.alpha = 0.0f;
    self.shareFileBtn.alpha = 0.0f;
    self.shareScreenBtn.alpha = 0.0f;
    self.whiteBoardbtn.alpha = 0.0f;
    self.addBtn.alpha = 0.0f;
    self.videoBtn.alpha = 0.0f;
    self.keypadBtn.alpha = 0.0f;
    self.shareFileLabel.alpha = 0.0f;
    self.shareScreenLabel.alpha = 0.0f;
    self.whiteBoardLabel.alpha = 0.0f;
    self.addLabel.alpha = 0.0f;
    self.videoLabel.alpha = 0.0f;
    self.keypadLabel.alpha = 0.0f;
    
    self.endBtn.alpha = 0.0f;
    self.audioBtn.alpha = 0.0f;
    self.audioLabel.alpha = 0.0f;
    self.speakerLabel.alpha = 0.0f;
    self.speakerBtn.alpha = 0.0f;
    
    //key pad view
    self.hideBtn.alpha = 0.0f;
    self.inputLabel.alpha = 0.0f;
    self.keypadCollectionView.alpha = 0.0f;
    
    //call in view
    self.declineBtn.alpha = 0.0f;
    self.acceptBtn.alpha = 0.0f;
    self.declineLabel.alpha = 0.0f;
    self.acceptLabel.alpha = 0.0f;
}

#pragma mark - other function method

- (void)endCallWithState:(MCCallControllerState)state
{
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    
    [self.timer invalidate];
    self.timer = nil;
    
    [self.rippleView removeFromSuperview];
    if(hasCallConfirmed)
        self.callTimeLabel.hidden = NO;
    
    switch (state)
    {
        case MCCallControllerStateCanceled:
        {
            self.callStatusLabel.text = NSLocalizedString(@"Call canceled", @"call status");
            break;
        }
        case MCCallControllerStateDeclined:
        {
            self.callStatusLabel.text = NSLocalizedString(@"Call busy", @"call status");
            break;
        }
        case MCCallControllerStateNoAnswer:
        {
            self.callStatusLabel.text = NSLocalizedString(@"No Answer", @"call status");
            break;
        }
        case MCCallControllerStateCallFailed:
        {
            self.callStatusLabel.text = NSLocalizedString(@"Call failed", @"call status");
            break;
        }
        case MCCallControllerStateNormalEnded:
        {
            self.callStatusLabel.text = NSLocalizedString(@"Call ended", @"call status");
            break;
        }
        default:
            break;
    }
    [self showEndCallView];
}

- (void)startAvatarAnimationWithRippleView:(UIView *)rippleView
{
    NSTimeInterval beginTime = CACurrentMediaTime();
    for (NSInteger i=0; i<2; i+=1)
    {
        CALayer *circle = [CALayer layer];
        if(rippleView == self.rippleView)
            circle.frame = CGRectMake(0.0f, 0.0f, 79.0f, 79.0f);
        else
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

- (void)enableButton:(UIButton *)button andLabel:(UILabel *)label isEnable:(BOOL)bEnable
{
    if (button == nil || label == nil)
        return;
    if (!bEnable)
    {
        button.enabled = NO;
        button.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.3f].CGColor;
        button.tintColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
        label.textColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
    }
    else
    {
        button.enabled = YES;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.tintColor = [UIColor whiteColor];
        label.textColor = [UIColor whiteColor];
    }
}

- (void)disableMeetFunction
{
    
    NSArray* buttons = @[self.shareFileBtn,self.shareScreenBtn,self.whiteBoardbtn,self.videoBtn,self.addBtn];
    for (UIButton* btn in buttons)
    {
        btn.enabled = NO;
        btn.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.3f].CGColor;
        btn.tintColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
    }
    
    NSArray* labels = @[self.shareScreenLabel,self.shareFileLabel,self.whiteBoardLabel,self.videoLabel,self.addLabel];
    for(UILabel* label in labels)
    {
        label.textColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
    }
}

- (void)enableMeetFunction
{
    
    if (self.shareFileBtn == nil)
        return;
    
    NSArray* buttons = @[self.shareScreenBtn,self.whiteBoardbtn, self.videoBtn];
    for (UIButton* btn in buttons)
    {
        btn.enabled = YES;
        btn.layer.borderColor = [UIColor whiteColor].CGColor;
        btn.tintColor = [UIColor whiteColor];
    }
    NSArray* labels = @[self.shareScreenLabel,self.whiteBoardLabel, self.videoLabel];
    for (UILabel* label in labels)
    {
        label.textColor = [UIColor whiteColor];
    }
    
    [self enableButton:self.keypadBtn andLabel:self.keypadLabel isEnable:NO];
}

- (void)playRingtone
{
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground)
    {
        if (self.audioPlayer)
        {
            [self.audioPlayer stop];
            self.audioPlayer = nil;
        }
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"meetcalling" ofType:@"caf"];
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        NSError * error;
        if (!self.audioPlayer)
        {
            self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&error];
            self.audioPlayer.numberOfLoops = -1;
            [self.audioPlayer play];
        }
        if (error)
        {
            NSLog(@"Play ringtone error: %@", [error localizedDescription]);
        }
    }
}

- (void)makeOutgoingCall
{
    self.callStatusLabel.text = NSLocalizedString(@"Calling...", @"call status");
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\[^0-9*+]"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    if (self.callNumber.length > 0)
    {
        NSString *phoneNumber = [regex stringByReplacingMatchesInString:self.callNumber options:0 range:NSMakeRange(0, [self.callNumber length]) withTemplate:@""];
        
        if ([self.delegate respondsToSelector:@selector(mcCallController:didSendMakeCallAction:withCompletion:)])
        {
            [self.delegate mcCallController:self didSendMakeCallAction:phoneNumber withCompletion:nil];
        }
    }
}

- (void)swichToMeetRequestWithTpye:(MCSwitchToMeetType)type
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mcCallController:didSendSwitchToMeetActionWithSwitchType:completion:)])
    {
        [self.delegate mcCallController:self didSendSwitchToMeetActionWithSwitchType:type completion:nil];
    }
}

#pragma mark - WidgetsActions

- (void)clickShareScreen:(UIButton*)button
{
    [self swichToMeetRequestWithTpye:MCSwitchToMeetTypeShareScreen];
}

- (void)clickShareFile:(UIButton*)button
{
    [self swichToMeetRequestWithTpye:MCSwitchToMeetTypeShareFile];
}

- (void)clickWhiteboard:(UIButton*)button
{
    [self swichToMeetRequestWithTpye:MCSwitchToMeetTypeWhiteBoard];
}

- (void)clickAdd:(UIButton*)button
{
    [self swichToMeetRequestWithTpye:MCSwitchToMeetTypeAddUser];
}

- (void)clickVideo:(UIButton*)button
{
    [self swichToMeetRequestWithTpye:MCSwitchToMeetTypeVideo];
}

- (void)clickKeypad:(UIButton*)button
{
    [self showKeypadView];
}

- (void)clickSpeaker:(UIButton*)button
{
    self.speakerBtn.selected = !self.speakerBtn.selected;
    if (self.speakerBtn.selected)
    {
        [self turnOnSpeaker];
    }
    else
    {
        [self turnOffSpeaker];
    }
}

- (void)clickEndCall:(UIButton*)button
{
    if ([self.delegate respondsToSelector:@selector(mcCallController:didSendHangupCallActionWithCompletion:)])
    {
        [self.delegate mcCallController:self didSendHangupCallActionWithCompletion:nil];
    }
}

- (void)clickAudio:(UIButton*)button
{
    
    if (self.audioBtn.selected)
    {
        self.audioBtn.selected = NO;
        if ([self.delegate respondsToSelector:@selector(mcCallController:didSendUnMuteCallActionWithCompletion:)])
        {
            [self.delegate mcCallController:self didSendUnMuteCallActionWithCompletion:^(BOOL success) {
                if (!success)
                {
                    self.audioBtn.selected = YES;
                }
            }];
        }
    }
    else
    {
        self.audioBtn.selected = YES;
        if ([self.delegate respondsToSelector:@selector(mcCallController:didSendMuteCallActionWithCompletion:)])
        {
            [self.delegate mcCallController:self didSendMuteCallActionWithCompletion:^(BOOL success) {
                if (!success)
                {
                    self.audioBtn.selected = NO;
                }
            }];
        }
    }
}

- (void)clickHide:(UIButton*)button
{
    [self hideKeypadView];
}

- (void)clickAccept:(UIButton*)button
{
    if ([self.delegate respondsToSelector:@selector(mcCallController:didSendAnswerCallActionWithCompletion:)])
    {
        [self.delegate mcCallController:self didSendAnswerCallActionWithCompletion:nil];
    }
    
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    [self showCallOutView];
}

- (void)clickDecline:(UIButton*)button
{
    
    if ([self.delegate respondsToSelector:@selector(mcCallController:didSendRejectCallActionWithCompletion:)])
    {
        [self.delegate mcCallController:self didSendRejectCallActionWithCompletion:nil];
    }
    
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

#pragma mark - UICollectView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    NSString* keypadStr = @"123456789*0#";
    NSString* digit = [keypadStr substringWithRange:NSMakeRange(indexPath.row, 1)];
    self.inputLabel.text = [self.inputLabel.text stringByAppendingString:digit];
    
    if([self.delegate respondsToSelector:@selector(mcCallController:didSendSetCallDTMFAction:)])
    {
        [self.delegate mcCallController:self didSendSetCallDTMFAction:digit];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    NSString* path;
    if([digit isEqualToString:@"*"])
        path = @"/System/Library/Audio/UISounds/dtmf-star.caf";
    else if([digit isEqualToString:@"#"])
        path = @"/System/Library/Audio/UISounds/dtmf-pound.caf";
    else
        path = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/dtmf-%@.caf", digit];
    
    SystemSoundID soundID;
    NSURL* soundURL = [NSURL fileURLWithPath:path];
    OSStatus error = AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)soundURL,&soundID);
    if (error == kAudioServicesNoError)
        AudioServicesPlaySystemSound(soundID);
#endif

}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    UILabel* numberLabel = [cell.contentView viewWithTag:27];
    
    [UIView animateWithDuration:0.1 delay:0.0f options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowUserInteraction animations:^{
        numberLabel.textColor = self.callViewPanel.backgroundColor;
        cell.contentView.backgroundColor = [UIColor whiteColor];
    } completion:nil];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    UILabel* numberLabel = [cell.contentView viewWithTag:27];
    
    [UIView animateWithDuration:0.5 delay:0.0f options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut animations:^{
        numberLabel.textColor = [UIColor whiteColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
    } completion:nil];
}

#pragma mark - UICollectView Datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 12;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

    cell.layer.cornerRadius = TEL_CALL_VIEW_BTN_WIDTH/2.0f;
    cell.layer.borderColor = TEL_CIRCLE_COLOR.CGColor;
    cell.layer.borderWidth = TEL_CALL_VIEW_BTN_BORDER_WIDTH;
    cell.layer.masksToBounds = YES;
    
    UILabel* number = [cell viewWithTag:27];
    if (!number)
    {
        number = [[UILabel alloc]initWithFrame:cell.contentView.bounds];
        number.tag = 27;
        number.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        number.font = [UIFont fontWithName:@"ProximaNova-Light" size:36.0f];
        number.textAlignment = NSTextAlignmentCenter;
        number.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:number];
    }
    
    NSString* keypadStr = @"123456789*0#";
    number.text = [keypadStr substringWithRange:NSMakeRange(indexPath.row, 1)];
    
    return cell;
}

#pragma mark - Public Method

- (void)setUser:(MXUserItem *)user
{
    if (user)
    {
        __weak typeof(self) weakself = self;
        __block BOOL avatarReady = NO;
        [user fetchAvatarWithCompletionHandler:^(NSError * _Nullable errorOrNil, NSString * _Nullable localPathOrNil) {
            if (localPathOrNil.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:localPathOrNil])
            {
                UIImage *avatar = [UIImage imageWithContentsOfFile:localPathOrNil];
                [weakself.avatarImgView setImage:avatar];
                [weakself.bigAvatarImgView setImage:avatar];
                avatarReady = YES;
            }
        }];
        
        if (!avatarReady)
        {
            UIImage *defaultAvatar = [UIImage imageNamed:@"default_avatar"];
            [self.avatarImgView setImage:defaultAvatar];
            [self.bigAvatarImgView setImage:defaultAvatar];
        }
    }
    else
    {
        [self.avatarImgView setImage:nil];
        [self.bigAvatarImgView setImage:nil];
    }
    
    self.nameLabel.text = [user fullName];
    
    _user = user;
}

- (void)turnOnSpeaker
{
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    self.speakerBtn.selected = YES;
}

- (void)turnOffSpeaker
{
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    self.speakerBtn.selected = NO;
}

- (void)mute
{
    if(!self.audioBtn.selected)
    {
        if([self.delegate respondsToSelector:@selector(mcCallController:didSendMuteCallActionWithCompletion:)])
        {
            [self.delegate mcCallController:self didSendMuteCallActionWithCompletion:^(BOOL success) {
                if (success)
                {
                    self.audioBtn.selected = YES;
                }
            }];
        }
    }
}

- (void)unmute
{
    if (self.audioBtn.selected)
    {
        if ([self.delegate respondsToSelector:@selector(mcCallController:didSendUnMuteCallActionWithCompletion:)])
        {
            [self.delegate mcCallController:self didSendUnMuteCallActionWithCompletion:^(BOOL success) {
                if (success)
                {
                    self.audioBtn.selected = NO;
                }
            }];
        }
    }
}

- (void)inputDigit:(NSString *)digit
{
    if([self.delegate respondsToSelector:@selector(mcCallController:didSendSetCallDTMFAction:)])
    {
        [self.delegate mcCallController:self didSendSetCallDTMFAction:digit];
    }
}

- (void)switchToMeetWithVideo
{
    [self swichToMeetRequestWithTpye:MCSwitchToMeetTypeVideo];
}

- (void)answerCall
{
    [self clickAccept:self.acceptBtn];
}

- (void)rejectCall
{
    [self clickDecline:self.declineBtn];
}

- (void)setCallState:(MCCallControllerState)state
{
    
    if (state == MCCallControllerStateConfirmed)
    {
        [self.rippleView removeFromSuperview];
        
        //meet function
        if (self.isMeetFunctionEnable)
            [self enableMeetFunction];
        
        __weak MCCallController* weakSelf = self;
        if (!weakSelf.timer)
        {
            weakSelf.timer = [NSTimer mc_scheduledTimerWithTimeInterval:1.0f block:^{
                
                __strong typeof(self) strongSelf = weakSelf;
                
                if (second == 60)
                {
                    second = 0;
                    minute++;
                }
                if (minute == 60)
                {
                    minute = 0;
                    hour++;
                }
                if (hour > 0)
                {
                    strongSelf.callStatusLabel.text = [NSString stringWithFormat:@"%d:%02d:%02d",hour,minute,second];
                    strongSelf.callTimeLabel.text = [NSString stringWithFormat:@"%d:%02d:%02d",hour,minute,second];
                }
                else
                {
                    strongSelf.callStatusLabel.text = [NSString stringWithFormat:@"%02d:%02d",minute,second];
                    strongSelf.callTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",                                                                                                                                                                                                                                        minute,second];
                }
                second ++;
            }
                                                                repeats:YES];
        }
        
        second = 0;
        minute = 0;
        hour = 0;
        allSecond = 0;
        hasCallConfirmed = YES;
        self.callStatusLabel.text = @"00:00";
        self.callTimeLabel.text = @"00:00";
    }
    else if (state == MCCallControllerStateCalling)
    {
        self.callStatusLabel.text = NSLocalizedString(@"Calling...", @"call status");
    }
    else if (state == MCCallControllerStateConnecting)
    {
        self.callStatusLabel.text = NSLocalizedString(@"Connecting...", @"call status");
    }
    else
    {
        if (_isMeetFunctionEnable )
            [self enableButton:self.keypadBtn andLabel:self.keypadLabel isEnable:NO];
    }
}

#pragma mark - Notifications

- (void)applicationDidEnterFront:(NSNotification*)aNotification
{
    [self.audioPlayer play];
}

- (void)applicationDidEnterBackground:(NSNotification *)aNotification
{
    [self.audioPlayer stop];
}

#pragma mark - Helper

- (BOOL)deviceIsIPad
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

- (BOOL)deviceIsIPhone5;
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] bounds].size.height == 568.0);
}

- (UIColor *)colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha
{
    return [[UIColor alloc] initWithRed:(((hex >> 16) & 0xff) / 255.0f) green:(((hex >> 8) & 0xff) / 255.0f) blue:(((hex) & 0xff) / 255.0f) alpha:alpha];
}

@end
