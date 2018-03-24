//
//  MCChatListViewController.h
//  MessageCenter
//
//  Created by Rookie on 30/11/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ChatSDK/MXChatSDK.h>

/**
 A view controller use to display a list of user's chats 
 */
@interface MCChatListViewController : UIViewController <MXChatClientDelegate>

/** Load chat list and display*/
- (void)loadChatList;

@end
