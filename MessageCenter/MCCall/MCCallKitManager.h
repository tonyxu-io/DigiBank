//
//  MXCallKitManager.h
//
//  Created by Jacob on 10/25/16.
//  Copyright © 2016 Moxtra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CallKit/CallKit.h>


typedef enum : NSUInteger {
    MXCallStatus_None,
    MXCallStatus_End,
    MXCallStatus_AnswerEnd,
    MXCallStatus_CallerEnd,
    MXCallStatus_TimeOut,
    MXCallStatus_Accept,
    MXCallStatus_ReadyStart,
    MXCallStatus_Busy,
    MXCallStatus_StartConnect,
    MXCallStatus_Connected
} MXCallStatus;


@class MCCallKitManager;

@protocol MCCallKitManagerDelegate <NSObject>

@required
- (void)callKitManager:(MCCallKitManager *)sender refreshCurrentCallStatus:(MXCallStatus)status withCompletion:(void (^)(BOOL success))completion;

@optional

- (void)callKitManager:(MCCallKitManager *)sender refreshCurrentCallHoldState:(BOOL)onHold;
- (void)callKitManager:(MCCallKitManager *)sender refreshCurrentCallMuteState:(BOOL)isMute;
- (void)callKitManager:(MCCallKitManager *)sender refreshCurrentCallplayDTMFState:(NSString *)digits andCXPlayDTMFCallActionType:(CXPlayDTMFCallActionType)playType;
- (void)callKitManager:(MCCallKitManager *)sender refreshCurrentCallGroupState:(NSUUID*)groupUUID;

@end

@interface MCCallKitManager : NSObject

@property (nonatomic, readonly) NSUUID *currentUUID;

+ (MCCallKitManager *)sharedInstance;


@property (nonatomic, weak)  id<MCCallKitManagerDelegate>delegate;


/*** 接收方 展示电话呼入等待接收界面 ****/
- (void)showCallInComingWithName:(NSString *)userName andPhoneNumber:(NSString *)phoneNumber isVideoCall:(BOOL)isVideo;

/******* Action **********/
//禁音通话
- (void)muteCurrentCall:(BOOL)isMute;

//通话连接成功 显示通话时间 作为拨打方
- (void)connectedOutgoingCall;
//拨打方 结束通话调用
- (void)endCallAction;

//接听方结束电话
- (void)finishCallWithReason:(CXCallEndedReason)reason;

@end
