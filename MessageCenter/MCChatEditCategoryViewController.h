//
//  MCChatCategoryViewController.h
//  DigiBank
//
//  Created by Moxtra on 2017/4/17.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A view controller use to edit a chat's category
 */
@interface MCChatEditCategoryViewController : UIViewController
/**
 Initialize a MCChatEditCategoryViewController, use to update a chat's category.
 
 @param chat The MXChat you want update
 @param handler A block object excuted when 'Done' button tapped, it has one argument: newCategory, the chat's new category just modified
 @return MCChatEditCategoryViewController
 */
- (instancetype)initWithChatItem:(MXChat *)chat completeHandle:(void(^)(MXChatCategory *newCategory))handler;

@end
