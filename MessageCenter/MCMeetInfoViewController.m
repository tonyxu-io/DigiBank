//
//  MCMeetInfoViewController.m
//  DigiBank
//
//  Created by Moxtra on 2017/4/19.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCMeetInfoViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "MCInputTableViewCell.h"
#import "MCMeetRecordPlayCell.h"
#import "MCUserInfoViewController.h"

#pragma mark - MCMeetInfoMemberCell

@interface MCMeetInfoMemberCell:UITableViewCell

@property (nonatomic, strong) MXUserItem *userItem;

@end

@implementation MCMeetInfoMemberCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(15, 5, 35, 35);
    self.textLabel.frame = CGRectMake(58, 0, self.frame.size.width - 55, self.frame.size.height);
}

- (void)setUserItem:(MXUserItem *)userItem
{
    _userItem = userItem;
    self.textLabel.text = [NSString stringWithFormat:@"%@ %@%@",userItem.firstname,userItem.lastname,userItem.isMyself?@"(Me)":@""];
}

@end

#pragma mark - MCMeetInfoViewController

@interface MCMeetInfoViewController ()<UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayerController;

@property (nonatomic, strong) MXMeet *meetItem;
@property (nonatomic, strong) MXMeetListModel *meetListModel;
@property (nonatomic, strong) NSArray *tableViewData;
@property (nonatomic, strong) NSArray *selectors;
@property (nonatomic, assign) BOOL canEditMeet;

@end

static CGFloat const kSectionHeadHeight = 25.f;
static CGFloat const kDatePickControllerHeight = 250.f;

static NSString *const kInputCellReustIdentifier = @"kInputCellReustIdentifier";
static NSString *const kTimeCellReustIdentifier = @"kTimeCellReustIdentifier";
static NSString *const kNormalCellReuseIdentifier = @"kNormalCellReuseIdentifier";
static NSString *const kMemberCellReuseIdentifier = @"kMemberCellReuseIdentifier";
static NSString *const kRecordPlayCellReuseIdentifier = @"kRecordPlayCellReuseIdentifier";

@implementation MCMeetInfoViewController

#pragma mark - LifeCycle

