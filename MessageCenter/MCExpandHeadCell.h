//
//  MCTodoChatHeadCell.h
//  MessageCenter
//
//  Created by Rookie on 16/12/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 An expandable talbeview cell, work with MCExpandTableView
 */
@interface MCExpandHeadCell : UITableViewCell

/**
 The cell's title
 */
@property (nonatomic, copy) NSString *title;

/**
 The cell's badge content,default is 0 and hidden. Largest number is 99.
 */
@property (nonatomic, assign) NSUInteger badgeNumber;

/**
 Expand cell with animation
 
 @param expanded Expand cell or not
 @param animated Animate or not
 */
- (void)setExpanded:(BOOL)expanded animated:(BOOL)animated;

@end
