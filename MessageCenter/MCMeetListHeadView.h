//
//  MCMeetListHeadView.h
//  DigiBank
//
//  Created by Moxtra on 2017/3/27.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCMeetListHeadView : UIView

/**
 Init a MCMeetListHeadView

 @param title Center button's title
 @param handler A block object excuted when button be tapped，the block has no return value, takes one argument:the button which be tapped
 @return MCMeetListHeadView
 */
- (instancetype)initWithTitle:(NSString *)title
                 buttonTapped:(void(^)(UIButton *sender))handler;

@end
