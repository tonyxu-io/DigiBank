//
//  MCFileSignActionCell.h
//  DigiBank
//
//  Created by Moxtra on 2017/3/31.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A tableView cell provides sign/decline action button
 */
@interface MCFileSignActionCell : UITableViewCell

/**
 A block object excuted when decline button tapped.
 */
@property (nonatomic, copy) void(^declineButtonTapped)();
/**
 A block object excuted when sign button tapped.
 */
@property (nonatomic, copy) void(^signButtonTapped)();

@end
