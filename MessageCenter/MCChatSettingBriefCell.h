//
//  MCChatSettingBriefCell.h
//  DigiBank
//
//  Created by Moxtra on 2017/4/14.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 MCChatSettingBriefCellType

 - MCChatSettingBriefCellTypeDisplay: In this type, cell will display the chat's cover, topic and description
 - MCChatSettingBriefCellTypeUpdate: In this type, cell will display the chat's cover and an edit image button
 */
typedef NS_ENUM(NSUInteger,MCChatSettingBriefCellType){
    MCChatSettingBriefCellTypeDisplay = 0,
    MCChatSettingBriefCellTypeUpdate
};

/**
 Cell used to display MXChat's brief
 */
@interface MCChatSettingBriefCell : UITableViewCell

/**
 ImageView of chat cover.
 */
@property (nonatomic, strong) UIImageView *chatCoverImageView;

/**
 Topic label
 */
@property (nonatomic, strong) UILabel *topicLabel;

/**
 Description label
 */
@property (nonatomic, strong) UILabel *descriptionLabel;

/**
 MXChat, set this property to display chat's brief
 */
@property (nonatomic, strong) MXChat *chat;

/**
 Set this to change cell's display mode.See more in MCChatSettingBriefCellType
 */
@property (nonatomic, assign) MCChatSettingBriefCellType type;

/**
 Initialize MCChatSettingBriefCell with MCChatSettingBriefCellType and reuseIdentifier.

 @param type See more in MCChatSettingBriefCellType.
 @param reuseIdentifier The Cell's reuseIdentifier
 @return return value MCChatSettingBriefCell
 */
- (instancetype)initWithType:(MCChatSettingBriefCellType)type reuseIdentifier:(NSString *)reuseIdentifier;

@end
