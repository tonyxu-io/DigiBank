//
//  MCChatSettingMemberCell.h
//  DigiBank
//
//  Created by Moxtra on 2017/4/14.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A cell use to display chat's member
 */
@interface MCChatSettingMemberCell : UITableViewCell

/**
 MXUserItem, set this property to display user info
 */
@property (nonatomic, strong) MXUserItem *userItem;

/**
 The user's authority
 */
@property (nonatomic, assign) MXChatMemberAccessType accessType;

@end
