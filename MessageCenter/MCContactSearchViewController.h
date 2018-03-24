//
//  MCContactSearchViewController.h
//  DigiBank
//
//  Created by Moxtra on 2017/3/13.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ChatSDK/MXUserListModel.h>

@interface MCContactSearchViewController : UIViewController

@property (nonatomic, weak) UIViewController *listController;

@property (nonatomic, weak) MXUserListModel *contactItems;

@property (nonatomic, strong) NSArray<MXUserItem *> *contacts;

- (void)reloadResults;

@end
