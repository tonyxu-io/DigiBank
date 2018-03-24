//
//  MCUserListViewController.h
//  DigiBank
//
//  Created by Moxtra on 2017/3/13.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ChatSDK/MXChatSDK.h>

/**
 An object use to package user data in different section
 */
@interface MCUserSection : NSObject

/**
 Section's title
 */
@property (nonatomic, copy) NSString *title;

/**
 Section's data
 */
@property (nonatomic, strong) NSMutableArray<MXUserItem *> *data;

/**
 Packing users in sections according to first character of the firstname

 @param users Unprocessed users
 @return An array stored MCUserSection
 */
+ (NSArray<MCUserSection *> *)getUserSectionArrayWithUsers:(NSArray <MXUserItem *> *)users;

@end

/**
 A view controller use to display a list of user's contact
 */
@interface MCUserListViewController : UIViewController

/** Load user list and display*/
- (void)loadUserList;

@end
