//
//  MCInviteViewController.h
//  DigiBank
//
//  Created by Moxtra on 2017/4/6.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A viewController contains user's contact,use to invite other user then create a new chat or invite members in meet/chat.
 */
@interface MCInviteViewController : UIViewController

/**
 Initialize a MCInviteViewController with completion handler

 @param handler A block object excuted when finished invited
 @return MCInviteViewController
 */
- (instancetype)initWithHandleSelectedUsers:(void(^)(NSArray <MXUserItem *> *users))handler;

@end
