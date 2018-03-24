//
//  MCManager.m
//  DigiBank
//
//  Created by Moxtra on 2017/3/21.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCManager.h"

NSString * const MCMessageCenterUserDidLoginNotification = @"MCMessageCenterUserDidLoginNotification";
NSString * const MCMessageCenterUserDidLogoutNotification = @"MCMessageCenterUserDidLogoutNotification";

#ifndef MCMoxtraAccountKey
    #define MCMoxtraAccountKey  @"MCMoxtraAccountKey"
    #define MCMoxtraAccountUniqueIdKey @"MCMoxtraAccountUniqueIdKey"
    #define MCMoxtraAccountOrgIdKey @"MCMoxtraAccountOrdIdKey"
#endif

//Default account's info
static NSString *const kMCDefaultUniqueID = @"mc_jacob";
static NSString *const kMCDefaultOrgID = @"PP2iXx2qi4f46aic2WD01Y7";

@interface MCManager()<MXChatClientDelegate>
{
    struct {
        unsigned int didClientLogout : 1;
    }_delegateFlag;
}

/**
 Storage of loaded avatar's url
 */
@property (nonatomic, strong) NSMutableDictionary *avatarMap;

/**
 Storage of loaded round avatar
 */
@property (nonatomic, strong) NSMutableDictionary *avatarCache;

@property (nonatomic, strong) dispatch_queue_t avatarQueue;

@property (nonatomic, copy) void(^loginCompletionHandler)(NSError *  errorOrNil);

@end

@implementation MCManager

#pragma mark - LifeCycle & Singleton

+ (instancetype)sharedManager
{
    static MCManager *_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[MCManager alloc] init];
        _manager.chatClient = [MXChatClient sharedInstance];
        [MXChatClient sharedInstance].delegate = _manager;
        _manager.chatListModel = [[MXChatListModel alloc] init];
        _manager.meetListModel = [[MXMeetListModel alloc] init];
        _manager.callListModel = [[MXCallListModel alloc] init];
    });
    return _manager;
}

#pragma mark - Setter

- (void)setDelegate:(id<MCManagerDelegate>)delegate
{
    _delegate = delegate;
    
    //Config delegate flag
    if ([_delegate respondsToSelector:@selector(managerDidLogout:)])
    {
        _delegateFlag.didClientLogout = YES;
    }
}

#pragma mark - Getter

- (MXChatListModel *)chatListModel
{
    if (_chatListModel == nil)
    {
        _chatListModel = [[MXChatListModel alloc] init];
    }
    return _chatListModel;
}

- (MXMeetListModel *)meetListModel
{
    if (_meetListModel == nil)
    {
        _meetListModel = [[MXMeetListModel alloc] init];
    }
    return _meetListModel;
}

- (MXCallListModel *)callListModel
{
    if (_callListModel == nil)
    {
        _callListModel = [[MXCallListModel alloc] init];
    }
    return _callListModel;
}

- (BOOL)online
{
    return self.chatClient.currentUser.uniqueId != nil;
}

- (NSMutableDictionary *)avatarMap
{
    if (_avatarMap == nil)
    {
        _avatarMap = [[NSMutableDictionary alloc] init];
    }
    return _avatarMap;
}

- (NSMutableDictionary *)avatarCache
{
    if (_avatarCache == nil)
    {
        _avatarCache = [[NSMutableDictionary alloc] init];
    }
    return _avatarCache;
}

