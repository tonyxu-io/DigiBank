//
//  MCFileSigneeCell.h
//  DigiBank
//
//  Created by Moxtra on 2017/3/31.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ChatSDK/MXChatSDK.h>

/**
 A cell use to display a sign-file signee
 */
@interface MCFileSigneeCell : UITableViewCell

/**
 MXUserItem, set this to display file's signee.
 */
@property (nonatomic, weak) MXUserItem *fileSigner;

/**
 MXFileSigneeState, set this to display file's signing state
 */
@property (nonatomic, assign) MXFileSigneeState signState;

@end
