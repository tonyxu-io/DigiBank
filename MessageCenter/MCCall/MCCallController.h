//
//  MXTelCallController.h
//  MoxtraBinder
//
//  Created by mac on 16/10/8.
//
//

#import <UIKit/UIKit.h>

/**
 The type of meet be switched to.

 - MCSwitchToMeetTypeShareFile: Switch to share file
 - MCSwitchToMeetTypeShareScreen: Switch to share screen
 - MCSwitchToMeetTypeWhiteBoard: Switch to share white board
 - MCSwitchToMeetTypeAddUser: Switch to add user
 - MCSwitchToMeetTypeVideo: Switch to video
 */
typedef NS_ENUM(NSInteger,MCSwitchToMeetType){
    MCSwitchToMeetTypeShareFile,
    MCSwitchToMeetTypeShareScreen,
    MCSwitchToMeetTypeWhiteBoard,
    MCSwitchToMeetTypeAddUser,
    MCSwitchToMeetTypeVideo
};

/**
 The state of MCCallController, decide the display content.
 */
typedef NS_ENUM(NSInteger,MCCallControllerState){
    MCCallControllerStateCalling,
    MCCallControllerStateConnecting,
    MCCallControllerStateConfirmed,
    MCCallControllerStateCanceled = 200,
    MCCallControllerStateNoAnswer = 210,
    MCCallControllerStateDeclined = 220,
    MCCallControllerStateNormalEnded = 230,
    MCCallControllerStateCallFailed = 240
};

@class MXUserItem;
@protocol MCCallControllerDelegate;

//Notification name of call ended
extern NSString *const MXTelCallControllerEndNotification;
extern NSString *const MXTelCallControllerEndNotificationCanceledByMyselfKey;
extern NSString *const MXTelCallControllerEndNotificationCallOutMemberKey;

/**
 A view controller use in dialing or be called
 */

@interface MCCallController : UIViewController

/**
 A boolean value to flag whether is calling out or be called.
 */
@property (nonatomic, assign, readwrite) BOOL isCallOut;

/**
 Open meet function or not, default is YES.
 */
@property (nonatomic, assign, readwrite) BOOL isMeetFunctionEnable;

/**
 The number being called.
 */
@property (nonatomic, strong, readwrite) NSString* callNumber;

/**
 The user be called or calling from
 */
@property (nonatomic, strong, readwrite) MXUserItem* user;

/**
 Set this to display MCCallController content
 */
@property (nonatomic, strong) MXCallItem *callItem;

/**
 The object that acts as delegate of the MCCallController
 */
@property (nonatomic, weak) id<MCCallControllerDelegate> delegate;

/**
 Set state to change MCCallController's display

 @param state MCCallControllerState
 */
- (void)setCallState:(MCCallControllerState)state;

/**
 Mute current call
 */
- (void)mute;

/**
 Unmute current call
 */
- (void)unmute;

/**
 Turn on the speaker
 */
- (void)turnOnSpeaker;

/**
 Turn off the speaker
 */
- (void)turnOffSpeaker;

/**
 Switch current call to meet
 */
- (void)switchToMeetWithVideo;

/**
 Answer current call
 */
- (void)answerCall;

/**
 Reject current call
 */
- (void)rejectCall;

@end

@protocol MCCallControllerDelegate <NSObject>

@optional

/**
 Tells the delegate that the answer button has been tapped. The delegate should implement the answer method, then tell MCCallController with the result.
 
 @param callController MCCallController
 @param completion Answered successfully or not
 */
- (void)mcCallController:(MCCallController *)callController didSendAnswerCallActionWithCompletion:(void (^)(BOOL success))completion;

/**
 Tells the delegate that the reject button has been tapped. The delegate should implement the reject method, then tell MCCallController with the result.

 @param callController MCCallController
 @param completion Rejected successfully or not
 */
- (void)mcCallController:(MCCallController *)callController didSendRejectCallActionWithCompletion:(void (^)(BOOL success))completion;

/**
 Tells the delegate that the unmute button has been tapped. The delegate should implement the unmute method, then tell MCCallController with the result.
 
 @param callController MCCallController
 @param completion Unmuted successfully or not
 */
- (void)mcCallController:(MCCallController *)callController didSendUnMuteCallActionWithCompletion:(void (^)(BOOL success))completion;

/**
 Tells the delegate that the mute button has been tapped. The delegate should implement the mute method, then tell MCCallController with the result.
 
 @param callController MCCallController
 @param completion Muted successfully or not
 */
- (void)mcCallController:(MCCallController *)callController didSendMuteCallActionWithCompletion:(void (^)(BOOL success))completion;

/**
 Tells the delegate that the call button has been tapped. The delegate should implement the call method, then tell MCCallController with the result.
 
 @param callController MCCallController
 @param callNumber The calling number
 @param completion Call successfully or not
 */
- (void)mcCallController:(MCCallController *)callController didSendMakeCallAction:(NSString *)callNumber withCompletion:(void (^)(BOOL success))completion;

/**
 Tells the delegate that the hangup button has been tapped. The delegate should implement the hangup method, then tell MCCallController with the result.
 
 @param callController MCCallController
 @param completion Hangup successfully or not
 */
- (void)mcCallController:(MCCallController *)callController didSendHangupCallActionWithCompletion:(void (^)(BOOL success))completion;

/**
 Tells the delegate that the DTMF button has been tapped. The delegate should implement the SetCallDTMF method, then tell MCCallController with the result.

 @param callController MCCallController
 @param digit  DTMF digit string
 */
- (void)mcCallController:(MCCallController *)callController didSendSetCallDTMFAction:(NSString *)digit;

/**
 Tells the delegate that the switch to meet button has been tapped. The delegate should implement the switchToMeet method, then tell MCCallController with the result.
 
 @param callController MCCallController
 @param type The type of meet be switched to.
 @param completion Switch to meet successfully or not
 */
- (void)mcCallController:(MCCallController *)callController didSendSwitchToMeetActionWithSwitchType:(MCSwitchToMeetType)type completion:(void (^)(BOOL success))completion;

@end