- (instancetype)initWithMeetItem:(MXMeet *)meetItem meetListModel:(MXMeetListModel *)meetListModel
{
    if (self = [super init])
    {
        _meetItem = meetItem;
        _meetListModel = meetListModel;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Meet Info", @"Meet Info");
    
    [self setupUserInterface];
    [self loadMeetData];
    [self loadSelectorData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

#pragma mark - Getter

- (BOOL)isOwner
{
    return _meetItem.host.isMyself;
}

- (BOOL)canEditMeet
{
    return _meetItem.startTime == nil && [self isValidMeet];
}

- (BOOL)isValidMeet
{
    if(_meetItem.isRecurrent && _meetItem.endTime != nil)
    {
        return NO;
    }
    else
    {
        return [_meetItem.scheduledEndTime compare:[NSDate date]];
    }
}

- (BOOL)displayAgenda
{
    return !(self.meetItem.agenda.length == 0 && self.meetItem != nil && (!self.meetItem.host.isMyself));
}

#pragma mark - UserInterface

- (void)setupUserInterface
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.tableView registerClass:[MCInputTableViewCell class] forCellReuseIdentifier:kInputCellReustIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kNormalCellReuseIdentifier];
    [self.tableView registerClass:[MCMeetInfoMemberCell class] forCellReuseIdentifier:kMemberCellReuseIdentifier];
    [self.tableView registerClass:[MCMeetRecordPlayCell class] forCellReuseIdentifier:kRecordPlayCellReuseIdentifier];
}

#pragma mark - DataProcess

- (void)loadMeetData
{
    //Section 0 content
    NSMutableArray *section0 = [[NSMutableArray alloc] init];
    NSString *row0Sec0Content = _meetItem.topic;
    NSAttributedString *row1Sec0Content = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Share Meet Link", @"Share Meet Link") attributes:@{NSForegroundColorAttributeName:MXBrandingColor, NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    [section0 addObject:row0Sec0Content];
    [section0 addObject:row1Sec0Content];
    if (_meetItem.recordingUrl != nil)
    {
        NSString *row2Sec0Content = @"Play";
        [section0 addObject:row2Sec0Content];
    }
    
    //Section 1 content
    NSMutableArray *section1 = [[NSMutableArray alloc] init];
    NSString *row0Sec1Content = NSLocalizedString(@"Starts", @"Starts");
    NSString *row1Sec1Content = NSLocalizedString(@"Ends", @"Ends");
    [section1 addObject:row0Sec1Content];
    [section1 addObject:row1Sec1Content];
    
    //Section 2 content, if host is mySelf display agenda, elsewise display members.
    NSString *agenda = self.meetItem.agenda.length ? self.meetItem.agenda : NSLocalizedString(@"Agenda", @"Agenda");
    NSArray *sectionAgenda = @[agenda];

    NSMutableArray *sectionMembers = [[self fetchMembersArray] mutableCopy];
    NSTextAttachment *addImageAttach = [[NSTextAttachment alloc] init];
    addImageAttach.image = [[UIImage imageNamed:@"common_button_add"] mc_renderImageWithColor:MXBrandingColor];
    addImageAttach.bounds = CGRectMake(0, 0, 14, 14);
    NSMutableAttributedString *addString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@" Invite Members", @" Invite Members") attributes:@{NSForegroundColorAttributeName:MXBrandingColor}];
    NSMutableAttributedString *addAttributedString = [[NSMutableAttributedString attributedStringWithAttachment:addImageAttach] mutableCopy];
    [addAttributedString appendAttributedString:addString];
    
    //Section 3 content
    NSAttributedString *deleteMeetString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Delete Meet", @"Delete Meet") attributes:@{NSForegroundColorAttributeName:MXRedColor, NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    NSArray *section4 = @[deleteMeetString];
    
    if ([self canEditMeet])
    {
        [sectionMembers insertObject:addAttributedString atIndex:0];
        self.tableViewData = @[section0, section1, sectionAgenda,sectionMembers,section4];
    }
    else
    {
        if ([self displayAgenda])
        {
            self.tableViewData = @[section0, section1,sectionAgenda,sectionMembers];
        }
        else
        {
            self.tableViewData = @[section0, section1,sectionMembers];
        }
    }
}

- (void)loadSelectorData
{
    //Section0 selectors
    NSMutableArray *section0 = [[NSMutableArray alloc] init];
    SEL topicSelector = @selector(emptySelector);
    SEL shareSelector = @selector(shareMeetLinkTapped);
    SEL recordPlaySelector = @selector(recordPlayTapped);
    [section0 addObject:NSStringFromSelector(topicSelector)];
    [section0 addObject:NSStringFromSelector(shareSelector)];
    if (_meetItem.recordingUrl != nil)
    {
        [section0 addObject:NSStringFromSelector(recordPlaySelector)];
    }
    
    //Section1 selectors
    NSArray *section1;
    SEL startSelector = @selector(startTimeTapped);
    SEL endSelector = @selector(endTimeTapped);
    section1 = @[NSStringFromSelector(startSelector),NSStringFromSelector(endSelector)];
    
    //Section2 selectors
    SEL agendaSelector = @selector(emptySelector);
    SEL inviteSelector = @selector(inviteMembersTapped);
    SEL userInfoSelector = @selector(userInfoTapped:);
    NSArray *agendaSection = @[NSStringFromSelector(agendaSelector)];
    NSMutableArray *membersSection = [@[NSStringFromSelector(userInfoSelector)] mutableCopy];
    
    SEL deleteSelector = @selector(deleteMeetTapped);
    NSArray *meetDeleteSection = @[NSStringFromSelector(deleteSelector)];
    
    if ([self canEditMeet])
    {
        [membersSection insertObject:NSStringFromSelector(inviteSelector) atIndex:0];
        self.selectors = @[section0,section1,agendaSection,membersSection,meetDeleteSection];
    }
    else
    {
        if ([self displayAgenda])
        {
            self.selectors = @[section0, section1,agendaSection,membersSection];
        }
        else
        {
            self.selectors = @[section0, section1,membersSection];
        }
    }
}

