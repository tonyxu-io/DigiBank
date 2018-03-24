//
//  MCChatListCell.h
//  MessageCenter
//
//  Created by Rookie on 30/11/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MXChat;

/**
 Cell used to display MXChat's info
 */
@interface MCChatListCell : UITableViewCell

/**
 MXChat, set this to display cell's content.
 */
@property (nonatomic, weak) MXChat *chat;

@end
