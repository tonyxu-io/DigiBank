//
//  MCChatBriefSettingViewController.h
//  DigiBank
//
//  Created by Moxtra on 2017/4/17.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCChatBriefSettingViewController;

/* 
 A protocol for delegates of MCChatBriefSettingViewController
 */
@protocol MCChatBriefUpdateDelegate <NSObject>

/**
 Called when MCChatBriefSettingViewController finished uploaded a new cover.

 @param controller MCChatBriefSettingViewController
 @param newImage The new chat cover
 */
- (void)briefSettingViewController:(MCChatBriefSettingViewController *)controller didUpdatedChatCoverWithImage:(UIImage *)newImage;

/**
 Called when MCChatBriefSettingViewController finished updated a new topic.
 
 @param controller MCChatBriefSettingViewController
 @param newTopic The new chat topic
 */
- (void)briefSettingViewController:(MCChatBriefSettingViewController *)controller didUpdatedChatTopic:(NSString *)newTopic;

/**
 Called when MCChatBriefSettingViewController finished updated a new description.
 
 @param controller MCChatBriefSettingViewController
 @param newDesc The new chat description
 */
- (void)briefSettingViewController:(MCChatBriefSettingViewController *)controller didUpdatedChatDescription:(NSString *)newDesc;

@end

/**
 A controller use to edit a chat's brief
 */
@interface MCChatBriefSettingViewController : UIViewController

/**
 The object that acts as delegate of the MCChatBriefSettingViewController
 */
@property (nonatomic, weak) id<MCChatBriefUpdateDelegate> updateDelegate;

/**
 Initialize MCChatBriefSettingViewController with MXChat.

 @param chat The related chat item
 @return MCChatBriefSettingViewController
 */
- (instancetype)initWithChatItem:(MXChat *)chat;

@end