- (NSArray *)fetchMembersArray;
{
    //Get chat's members and sort them
    NSArray<MXUserItem *> *result;
    result = [NSArray arrayWithArray:_meetItem.users];
    [result sortedArrayUsingComparator:^NSComparisonResult(MXUserItem *obj1, MXUserItem *obj2) {
        NSUInteger role1 = 0;
        NSUInteger role2 = 0;
        if (obj1.isMyself)
        {
            role1 = 1;
        }
        if ([_meetItem.host isEqual:obj1])
        {
            role1 = 2;
        }
        if (obj2.isMyself)
        {
            role2 = 1;
        }
        if ([_meetItem.host isEqual:obj2])
        {
            role2 = 2;
        }
        if(role1 != role2)
            return (role1 > role2)?NSOrderedAscending:NSOrderedDescending;
        
        return [obj1.firstname caseInsensitiveCompare:obj2.firstname];
    }];
    return result;
}

#pragma mark - UITableViewDataSource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tableViewData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableViewData[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    //Topic modify cell
                    MCInputTableViewCell *inputCell = [tableView dequeueReusableCellWithIdentifier:kInputCellReustIdentifier];
                    inputCell.text = self.meetItem.topic;
                    inputCell.editable = self.meetItem.host.isMyself;
                    inputCell.textField.tag = 999;
                    inputCell.textField.delegate = self;
                    return inputCell;
                }
                    break;
                case 1:
                {
                    UITableViewCell *shareCell = [tableView dequeueReusableCellWithIdentifier:kNormalCellReuseIdentifier];
                    shareCell.textLabel.textAlignment = NSTextAlignmentCenter;
                    [shareCell.textLabel setAttributedText:self.tableViewData[indexPath.section][indexPath.row]];
                    return shareCell;
                }
                    break;
                case 2:
                {
                    MCMeetRecordPlayCell *playCell = [tableView dequeueReusableCellWithIdentifier:kRecordPlayCellReuseIdentifier];
                    playCell.fileName = self.meetItem.recordingName;
                    return playCell;
                }
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            UITableViewCell *timeCell = [tableView dequeueReusableCellWithIdentifier:kTimeCellReustIdentifier];
            if (timeCell == nil)
            {
                timeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kTimeCellReustIdentifier];
                timeCell.detailTextLabel.font = [UIFont systemFontOfSize:15];
            }
            if (indexPath.row == 0)
            {
                //Start time cell
                timeCell.textLabel.text = NSLocalizedString(@"Starts", @"Starts");
                if (_meetItem.startTime != nil)
                {
                    timeCell.detailTextLabel.text = [NSDate mc_getLocalizedShortFullDateString:_meetItem.startTime];
                }
                else if (_meetItem.scheduledStartTime != nil)
                {
                    timeCell.detailTextLabel.text = [NSDate mc_getLocalizedShortFullDateString:_meetItem.scheduledStartTime];
                }
            }
            else
            {
                //End time cell
                timeCell.textLabel.text = NSLocalizedString(@"Ends", @"Ends");
                if (_meetItem.endTime != nil)
                {
                    timeCell.detailTextLabel.text = [NSDate mc_getLocalizedShortFullDateString:_meetItem.endTime];
                }
                else if (_meetItem.scheduledEndTime != nil)
                {
                    timeCell.detailTextLabel.text = [NSDate mc_getLocalizedShortFullDateString:_meetItem.scheduledEndTime];
                }
            }
            return timeCell;
        }
        case 2:
            if ([self displayAgenda] || [self canEditMeet])
            {
                //Section2 is agenda
                MCInputTableViewCell *agendaCell = [tableView dequeueReusableCellWithIdentifier:kInputCellReustIdentifier];
                agendaCell.textField.placeholder = self.tableViewData[indexPath.section][indexPath.row];
                agendaCell.textField.text = self.meetItem.agenda.length ? self.tableViewData[indexPath.section][indexPath.row] : nil;
                agendaCell.textField.delegate = self;
                agendaCell.textField.tag = 888;
                return agendaCell;
            }
            else
            {
                //Section2 is members
                //Config user cell
                return [self configUserCellWithIndexPath:indexPath];
            }
            break;
        case 3:
            if ([self canEditMeet] && indexPath.row == 0)
            {
                //Config invite cell
                UITableViewCell *inviteCell = [tableView dequeueReusableCellWithIdentifier:kNormalCellReuseIdentifier];
                inviteCell.textLabel.textAlignment = NSTextAlignmentCenter;
                inviteCell.textLabel.attributedText = self.tableViewData[indexPath.section][indexPath.row];
                return inviteCell;
            }
            else
            {
                return [self configUserCellWithIndexPath:indexPath];
            }
            break;
        case 4:
        {
            UITableViewCell *deleteCell = [tableView dequeueReusableCellWithIdentifier:kNormalCellReuseIdentifier];
            deleteCell.textLabel.textAlignment = NSTextAlignmentCenter;
            [deleteCell.textLabel setAttributedText:self.tableViewData[indexPath.section][indexPath.row]];
            return deleteCell;
        }
            break;
        default:
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectorName;
    if (indexPath.row > [self.selectors[indexPath.section] count] - 1)
    {
        //This situation happend only in 'members' section, bacause @selector(userInfoTapped) only saved once in self.selectors,
        //For preventing from index beyond array bounds, we do so.
        selectorName = [self.selectors[indexPath.section] lastObject];
    }
    else
    {
        selectorName = self.selectors[indexPath.section][indexPath.row];
    }
    SEL currentSelector = NSSelectorFromString(selectorName);
    
    if (indexPath.section < 2)
    {
        [self performSelector:currentSelector withObject:nil afterDelay:0];
    }
    else
    {
        //Need care when section larger or eaual 2
        
        if ([self canEditMeet])
        {
            if (indexPath.row > 0)
            {
                //This situation is calling @selector(userInfoTapped), get the user data from self.tableViewData then passed it in
                [self performSelector:currentSelector withObject:self.tableViewData[indexPath.section][indexPath.row] afterDelay:0];
            }
            else
            {
                //Agenda or invite
                [self performSelector:currentSelector withObject:nil afterDelay:0];
            }
        }
        else
        {
            //UserInfo Tapped
            [self performSelector:currentSelector withObject:self.tableViewData[indexPath.section][indexPath.row] afterDelay:0];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? DBL_EPSILON : kSectionHeadHeight;
}

#pragma mark - Helper

- (UITableViewCell *)configUserCellWithIndexPath:(NSIndexPath *)indexPath
{
    MCMeetInfoMemberCell *userCell = [self.tableView dequeueReusableCellWithIdentifier:kMemberCellReuseIdentifier];
    MXUserItem *user = self.tableViewData[indexPath.section][indexPath.row];
    userCell.userItem = user;
    [[MCMessageCenterInstance sharedInstance] getRoundedAvatarWithUser:user completionHandler:^(UIImage *avatar, NSError *error) {
        userCell.imageView.image = avatar;
    }];
    return userCell;
}

#pragma mark - TableViewSelectors

- (void)emptySelector
{
    return;
}

- (void)shareMeetLinkTapped
{
    if (_meetItem.meetURL)
    {
        UIActivityViewController *shareViewController = [[UIActivityViewController alloc] initWithActivityItems:@[_meetItem.meetURL] applicationActivities:nil];
        [self presentViewController:shareViewController animated:YES completion:nil];
    }
}

- (void)recordPlayTapped
{
    NSURL *movieURL = _meetItem.recordingUrl;
    if(movieURL == nil)
        return ;
    self.moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    self.moviePlayerController.allowsAirPlay = YES;
    self.moviePlayerController.contentURL = movieURL;
    self.moviePlayerController.movieSourceType = movieURL.isFileURL ? MPMovieSourceTypeFile : MPMovieSourceTypeUnknown;
    self.moviePlayerController.view.backgroundColor = [UIColor clearColor];
    self.moviePlayerController.view.frame = self.view.bounds;
    [self.view addSubview:self.moviePlayerController.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.moviePlayerController];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:self.moviePlayerController];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didExitFullscreen:)
                                                 name:MPMoviePlayerDidExitFullscreenNotification
                                               object:self.moviePlayerController];
    
    [self.moviePlayerController setShouldAutoplay:NO];
    [self.moviePlayerController play];
    [self.moviePlayerController setFullscreen:YES animated:YES];
}

