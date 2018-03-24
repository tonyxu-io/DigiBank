//
//  MCMeetListCell.h
//  DigiBank
//
//  Created by Moxtra on 2017/3/27.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface MCMeetCellRecordView : UIView

@end

/**
 A tableView cell use to display a meet's brief
 */
@interface MCMeetListCell : SWTableViewCell

/**
 MXMeet, set this to display content.
 */
@property (nonatomic, strong) MXMeet *meetItem;

@property (nonatomic, assign) BOOL isJoin;

/**
 A block object excute when start/join button tapped.It takes two arguments: start - 'YES' for start a meet , 'NO' for join a meet.
 */
@property (nonatomic, copy) void(^handleStartOrJoinMeet)(BOOL start, id sender);

/**
  A block object excute when play button tapped.
 */
@property (nonatomic, copy) void(^handlePlayButtonTapped)(UIButton *sender);

@end
