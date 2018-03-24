//
//  MCMeetListViewController.m
//  MessageCenter
//
//  Created by Rookie on 30/11/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "MCMeetInfoViewController.h"
#import "MCMeetListViewController.h"
#import "MCMeetListSectionView.h"
#import "MCMeetListCell.h"

@interface MCMeetListSection : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation MCMeetListSection

- (instancetype)init
{
    if (self = [super init])
    {
        _data = [[NSMutableArray alloc] init];
    }
    return self;
}

@end

static NSString *const kMeetListCellIdentify = @"kMeetListCellIdentify";
static NSString *const kMeetSectionHeadReuseIdentifier = @"kMeetSectionHeadReuseIdentifier";

@interface MCMeetListViewController () <UITableViewDelegate, UITableViewDataSource,MXMeetListModelDelegate,SWTableViewCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UINavigationController *meetInfoNavigator;
@property (nonatomic, readwrite, strong)MPMoviePlayerController *moviePlayerController;

@property (nonatomic, strong) MXMeetListModel *meetListModel;
@property (nonatomic, strong) NSArray<MXMeet *> *meetList;
@property (nonatomic, strong) NSMutableDictionary *meetSectionMap;
@property (nonatomic, strong) NSMutableArray <MCMeetListSection *> *meetSections;

@end

@implementation MCMeetListViewController

#pragma mark - LifeCycle

- (instancetype)init
{
    if (self = [super init])
    {
        self.moviePlayerController = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Setup table view
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = MCColorBackground;
    self.tableView.estimatedRowHeight = 95;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[MCMeetListCell class] forCellReuseIdentifier:kMeetListCellIdentify];
    [self.tableView registerClass:[MCMeetListSectionView class] forHeaderFooterViewReuseIdentifier:kMeetSectionHeadReuseIdentifier];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Scroll tableView to the meeting which closest to current date
    if(self.meetSections.count)
    {
        NSUInteger lastSection = self.meetSections.count > 1 ? self.meetSections.count - 1 : 0;
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:lastSection] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
        [self.meetSections enumerateObjectsUsingBlock:^(MCMeetListSection *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([[NSCalendar currentCalendar] isDate:obj.date inSameDayAsDate:[NSDate date]])
            {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:idx] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
        }];
    }

}

#pragma mark - Getter

- (MXMeetListModel *)meetListModel
{
    if (_meetListModel == nil)
    {
        _meetListModel = [[MXMeetListModel alloc] init];
        _meetListModel.delegate = self;
    }
    return _meetListModel;
}

- (NSMutableDictionary *)meetSectionMap
{
    if (_meetSectionMap == nil)
    {
        _meetSectionMap = [[NSMutableDictionary alloc] init];
    }
    return _meetSectionMap;
}

- (UINavigationController *)meetInfoNavigator
{
    if (_meetInfoNavigator == nil)
    {
        _meetInfoNavigator = [[UINavigationController alloc] init];
        _meetInfoNavigator.navigationBar.barStyle = UIBarStyleBlack;
        _meetInfoNavigator.navigationBar.barTintColor = MCColorMain;
        _meetInfoNavigator.navigationBar.tintColor = [UIColor whiteColor];
        _meetInfoNavigator.navigationBar.translucent = NO;
        [_meetInfoNavigator.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:18.0f]}];
    }
    return _meetInfoNavigator;
}

#pragma mark - Public Method

- (void)loadMeetList
{
    [self clearMeetList];
    self.meetList = self.meetListModel.meets;
    self.meetSectionMap = nil;
    self.meetSections = [[self getMeetSectionsWithMeets:self.meetList] mutableCopy];
    [self.tableView reloadData];
}

- (void)clearMeetList
{
    self.meetListModel = nil;
    self.meetSections = nil;
    self.meetSectionMap = nil;
    [self.tableView setContentOffset:CGPointZero];
    [self.tableView reloadData];
}


#pragma mark - Private Methods