- (void)startTimeTapped
{
    if ([self canEditMeet] && self.meetItem.startTime == nil)
    {
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        datePicker.frame = CGRectMake(0, 0, self.view.frame.size.width - 10, kDatePickControllerHeight);
        datePicker.date = _meetItem.startTime;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alert.view addSubview:datePicker];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"Select", @"Select") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)endTimeTapped
{
    if ([self canEditMeet] && self.meetItem.startTime == nil)
    {
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        datePicker.frame = CGRectMake(0, 0, self.view.frame.size.width - 10, kDatePickControllerHeight);
        datePicker.date = _meetItem.endTime;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alert.view addSubview:datePicker];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"Select", @"Select") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)inviteMembersTapped
{
    [[MCMessageCenterViewController sharedInstance] openInviteControllerWithHandleSelectedUsers:^(NSArray<MXUserItem *> *users) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)userInfoTapped:(MXUserItem *)user
{
    MCUserInfoViewController *userInfoVC = [[MCUserInfoViewController alloc] initWithUserItem:user userListModel:nil];
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

- (void)deleteMeetTapped
{
    @WEAKSELF;
    UIAlertController *deleteAlert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Do you want to delete this meet?", @"Do you want to delete this meet?") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", @"Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.meetListModel deleteMeet:weakSelf.meetItem withCompletionHandler:^(NSError * _Nullable errorOrNil) {
            [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
    }];
    [deleteAlert addAction:cancelAction];
    [deleteAlert addAction:confirmAction];
    [self presentViewController:deleteAlert animated:YES completion:nil];
}

#pragma mark - MoviePlayerNotification

- (void)finishedRecordPlay
{
    //Remove notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayerController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.moviePlayerController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:self.moviePlayerController];
    
    //Clear movie player
    if( self.moviePlayerController.isFullscreen )
        [self.moviePlayerController setFullscreen:NO animated:YES];
    
    [self.moviePlayerController.view removeFromSuperview];
    self.moviePlayerController = nil;
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    MPMoviePlayerController *player = notification.object;
    if (player == self.moviePlayerController)
    {
        NSNumber *reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
        switch ([reason integerValue])
        {
            case MPMovieFinishReasonPlaybackEnded:
            case MPMovieFinishReasonPlaybackError:
            case MPMovieFinishReasonUserExited:
                [self finishedRecordPlay];
            default:
                break;
        }
    }
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    MPMoviePlayerController *player = notification.object;
    if (player == self.moviePlayerController)
    {
        if (player.playbackState == MPMoviePlaybackStateStopped ||
            player.playbackState == MPMoviePlaybackStateInterrupted)
        {
            [self finishedRecordPlay];
        }
    }
}

- (void)didExitFullscreen:(NSNotification*)notification
{
    MPMoviePlayerController *player = notification.object;
    if (player == self.moviePlayerController)
    {
        [self finishedRecordPlay];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    @WEAKSELF;
    if (textField.tag == 999)
    {
        if (textField.text.length)
        {
            //Update Topic
            [self.meetItem updateTopic:textField.text withCompletionHandler:^(NSError * _Nullable error) {
                if (error)
                {
                    [self mc_simpleAlertError:error];
                }
                [weakSelf.view endEditing:YES];
            }];
        }
    }
    else
    {
        if (textField.text.length)
        {
            //Update Agenda
            [self.meetItem updateAgenda:textField.text withCompletionHandler:^(NSError * _Nullable error) {
                if (error)
                {
                    [self mc_simpleAlertError:error];
                }
                [weakSelf.view endEditing:YES];
            }];
        }
    }
    return YES;
}
@end
