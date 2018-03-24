//
//  MCUserListCell.h
//  DigiBank
//
//  Created by Moxtra on 2017/3/13.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ChatSDK/MXChatSDK.h>


/**
 Cell type,decide to display which kind of accessory.

 - MCUserListCellTypeCall: 'Call' accessory
 - MCUserListCellTypeCheck: 'CheckBox' accessory
 */
typedef NS_ENUM(NSUInteger,MCUserListCellType){
    MCUserListCellTypeCall = 0,
    MCUserListCellTypeCheck,
};

/**
 A tableView cell use to display a user's contact
 */
@interface MCUserListCell : UITableViewCell

/**
 MXUserItem, set this to display content
 */
@property (nonatomic, weak) MXUserItem *user;

/**
 The UIControl which trigger action
 */
@property (nonatomic, strong) UIControl *control;
/**
 Initializer

 @param identifier cell's reuse identifier
 @param type Cell type,decide to display which kind of accessory.
 @param action A block object excute when widget be tapped, the argument sender is the widget(call or checkbox button) itself.
 @return MCUserListCell
 */
- (instancetype)initWithReuseIdentifier:(NSString *)identifier
                             cellType:(MCUserListCellType)type
                           widgetAction:(void(^)(MCUserListCell *cell,id sender))action;
@end