- (NSArray <MCMeetListSection *> *)getMeetSectionsWithMeets:(NSArray <MXMeet *>* )meets
{
    @WEAKSELF;
    //Seperate meets data to different section according date.
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    [meets enumerateObjectsUsingBlock:^(MXMeet *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *meetStartDate = nil;
        if ([weakSelf isUpcomingMeet:obj now:[NSDate new]])
        {
            meetStartDate = obj.scheduledStartTime;
        }
        else
        {
            meetStartDate = obj.startTime;
        }
        if (meetStartDate)
        {
            NSDateComponents *dateComponents = [currentCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:meetStartDate];
            NSDate *sectionDate = [currentCalendar dateFromComponents:dateComponents];
            MCMeetListSection *targetSection;
            if ([self.meetSectionMap objectForKey:sectionDate])
            {
                targetSection = [self.meetSectionMap objectForKey:sectionDate];
            }
            else
            {
                targetSection = [[MCMeetListSection alloc] init];
                targetSection.date = sectionDate;
                [self.meetSectionMap setObject:targetSection forKey:sectionDate];
            }
            [targetSection.data addObject:obj];
        }
    }];
    return [self.meetSectionMap.allValues sortedArrayUsingComparator:^NSComparisonResult(MCMeetListSection *obj1, MCMeetListSection *obj2) {
        return [obj1.date compare:obj2.date];
    }];
}

