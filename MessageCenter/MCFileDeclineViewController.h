//
//  MCFileDeclineViewController.h
//  DigiBank
//
//  Created by Moxtra on 2017/4/11.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A view controller use to input a reson for declining a file
 */
@interface MCFileDeclineViewController : UIViewController

/**
 Initialize a file decline view controller

 @param chatSession The MXChatSession which file belongs to
 @param signItem The file you want to decline
 @return MCFileDeclineViewController
 */
- (instancetype)initWithChatItemModel:(MXChatSession *)chatSession
                         signFileItem:(MXSignFileItem *)signItem;

@end
