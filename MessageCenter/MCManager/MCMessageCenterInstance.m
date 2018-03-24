//
//  MCMessageCenterInstance.m
//  DigiBank
//
//  Created by Moxtra on 2017/3/21.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCMessageCenterInstance.h"

NSString * const MCMessageCenterUserDidLoginNotification = @"MCMessageCenterUserDidLoginNotification";
NSString * const MCMessageCenterUserDidLogoutNotification = @"MCMessageCenterUserDidLogoutNotification";

#ifndef MCMoxtraAccountKey
    #define MCMoxtraAccountKey  @"MCMoxtraAccountKey"
    #define MCMoxtraAccountUniqueIdKey @"MCMoxtraAccountUniqueIdKey"
    #define MCMoxtraAccountOrgIdKey @"MCMoxtraAccountOrdIdKey"
#endif

//Default account's info
static NSString *const kMCDefaultUniqueID = @"INSERT-UNIQUEID";
static NSString *const kMCDefaultOrgID = @"INSERT-ORGID";

static NSString *const kUploadImageDir = @"UploadCover";

@interface MCMessageCenterInstance()<MXChatClientDelegate>
{
    struct {
        unsigned int didClientLogout : 1;
    }_delegateFlag;
}

/**
 Storage of loaded round avatar or chat cover
 */
@property (nonatomic, strong) NSCache *avatarCache;

@property (nonatomic, strong) dispatch_queue_t avatarQueue;

@property (nonatomic, copy) void(^loginCompletionHandler)(NSError *  errorOrNil);

@end

@implementation MCMessageCenterInstance

#pragma mark - LifeCycle & Singleton

+ (instancetype)sharedInstance
{
    static MCMessageCenterInstance *_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[MCMessageCenterInstance alloc] init];
        _manager.chatClient = [MXChatClient sharedInstance];
        [MXChatClient sharedInstance].delegate = _manager;
        _manager.chatListModel = [[MXChatListModel alloc] init];
        _manager.meetListModel = [[MXMeetListModel alloc] init];
    });
    return _manager;
}

#pragma mark - Setter

