//
//  MCChatSettingViewController.h
//  DigiBank
//
//  Created by Moxtra on 2017/4/14.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 A view controller use to set a chat
 */
@interface MCChatSettingViewController : UIViewController

/**
 Initialize a chat setting controller with a specified chat item.
 
 @param chat The related chat item
 @return Return MCChatSettingViewController
 */
- (instancetype)initWithChatItem:(MXChat *)chat;

@end
