//
//  MCManager.h
//  DigiBank
//
//  Created by Moxtra on 2017/3/21.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ChatSDK/MXChatSDK.h>

@protocol MCManagerDelegate;

/** Login & logout notification name */
FOUNDATION_EXTERN NSString * const MCMessageCenterUserDidLoginNotification;
FOUNDATION_EXTERN NSString * const MCMessageCenterUserDidLogoutNotification;

/**
 MXModelHelper,use to manage MXChatClient、MXChatListModel、MXMeetListModel.etc instance.
 @discuss In a overall view of an App,instances like MXChatClient、MXChatListModel.etc should be mananged globally,
 so in order to handle these situations. MXModelHelper is designed to facilitate the management and callback processing of these instance objects.
 */
@interface MCManager : NSObject<MXChatClientDelegate>

/**
 The MXChatClient class provides interfaces for user authentication.
 A MXChatClient object maintains the linked user profile represented by a MXUserItem object as well as configuration objects that define chat and meet session behaviours.
 */
@property (nonatomic, strong) MXChatClient *chatClient;

/**
 The MXChatListModel class provides interfaces for creating, deleting, accepting and declining chats. It also maintains all the chats object related with current user.
 */
@property (nonatomic, strong) MXChatListModel *chatListModel;

/**
 The MXMeetListModel class provides interfaces for creating, deleting, accepting and declining meets. It also maintains all the meets object related with current user.
 */
@property (nonatomic, strong) MXMeetListModel *meetListModel;

/**
 The MXCallListModelDelegate protocol defines the methods that MXCallListModel objects call on their delegates to handle call list events.
 */
@property (nonatomic, strong) MXCallListModel *callListModel;

@property (nonatomic, weak) id<MCManagerDelegate> delegate;

/**
 Use to flag current user's online status.
 */
@property (nonatomic, assign) BOOL online;

/**
 Return a global instance of MCManager.
 */
+ (instancetype)sharedManager;

/**
 Use default user account to do login.

 @param completion A block object to be executed when the action completes.The block has no return value, and takes two arguments: the chat client, and error.
 */
- (void)loginWithCompletionHandler:(void(^)(NSError *error))completion;

/**
 Logout
 */
- (void)logout;

/**
 Get a user's round avatar

 @param user The user
 @param completion A block object to be executed when the action completes.The block has no return value, and takes two arguments: the round avatar, and error.
 */
- (void)getRoundedAvatarWithUser:(MXUserItem *)user completionHandler:(void (^)(UIImage *avatar, NSError *error))completion;

/**
 Get a chat's cover

 @param chat The chat
 @param completion A block object to be executed when the action completes.The block has no return value, and takes two arguments: the image, and error.
 */
- (void)getChatCoverWithChatItem:(MXChatItem *)chat completionHandler:(void (^)(UIImage *image, NSError *error))completion;

@end

@protocol MCManagerDelegate <NSObject>

@optional

/**
 Get called when the user logged out

 @param manager MCManager
 */
- (void)managerDidLogout:(MCManager *)manager;

@end
