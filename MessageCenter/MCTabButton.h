//
//  MCTabButton.h
//  MessageCenter
//
//  Created by Rookie on 12/12/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A customed UIButton in MCStyle, work with MCTabBar
 */
@interface MCTabButton : UIButton

/**
 Show badge or not
 */
@property (nonatomic, assign) BOOL showBadge;

/**
 Initialize a MCTabButton

 @param title Button's title
 @param imageName Button image's name
 @return MCTabButton
 */
- (instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName;

@end