- (BOOL)isUpcomingMeet:(MXMeet *)meet now:(NSDate *)now {
    return ([meet.scheduledEndTime compare:now] == NSOrderedDescending) || meet.isInProgress;
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.meetSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.meetSections[section].data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCMeetListCell *cell = [tableView dequeueReusableCellWithIdentifier:kMeetListCellIdentify];
    NSArray *meets = self.meetSections[indexPath.section].data;
    MXMeet *meetItem = [meets objectAtIndex:indexPath.row];
    cell.meetItem = meetItem;
    cell.delegate = self;
    
    //Set cell‘s action block
    @WEAK_OBJ(cell);
    @WEAKSELF;
    cell.handleStartOrJoinMeet = ^(BOOL start, id sender)
    {
        if([cellWeak isUtilityButtonsHidden] == NO)
        {
            [cellWeak hideUtilityButtonsAnimated:YES];
            return;
        }
        MCMessageCenterViewController *messageCenterVC = [MCMessageCenterViewController sharedInstance];
        [weakSelf.view.window mc_startIndicatorViewAnimating];
        if (start)
        {
            [self.meetListModel startMeetWithMeetId:cellWeak.meetItem.meetId completionHandler:^(NSError * _Nullable error, MXMeetSession * _Nullable meetSession) {
                [weakSelf.view.window mc_stopIndicatorViewAnimating];
                
                if (error)
                {
                    [messageCenterVC mc_simpleAlertError:error];
                }
                
                if (meetSession)
                {
                    [meetSession presentMeetWindow];
                }
            }];
        }
        else
        {
            [self.meetListModel joinMeetWithMeetId:cellWeak.meetItem.meetId completionHandler:^(NSError * _Nullable error, MXMeetSession * _Nullable meetSession) {
                [weakSelf.view.window mc_stopIndicatorViewAnimating];
                
                if (error)
                {
                    [messageCenterVC mc_simpleAlertError:error];
                }
                
                if (meetSession)
                {
                    [meetSession presentMeetWindow];
                }
            }];
        }
    };
    
    cell.handlePlayButtonTapped = ^(UIButton *sender) {
        if([cellWeak isUtilityButtonsHidden] == NO)
        {
            [cellWeak hideUtilityButtonsAnimated:YES];
            return;
        }
        
        MXMeet *meetItem = cellWeak.meetItem;
        NSURL *movieURL = meetItem.recordingUrl;
        if(movieURL == nil)
            return ;
        
        weakSelf.moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
        weakSelf.moviePlayerController.allowsAirPlay = YES;
        weakSelf.moviePlayerController.contentURL = movieURL;
        weakSelf.moviePlayerController.movieSourceType = movieURL.isFileURL ? MPMovieSourceTypeFile : MPMovieSourceTypeUnknown;
        weakSelf.moviePlayerController.view.backgroundColor = [UIColor clearColor];
        weakSelf.moviePlayerController.view.frame = cellWeak.bounds;
        [cellWeak addSubview:weakSelf.moviePlayerController.view];
        
        [[NSNotificationCenter defaultCenter] addObserver:weakSelf
                                                 selector:@selector(moviePlayBackDidFinish:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:weakSelf.moviePlayerController];
        [[NSNotificationCenter defaultCenter] addObserver:weakSelf
                                                 selector:@selector(moviePlayBackStateDidChange:)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                   object:weakSelf.moviePlayerController];
        [[NSNotificationCenter defaultCenter] addObserver:weakSelf
                                                 selector:@selector(didExitFullscreen:)
                                                     name:MPMoviePlayerDidExitFullscreenNotification
                                                   object:weakSelf.moviePlayerController];
        
        [weakSelf.moviePlayerController setShouldAutoplay:NO];
        [weakSelf.moviePlayerController play];
        [weakSelf.moviePlayerController setFullscreen:YES animated:YES];

    };
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    MCMeetListSectionView *headView = (MCMeetListSectionView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:kMeetSectionHeadReuseIdentifier];
    headView.sectionDate = self.meetSections[section].date;
    if ([[NSCalendar currentCalendar] isDate:self.meetSections[section].date inSameDayAsDate:[NSDate date]])
    {
        
        headView.isToday = YES;
        NSArray *meets = self.meetSections[section].data;
        headView.hasMeeting = meets.count;
    }
    return headView;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 28.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MXMeet *meetItem = self.meetSections[indexPath.section].data[indexPath.row];
    if (meetItem == nil)
    {
        return 0.0f;
    }
    if (meetItem.recordingUrl != nil)
    {
        return 140.0f;
    }
    else
    {
        return 105.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    MXMeet *meet = self.meetSections[indexPath.section].data[indexPath.row];
    if (!meet)
    {
        return;
    }
    
//    //Present meet info viewcontroller
//    MXMeetInfoViewController *meetInfoVC = [[MXMeetInfoViewController alloc] initWithMeetItem:meet];
//    self.meetInfoNavigator.viewControllers = @[meetInfoVC];
//    meetInfoVC.title = NSLocalizedString(@"Meeting Info", @"Meeting Info");
//    meetInfoVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Close") style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonTapped:)];
//    [self presentViewController:self.meetInfoNavigator animated:YES completion:nil];
    
    
    MCMeetInfoViewController *meetInfoVC = [[MCMeetInfoViewController alloc] initWithMeetItem:meet meetListModel:self.meetListModel];
    self.meetInfoNavigator.viewControllers = @[meetInfoVC];
    meetInfoVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Close") style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonTapped:)];
    [self presentViewController:self.meetInfoNavigator animated:YES completion:nil];
}

#pragma mark - MXMeetListModelDelegate

- (void)meetListModel:(MXMeetListModel *)meetListModel didCreateMeets:(NSArray<MXMeet *> *)createdMeets
{
    //Find added meets then add them to meet section.
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSMutableArray *willAddedIndex = [[NSMutableArray alloc] init];
    NSMutableIndexSet *willAddedSection = [[NSMutableIndexSet alloc] init];

    for (MXMeet *meet in createdMeets)
    {
        if (meet.startTime)
        {
            NSDateComponents *dateComponents = [currentCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:meet.startTime];
            NSDate *sectionDate = [currentCalendar dateFromComponents:dateComponents];
            MCMeetListSection *targetSection;
            NSIndexPath *updateIndex;
            if ([self.meetSectionMap objectForKey:sectionDate])
            {
                targetSection = [self.meetSectionMap objectForKey:sectionDate];
                [targetSection.data binaryInsertObjects:@[meet] withComparator:^NSComparisonResult(MXMeet *obj1, MXMeet *obj2) {
                    return [obj1.startTime compare:obj2.startTime];
                }];
                updateIndex = [NSIndexPath indexPathForRow:[targetSection.data indexOfObject:meet] inSection:[self.meetSections indexOfObject:targetSection]];
            }
            else
            {
                targetSection = [[MCMeetListSection alloc] init];
                targetSection.date = sectionDate;
                [self.meetSectionMap setObject:targetSection forKey:sectionDate];
                [self.meetSections binaryInsertObjects:@[targetSection] withComparator:^NSComparisonResult(MCMeetListSection *obj1,MCMeetListSection * obj2) {
                    return [obj1.date compare:obj2.date];
                }];
                [targetSection.data addObject:meet];
                updateIndex = [NSIndexPath indexPathForRow:[targetSection.data indexOfObject:meet] inSection:[self.meetSections indexOfObject:targetSection]];
                [willAddedSection addIndex:updateIndex.section];
            }
            [willAddedIndex addObject:updateIndex];
        }
    }
    [self.tableView beginUpdates];
    [self.tableView insertSections:willAddedSection withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView insertRowsAtIndexPaths:willAddedIndex withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
}

- (void)meetListModel:(MXMeetListModel *)meetListModel didUpdateMeets:(NSArray<MXMeet *> *)updatedMeets
{
    //Find deleted meets in meet sections then update it.
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSMutableArray *willUpdatedIndex = [[NSMutableArray alloc] init];
    for (MXMeet *meet in updatedMeets)
    {
        NSDateComponents *dateComponents = [currentCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:meet.startTime];
        NSDate *sectionDate = [currentCalendar dateFromComponents:dateComponents];
        MCMeetListSection *targetSection;
        if ([self.meetSectionMap objectForKey:sectionDate])
        {
            targetSection = [self.meetSectionMap objectForKey:sectionDate];
            NSIndexPath *updateIndex = [NSIndexPath indexPathForRow:[targetSection.data indexOfObject:meet] inSection:[self.meetSections indexOfObject:targetSection]];
            [willUpdatedIndex addObject:updateIndex];
        }
    }
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:willUpdatedIndex withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
}

- (void)meetListModel:(MXMeetListModel *)meetListModel didDeleteMeets:(NSArray<MXMeet *> *)deletedMeets
{
    //Pop over the MeetInfoViewController when it's meet get deleted
    MXMeet *selectedMeet;
    if (self.tableView.indexPathForSelectedRow)
    {
        NSIndexPath *selectedPath = self.tableView.indexPathForSelectedRow;
        selectedMeet = self.meetSections[selectedPath.section].data[selectedPath.row];
    }

    //Find deleted meets in meet sections then delete it.
    NSMutableArray *meetList = [NSMutableArray arrayWithArray:self.meetList];
    [meetList removeObjectsInArray:deletedMeets];
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSMutableArray *willRemovedIndexs = [[NSMutableArray alloc] init];
    NSMutableIndexSet *willRemovedSections = [[NSMutableIndexSet alloc] init];
    for (MXMeet *meet in deletedMeets)
    {
        if ([meet isEqual:selectedMeet])
        {
            if (self.meetInfoNavigator.viewControllers.count)
            {
                [self closeButtonTapped:nil];
                [self mc_simpleAlertWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"The meet just has just be deleted", @"The meet just has just be deleted")];
            }
        }
        NSDateComponents *dateComponents = [currentCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:meet.startTime];
        NSDate *sectionDate = [currentCalendar dateFromComponents:dateComponents];
        MCMeetListSection *targetSection;
        if ([self.meetSectionMap objectForKey:sectionDate])
        {
            targetSection = [self.meetSectionMap objectForKey:sectionDate];
            if (![targetSection.data containsObject:meet])
            {
                return;
            }
            NSIndexPath *removeIndex = [NSIndexPath indexPathForRow:[targetSection.data indexOfObject:meet] inSection:[self.meetSections indexOfObject:targetSection]];
            [targetSection.data removeObject:meet];
            if (targetSection.data.count == 0)
            {
                [willRemovedSections addIndex:[self.meetSections indexOfObject:targetSection]];

                [self.meetSectionMap removeObjectForKey:sectionDate];
                [self.meetSections removeObject:targetSection];
            }
            [willRemovedIndexs addObject:removeIndex];
        }
    }
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:willRemovedIndexs withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView deleteSections:willRemovedSections withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
}

#pragma mark - SWTableViewCellDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    MXMeet *meetItem = ((MCMeetListCell *)cell).meetItem;
    [self.view.window mc_startIndicatorViewAnimating];
    [self.meetListModel deleteMeet:meetItem withCompletionHandler:^(NSError * _Nullable errorOrNil) {
        [self.view.window mc_stopIndicatorViewAnimating];
        if (errorOrNil)
        {
            [self mc_simpleAlertError:errorOrNil];
        }
    }];
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state;
{
    MXMeet *meetItem = ((MCMeetListCell *)cell).meetItem;
    if (!meetItem)
    {
        return NO;
    }
    
    MXUserItem *me = [MXChatClient sharedInstance].currentUser;
    return [meetItem.host isEqual:me];
}

#pragma mark - WidgetsActions

- (void)closeButtonTapped:(UIBarButtonItem *)sender
{
    [self.meetInfoNavigator dismissViewControllerAnimated:YES completion:nil];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

@end
