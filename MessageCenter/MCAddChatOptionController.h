//
//  MCAddChatOptionController.h
//  MessageCenter
//
//  Created by bright wu on 14-12-5.
//
//

#import <UIKit/UIKit.h>

/**
 Use to create a topic for the chat, can skip this step.
 */
@interface MCAddChatOptionController : UIViewController

/**
 Initialize MCAddChatOptionController with invited users.

 @param users The invited users
 @return MCAddChatOptionController
 */
- (instancetype)initWithInvitedUsers:(NSArray <MXUserItem *>*)users;

@end
