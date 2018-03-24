//
//  MCTabBar.h
//  DigiBank
//
//  Created by Moxtra on 2017/3/28.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - MCTabButton

/**
 A customed UITabBar in MCStyle.
 */
@interface MCTabBarButton : UITabBarItem

@end

#pragma mark - MCTabBar

/**
 A customed UITabBar in MCStyle
 */
@interface MCTabBar : UITabBar

/**
 MCTabBar initializer,

 @param frame Frame
 @param handler A block object excuted after tapped a MCTabBarButton or called method: 'selectIndex:'.
 @return MCTabBar
 */
- (instancetype)initWithFrame:(CGRect)frame
           handleSelectedItem:(void(^)(UITabBarItem *item))handler;

/**
 Set which badge to show or not.
 Default is hidden.

 @param index The badge's index
 @param show Show or not
 */
- (void)setBadgeAtIndex:(NSUInteger)index show:(BOOL)show;


/**
 Select a MCTabBarButton,
 this method would extra excute the handler passed in initializer.

 @param index The button's index
 */
- (void)selectIndex:(NSUInteger)index;

@end
