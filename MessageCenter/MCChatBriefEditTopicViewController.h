//
//  MCChatBriefEditTopicViewController.h
//  DigiBank
//
//  Created by Moxtra on 2017/4/17.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A view controller use to edit a chat's topic
 */
@interface MCChatBriefEditTopicViewController : UIViewController

/**
 Initialize a MCChatBriefEditTopicViewController, use to update a chat's topic.

 @param chat The MXChat you want update
 @param handler A block object excuted when 'Done' button tapped, it has one argument: newTopic, the chat's new topic just modified
 @return MCChatBriefEditTopicViewController
 */
- (instancetype)initWithChatItem:(MXChat *)chat completeHandler:(void(^)(NSString *newTopic))handler;

@end