- (dispatch_queue_t)avatarQueue
{
    if (_avatarQueue == nil)
    {
        _avatarQueue = dispatch_queue_create("avatarQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(_avatarQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    }
    return _avatarQueue;
}

#pragma mark - Private Method

- (void)saveAccountWithUniqueID:(NSString *)uniqueId orgId:(NSString *)orgId
{
    if (uniqueId.length == 0)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:MCMoxtraAccountKey];
    }
    else
    {
        NSDictionary *dictionary = nil;
        if (orgId.length > 0)
        {
            dictionary = @{MCMoxtraAccountUniqueIdKey : uniqueId, MCMoxtraAccountOrgIdKey : orgId};
        }
        else
        {
            dictionary = @{MCMoxtraAccountUniqueIdKey : uniqueId};
        }
        [[NSUserDefaults standardUserDefaults] setObject:dictionary forKey:MCMoxtraAccountKey];
    }
}

- (void)chatClientLoginWithUniqueId:(NSString *)uniqueId orgId:(NSString *)orgId
{
    [[UIApplication sharedApplication].keyWindow mc_startIndicatorViewAnimating];
    __weak typeof(self) weakSelf = self;
    //Start login in ChatSDK
    [[MXChatClient sharedInstance] linkWithUniqueID:uniqueId orgID:orgId clientID:kClientId clientSecret:kClientSecret baseDomain:kBaseDomain completionHandler:^(NSError * _Nullable error) {
        if (error)
        {
            //Clear userDefaults
            [weakSelf saveAccountWithUniqueID:nil orgId:nil];
            [[UIApplication sharedApplication].keyWindow.mc_frontMostViewController mc_simpleAlertError:error];
        }
        else
        {
            weakSelf.chatClient.chatSessionConfig.multiTabsEnabled = NO;
            weakSelf.chatClient.delegate = weakSelf;
            //Save account
            [weakSelf saveAccountWithUniqueID:uniqueId orgId:orgId];
            //Notify
            [[NSNotificationCenter defaultCenter] postNotificationName:MCMessageCenterUserDidLoginNotification object:weakSelf.chatClient];
        }
        if (weakSelf.loginCompletionHandler)
        {
            weakSelf.loginCompletionHandler(error);
        }
        [[UIApplication sharedApplication].keyWindow mc_stopIndicatorViewAnimating];
    }];
}

- (void)configAlertControllerAndPresent
{
    __weak typeof(self) weakSelf = self;
    //Use a default account in DEBUG mode.
    UIAlertController *loginAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Login", @"login") message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [loginAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Unique ID";
        
#ifdef DEBUG
        textField.text = kMCDefaultUniqueID;
#endif
        
    }];
    [loginAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Org ID";
#ifdef DEBUG
        textField.text = kMCDefaultOrgID;
#endif
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *uniqueID = loginAlert.textFields.firstObject.text;
        NSString *orgID = loginAlert.textFields.lastObject.text.length > 0 ? loginAlert.textFields.lastObject.text : kOrgId;
        //Start login
        [weakSelf chatClientLoginWithUniqueId:uniqueID orgId:orgID];
    }];
    [loginAlert addAction:okAction];
    
    //Present alert
    [[[[UIApplication sharedApplication].windows firstObject] rootViewController] presentViewController:loginAlert animated:YES completion:nil];
}

#pragma mark - Public Method

- (void)loginWithCompletionHandler:(void (^)(NSError *  errorOrNil))completion
{
    __weak typeof(self) weakSelf = self;
    self.loginCompletionHandler = completion;
#warning In iOS10, system will clear Userdefaults sometimes.
    //Fetch account info from user default.
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:MCMoxtraAccountKey];
    NSString *uniqueId = [userInfo objectForKey:MCMoxtraAccountUniqueIdKey];
    NSString *orgId = [userInfo objectForKey:MCMoxtraAccountOrgIdKey];
    
    if( uniqueId.length == 0 )
    {
        //Provide a default account or a custom one to login
        [weakSelf configAlertControllerAndPresent];
    }
    else
    {
        //Do login
        [weakSelf chatClientLoginWithUniqueId:uniqueId orgId:orgId];
    }
}

