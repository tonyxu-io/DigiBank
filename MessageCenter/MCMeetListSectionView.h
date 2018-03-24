//
//  MCMeetListSectionView.h
//  DigiBank
//
//  Created by Moxtra on 2017/3/27.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A section head view use to display a section's date
 */
@interface MCMeetListSectionView : UITableViewHeaderFooterView

/**
 Date represent the section 
 */
@property (nonatomic, strong) NSDate *sectionDate;

/**
 The color of content will be green if 'isToday' setted to YES,otherwise is gray.
 Default is NO.
 */
@property (nonatomic, assign) BOOL isToday;


/**
 The right part of content will show “No Meeting” if 'hasMeeting' setted to NO,otherwise is hidden. 
 Default is YES.
 */
@property (nonatomic, assign) BOOL hasMeeting;

@end
