//
//  MCMeetRingCallViewController.h
//  MessageCenter
//
//  Created by jacob on 12/28/16.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol MCMeetRingCallViewControllerDelegate;

/**
 A view controller use in meet dialing
 */
@interface MCMeetRingCallViewController : UIViewController
/**
 Set this to display MCMeetRingCallViewController content
 */
@property(nonatomic, readonly) MXMeet *meetItem;
/**
 The object that acts as delegate of the MCMeetRingCallViewController
 */
@property(weak) id<MCMeetRingCallViewControllerDelegate> delegate;

/**
 Initialize MCMeetRingCallViewController with a meetItem

 @param meetItem The MXMeet
 @return MCMeetRingCallViewController
 */
- (instancetype)initWithMeetItem:(MXMeet *)meetItem;

@end

/*
 A protocol for delegates of MCMeetRingCallViewController
 */
@protocol MCMeetRingCallViewControllerDelegate <NSObject>
/**
 Tells the delegate that the meet has been accepted.
 
 @param sender MCMeetRingCallViewController
 @param meetItem  The MXMeet just been accepted
 */
- (void)meetRingCallView:(MCMeetRingCallViewController *)sender didAcceptWithMeetItem:(MXMeet *)meetItem;

/**
 Tells the delegate that the meet has been declined.

 @param sender MCMeetRingCallViewController
 @param meetItem  The MXMeet just been declined
 */
- (void)meetRingCallView:(MCMeetRingCallViewController *)sender didDeclineWithMeetItem:(MXMeet *)meetItem;

@end