- (void)logout
{
    [self.chatClient unlink];
    self.chatListModel = nil;
    self.meetListModel = nil;
    self.callListModel = nil;
    [self saveAccountWithUniqueID:@"" orgId:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:MCMessageCenterUserDidLogoutNotification object:self.chatClient];
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

- (void)getChatCoverWithChatItem:(MXChatItem *)chat completionHandler:(void (^)(UIImage *, NSError *))completion
{
    __weak typeof(self) weakSelf = self;
    NSParameterAssert(chat);
    NSString *key = [NSString stringWithFormat:@"chatId:%@", chat.chatId];
    [chat fetchCoverWithCompletionHandler:^(NSError * _Nullable errorOrNil, NSString * _Nullable localPathOrNil) {
        //Get cache
        UIImage *result = [weakSelf handleGetImageCompletion:errorOrNil localPath:localPathOrNil key:key];
        if (result)
        {
            completion(result,errorOrNil);
        }
        else if (localPathOrNil)
        {
            result = [UIImage imageWithContentsOfFile:localPathOrNil];
            [weakSelf cacheRoundImage:result withKey:key path:localPathOrNil completion:^(UIImage *image) {
                completion(image,errorOrNil);
            }];
        }
        else
        {
            completion(nil,errorOrNil);
        }
    }];
}

- (void)getRoundedAvatarWithUser:(MXUserItem *)user completionHandler:(void (^)(UIImage *, NSError *))completion
{
    __weak typeof(self) weakSelf = self;
    NSParameterAssert(user);
    if (!user) {
        NSError *error = [NSError errorWithDomain:@"message center domain" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"No user was specified"}];
        completion(nil, error);
        return;
    }
    
    NSString *key = [NSString stringWithFormat:@"orgId:%@ uniqueID:%@", user.orgId, user.uniqueId];
    [user fetchAvatarWithCompletionHandler:^(NSError * _Nullable errorOrNil, NSString * _Nullable localPathOrNil) {
        //Get cache
        UIImage *result = [weakSelf handleGetImageCompletion:errorOrNil localPath:localPathOrNil key:key];
        if (result)
        {
            completion(result,errorOrNil);
        }
        else if (localPathOrNil)
        {
            result = [UIImage imageWithContentsOfFile:localPathOrNil];
            [weakSelf cacheRoundImage:result withKey:key path:localPathOrNil completion:^(UIImage *image) {
                completion(image,errorOrNil);
            }];
        }
        else
        {
            completion(nil,errorOrNil);
        }
    }];
}

#pragma mark - Image Cache

- (UIImage *)handleGetImageCompletion:(NSError *)error localPath:(NSString *)path key:(NSString *)key;
{
    if (error)
    {
        return nil;
    }
    else if (path.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil])
    {
        
        //Get cache
        if ([path isEqualToString:[self.avatarMap objectForKey:key]])
        {
            UIImage *avatar = [self.avatarCache objectForKey:key];
            
            if (avatar)
            {
                return avatar;
            }
        }
        return nil;
    }
    else
    {
        return nil;
    }
}

- (void)cacheRoundImage:(UIImage *)image withKey:(NSString *)key path:(NSString *)path completion:(void(^)(UIImage *image))handler;
{
    dispatch_async(self.avatarQueue, ^{
        UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGRect rect = {CGPointMake(0, 0), image.size};
        CGContextAddRect(context, rect);
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
        CGContextFillPath(context);
        CGContextAddEllipseInRect(context, rect);
        CGContextClip(context);
        [image drawInRect:rect];
        UIImage *roundedAvatar = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(roundedAvatar);
            [self.avatarMap setObject:path forKey:key];
            if (roundedAvatar)
            {
                [self.avatarCache setObject:roundedAvatar forKey:key];
            }
        });
    });
}

#pragma mark - MXChatClientDelegate

- (void)chatClientDidUnlink:(MXChatClient *)chatClient
{
    if (_delegateFlag.didClientLogout)
    {
        [self.delegate managerDidLogout:self];
    }
}

@end
