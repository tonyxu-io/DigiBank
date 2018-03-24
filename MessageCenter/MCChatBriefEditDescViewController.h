//
//  MCChatBriefEditDescViewController.h
//  DigiBank
//
//  Created by Moxtra on 2017/4/17.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A view controller use to edit a chat's description
 */
@interface MCChatBriefEditDescViewController : UIViewController

/**
 Initialize a MCChatBriefEditDescViewController, use to update a chat's description.

 @param chat The MXChat you want update
 @param handler A block object excuted when 'Save' button tapped, it has one argument: newDesc, the chat's new description just modified
 @return MCChatBriefEditDescViewController
 */
- (instancetype)initWithChatItem:(MXChat *)chat completeHandler:(void(^)(NSString *newDesc))handler;;

@end
