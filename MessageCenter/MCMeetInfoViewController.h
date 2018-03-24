//
//  MCMeetInfoViewController.h
//  DigiBank
//
//  Created by Moxtra on 2017/4/19.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A view controller use to display a meet's infomation
 */
@interface MCMeetInfoViewController : UIViewController

/**
 Initialize a MCMeetInfoViewController, use to display a meet's info

 @param meetItem The related meet item
 @param meetListModel The MXMeetListModel, use to operate
 @return MCMeetInfoViewController
 */
- (instancetype)initWithMeetItem:(MXMeet *)meetItem meetListModel:(MXMeetListModel *)meetListModel;

@end
