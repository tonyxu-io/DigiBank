//
//  MCTodoListCell.h
//  MessageCenter
//
//  Created by wubright on 2016/12/5.
//  Copyright © 2016年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MXTodoItem;

/**
 A tableView cell use to display a todo item
 */
@interface MCTodoListCell : UITableViewCell

/**
 MXTodoItem, set this to display cell's content.
 */
@property (nonatomic, strong) MXTodoItem *todoItem;

@end
