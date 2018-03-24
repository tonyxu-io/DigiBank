//
//  MCFileListCell.h
//  DigiBank
//
//  Created by Moxtra on 2017/3/30.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Cell used to display MXFileItem's info
 */
@interface MCFileListCell : UITableViewCell

/**
 MXFileItem, set this to display cell's content.
 */
@property (nonatomic, weak) MXSignFileItem *signFileItem;

/**
 Hide or show the action button
 */
@property (nonatomic, assign) BOOL actionButtonHide;

/**
 A block object excuted when the action button tapped.
 */
@property (nonatomic, copy) void(^actionButtonTapped)(MXSignFileItem *fileItem);

@end