- (void)setDelegate:(id<MCMessageCenterInstanceDelegate>)delegate
{
    _delegate = delegate;
    
    //Config delegate flag
    if ([_delegate respondsToSelector:@selector(instanceDidLogout:)])
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

- (BOOL)online
{
    return self.chatClient.currentUser.uniqueId != nil;
}

- (NSCache *)avatarCache
{
    if (_avatarCache == nil)
    {
        _avatarCache = [[NSCache alloc] init];
        _avatarCache.countLimit = 100;
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
    [[MXChatClient sharedInstance] linkWithUniqueId:uniqueId orgId:orgId clientId:kClientId clientSecret:kClientSecret baseDomain:kBaseDomain completionHandler:^(NSError * _Nullable error) {
        if (error)
        {
            //Clear userDefaults
            [weakSelf saveAccountWithUniqueID:nil orgId:nil];
            [[UIApplication sharedApplication].keyWindow.mc_frontMostViewController mc_simpleAlertError:error];
        }
        else
        {
            weakSelf.chatClient.chatSessionConfig.locationEnabled = YES;
            weakSelf.chatClient.chatSessionConfig.inputPanelLayout = MXChatInputPanelLayoutDefault;
            weakSelf.chatClient.chatSessionConfig.emojiEnabled = YES;
            weakSelf.chatClient.chatSessionConfig.readReceiptEnabled = YES;
            self.chatClient.chatSessionConfig.didTapShareButton = ^(MXChat * _Nonnull chat, UIViewController * _Nonnull viewController, id  _Nonnull sender, NSURL * _Nonnull shareLink, NSURL * _Nonnull downloadLink) {
                //Do what you want
            };
            
            self.chatClient.chatSessionConfig.didTapMemberAvatar = ^(MXChat * _Nonnull chat, UIViewController * _Nonnull viewController, id  _Nonnull sender, MXUserItem * _Nonnull userItem) {
                //Do want you want
            };
            
            self.chatClient.chatSessionConfig.didTapMoreFilesButton = ^(MXChat * _Nonnull chat, UIViewController * _Nonnull viewController, id  _Nonnull sender) {
                //Do want you want
            };
            UIImage *imag1 = [UIImage imageNamed:@"checked_button"];
            MXAddFileEntry *entrance1 = [MXAddFileEntry entryWithTitle:@"kkk" iconImage:nil onClicked:^(MXChat * _Nonnull chat, UIViewController * _Nonnull viewController, id  _Nonnull sender) {
                NSLog(@"%@:%@:%@",chat,viewController,sender);
            }];
            MXAddFileEntry *entrance2 = [MXAddFileEntry entryWithTitle:nil iconImage:imag1 onClicked:nil];
            self.chatClient.chatSessionConfig.extraAddFileEntries = @[entrance1, entrance2];
//
//            [self.chatClient.chatSessionConfig addMenuWithTitle:@"KKK"
//                                                      imageName:@"checked_button"
//                                            handleItemOnClicked:^(UIViewController * _Nonnull viewController) {
//               NSLog(@"kkk");
//            }];
//            
//            [self.chatClient.chatSessionConfig addMenuWithTitle:@"sss"
//                                                      imageName:@"checked_button"
//                                            handleItemOnClicked:^(UIViewController * _Nonnull viewController) {
//                NSLog(@"sss");
//            }];
            
            self.chatClient.meetSessionConfig.VoIPEnabled = YES;
            
            
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
    [self saveAccountWithUniqueID:@"" orgId:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:MCMessageCenterUserDidLogoutNotification object:self.chatClient];
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

- (void)getChatCoverWithChatItem:(MXChat *)chat completionHandler:(void (^)(UIImage *, NSError *))completion
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
            return;
        }
        else if (localPathOrNil)
        {
            result = [UIImage imageWithContentsOfFile:localPathOrNil];
            [weakSelf cacheImage:result withKey:key path:localPathOrNil completion:^(UIImage *image) {
                completion(image,errorOrNil);
            }];
        }
        else
        {
            completion(nil,errorOrNil);
        }
    }];
}

- (void)writeToDiskWithImage:(UIImage *)image completeHandler:(void(^)(NSString *imagePath, NSError *error))handler;
{    
    NSString *directoryPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"UploadCover"];
    NSString *imagePath = [directoryPath stringByAppendingPathComponent:[[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] stringByAppendingPathExtension:@"png"]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath])
    {
        //Create directory
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:&error];
        if (error)
        {
            if (handler)
            {
                handler(nil, error);
            }
        }
    }

    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:imagePath atomically:YES];
    if (handler)
    {
        handler(imagePath, nil);
    }
}

- (void)clearDiskUploadImage
{
    NSString *directoryPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"UploadCover"];
    [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
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
    
    NSString *key = [NSString stringWithFormat:@"orgId:%@xuniqueID:%@", user.orgId, user.uniqueId];
    [user fetchAvatarWithCompletionHandler:^(NSError * _Nullable errorOrNil, NSString * _Nullable localPathOrNil) {
        //Get cache
        UIImage *result = [weakSelf handleGetImageCompletion:errorOrNil localPath:localPathOrNil key:key];
        if (result)
        {
            completion(result,errorOrNil);
            return;
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
        UIImage *avatar = [self.avatarCache objectForKey:key];
        if (avatar)
        {
            return avatar;
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
    @WEAKSELF;
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
        });
        if (roundedAvatar)
        {
            [weakSelf.avatarCache setObject:roundedAvatar forKey:key];
        }
    });
}

- (void)cacheImage:(UIImage *)image withKey:(NSString *)key path:(NSString *)path completion:(void(^)(UIImage *image))handler;
{
    @WEAKSELF;
    dispatch_async(self.avatarQueue, ^{
        CGSize itemSize = CGSizeMake(40, 40);
        UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [image drawInRect:imageRect];
        UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(result);
        });
        if (result)
        {
            [weakSelf.avatarCache setObject:result forKey:key];
        }
    });
}

#pragma mark - MXChatClientDelegate

- (void)chatClientDidUnlink:(MXChatClient *)chatClient
{
    if (_delegateFlag.didClientLogout)
    {
        [self.delegate instanceDidLogout:self];
    }
}

@end
