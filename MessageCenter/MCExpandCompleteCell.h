//
//  MCExpandCompleteCell.h
//  DigiBank
//
//  Created by Moxtra on 2017/3/31.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 An expandable talbeview cell, work with MCExpandTableView
 */
@interface MCExpandCompleteCell : UITableViewCell

/**
 The cell's title
 */
@property (nonatomic, copy) NSString *title;

/**
 AccessoryView display "-" for expand setted to YES, "+" for NO.
 */
@property (nonatomic, assign) BOOL expand;

@end
