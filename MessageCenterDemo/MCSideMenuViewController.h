//
//  MCSideMenuViewController.h
//  MessageCenter
//
//  Created by Rookie on 01/12/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCSideMenuViewController : UITableViewController


/**
 Where MCSideMenuViewController presented from
 @discussion Set this property would add an UIScreenEdgePanGestureRecognizer on container  
 */
@property (nonatomic, weak) UIViewController *container;

/**
 Initialize a MCSideMenuViewController

 @param titles The titles of the menu option
 @param handler A block object to be executed when one menu option be selected. Block has no return value, and takes one argument:selected index.

 @return MCSideMenuViewController
 */
- (instancetype)initWithMenuTitles:(NSArray <NSString *> *)titles
                     indexSelected:(void(^)(NSUInteger index))handler;
@end
