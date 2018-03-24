//
//  MCChatEmailViewController.h
//  DigiBank
//
//  Created by Moxtra on 2017/4/18.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A view controller use to display chat's email adress and email actions
 */
@interface MCChatEmailViewController : UIViewController

/**
 Initialize a MCChatEmailViewController, use to view email or create contact.etc

 @param chat The related chat item
 @param email Email adress
 @return MCChatEmailViewController
 */
- (instancetype)initWithChatItem:(MXChat *)chat emailAdress:(NSString *)email;

@end
