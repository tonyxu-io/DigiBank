//
//  MCUserInfoViewController.h
//  DigiBank
//
//  Created by Moxtra on 2017/4/7.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MXUserItem;

/**
 A viewController use to display a user's info
 */
@interface MCUserInfoViewController : UIViewController

/**
 Initialize a MCUserInfoViewController with MXUserItem and MXUserListModel

 @param user The user in display
 @param userListModel MXUserListModel, use to get the user's data
 @return MCUserInfoViewController
 */
- (instancetype)initWithUserItem:(MXUserItem *)user userListModel:(MXUserListModel *)userListModel;

@end
