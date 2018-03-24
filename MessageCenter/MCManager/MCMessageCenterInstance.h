//
//  MCMessageCenterInstance.h
//  DigiBank
//
//  Created by Moxtra on 2017/3/21.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ChatSDK/MXChatSDK.h>

@protocol MCMessageCenterInstanceDelegate;

/** Login & logout notification name */
FOUNDATION_EXTERN NSString * const MCMessageCenterUserDidLoginNotification;
FOUNDATION_EXTERN NSString * const MCMessageCenterUserDidLogoutNotification;

/**
 MCMessageCenterInstance,use to manage MXChatClient、MXChatListModel、MXMeetListModel.etc instance.
 @discuss In a overall view of an App,instances like MXChatClient、MXChatListModel.etc should be mananged globally,
 so in order to handle these situations. MXModelHelper is designed to facilitate the management and callback processing of these instance objects.
 */
@interface MCMessageCenterInstance : NSObject<MXChatClientDelegate>

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

@property (nonatomic, weak) id<MCMessageCenterInstanceDelegate> delegate;

/**
 Use to flag current user's online status.
 */
@property (nonatomic, assign) BOOL online;

/**
 Return a global instance of MCMessageCenterInstance.
 */
+ (instancetype)sharedInstance;

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
- (void)getChatCoverWithChatItem:(MXChat *)chat completionHandler:(void (^)(UIImage *image, NSError *error))completion;

/**
 Write an image to disk,using when need to upload an UIImage. Default is wrote to Library/Caches/UploadCover directory.

 @param image The image
 @param handler A block object excuted when completed write image to disk, it has two arguments, the image's file path and error
 */
- (void)writeToDiskWithImage:(UIImage *)image completeHandler:(void(^)(NSString *imagePath, NSError *error))handler;

/**
 Clear the uploaded image in directory Library/Caches/UploadCover.
 */
- (void)clearDiskUploadImage;

@end

/*
 A protocol for delegates of MCMessageCenterInstance
 */
@protocol MCMessageCenterInstanceDelegate <NSObject>

@optional

/**
 Get called when the user logged out

 @param instance MCMessageCenterInstance
 */
- (void)instanceDidLogout:(MCMessageCenterInstance *)instance;

@end
