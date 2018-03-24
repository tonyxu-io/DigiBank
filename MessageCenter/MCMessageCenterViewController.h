//
//  MCMessageCenterViewController.h
//  MessageCenter
//
//  Created by Rookie on 30/11/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MXChatClient;

/**
 Main Message Center ViewController,has five tabs:Inbox,File,To-do,Meeting,Contacts.
 */
@interface MCMessageCenterViewController : UIViewController < UINavigationControllerDelegate>

@property (nonatomic, strong) NSData *deviceToken;

//MCMessageCenterViewController is a singleton，use '+sharedInstance' method to get its instance.
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 Returns a global instance of MCMessageCenterViewController configured to mananger sub-viewControllers
*/
+ (instancetype)sharedInstance;

/**
 When login successed, call this method to diaplay content.
 */
- (void)loadContent;

/**
 When login successed, call this method to config some global interface presentation.
 */
- (void)configInerfacePresenting;

/**
 Push a MXChatViewController controller with chat globally

 @param chat The MXChat
 @param feed Target feed you may want scroll to
 */
- (void)openChatItem:(MXChat *)chat withFeedObject:(id)feed;

/**
 Push a MCInviteViewController to provide users to select.

 @param handler A block objct excute when completed users,has one argument:an array stored users just selected
 */
- (void)openInviteControllerWithHandleSelectedUsers:(void(^)(NSArray<MXUserItem *> *users))handler;

/**
 Present a MXGlobalSearchViewController
 */
- (void)openGlobalSearch;

/**
 Show a badge in Inbox tab

 @param show Show or not
 */
- (void)showInboxBadge:(BOOL)show;

/**
 Show a badge in Meet tab
 
 @param show Show or not
 */
- (void)showMeetBadge:(BOOL)show;

@end

