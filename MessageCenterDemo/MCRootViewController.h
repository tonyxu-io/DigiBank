//
//  MCRootViewController.h
//  MessageCenter
//
//  Created by Rookie on 01/12/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCRootViewController : UIViewController

+ (instancetype)sharedInstance;

/**
 Switch MCRootViewController's content

 @param containerController The container viewController
 */

- (void)switchContainerController:(UIViewController *)containerController;

- (void)handleRemoteNotification:(NSDictionary *)userInfo;
@end
