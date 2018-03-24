//
//  MCCallKitManager.m
//
//  Created by Jacob on 10/25/16.
//  Copyright © 2016 Moxtra. All rights reserved.
//

#import "MCCallKitManager.h"
#import <Intents/Intents.h>
#import <AVFoundation/AVFoundation.h>

@interface MCCallKitManager ()<CXProviderDelegate,CXCallObserverDelegate>

@property (nonatomic, strong) CXProvider *provider;
@property (nonatomic, strong) CXCallUpdate *callUpdate; //信息状态变换更新
@property (nonatomic, strong) CXProviderConfiguration *configuration; //配置

@property (nonatomic, strong) CXCallController *callController; //call 界面
@property (nonatomic, strong) NSUUID *currentUUID;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, assign) BOOL currentIsVideo;
@property (nonatomic, strong) NSString *currentPhoneNumber; //需要有+号

@property (nonatomic, assign) BOOL  hasOtherCall;//当前是否存在其他call //如系统电话或其他app的call

@end

@implementation MCCallKitManager

#define callQueue  dispatch_get_main_queue()//dispatch_queue_create("WESKHEN_CallKitQueue", 0)
+ (MCCallKitManager *)sharedInstance
{
    static MCCallKitManager *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if( [UIDevice currentDevice].systemVersion.floatValue >= 10.0 )
            singleton = [MCCallKitManager new];
    });
    return singleton;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.provider = [[CXProvider alloc] initWithConfiguration:self.configuration];
        [_provider setDelegate:self queue:nil];
        [self.callController.callObserver setDelegate:self queue:callQueue];
    }
    return self;
}


//接听方 来电展示 incomingCall
- (void)showCallInComingWithName:(NSString *)userName andPhoneNumber:(NSString *)phoneNumber isVideoCall:(BOOL)isVideo
{
    self.currentIsVideo = isVideo;
    self.currentPhoneNumber = phoneNumber;
    
    CXHandle* handle=[[CXHandle alloc]initWithType:CXHandleTypeGeneric value:phoneNumber];
    self.callUpdate.remoteHandle = handle;
    _callUpdate.hasVideo = isVideo;
    _callUpdate.localizedCallerName = userName;
    self.userName = userName;
    
    self.currentUUID = [NSUUID UUID];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    [_provider reportNewIncomingCallWithUUID:self.currentUUID update:self.callUpdate completion:^(NSError * _Nullable error) {
        if (error) {
        }
    }];
}

//拨打方
- (void)starCallWithUserActivity:(NSUserActivity *)userActivity
{
    BOOL isVideoCall = false;
    if ([userActivity.activityType isEqualToString:@"INStartAudioCallIntent"]) {
        //voice call
        isVideoCall = false;
    }
    else if ([userActivity.activityType isEqualToString:@"INStartVideoCallIntent"])
    {
        //video call
        isVideoCall = true;
    }
    
    INInteraction *interaction = userActivity.interaction;
    INIntent *intent = interaction.intent;
    
    INPerson *person = nil;
    if (isVideoCall) {
        person = [(INStartVideoCallIntent *)intent contacts][0];
    }
    else
    {
        person = [(INStartAudioCallIntent *)intent contacts][0];
    }
    
    if (person.personHandle.type != INPersonHandleTypePhoneNumber) {
        return;
    }
    
    // 长按通讯录中联系人号码 person.personHandle.value 读取的是通讯录中的号码 可能不含（+区号）需要自己做简单识别判断
    if ([self.currentPhoneNumber isEqualToString:person.personHandle.value] && self.currentPhoneNumber.length > 0) {
        //同一个回话
        if (self.currentIsVideo == isVideoCall) {
            //其他的场景不处理:
            
        }
        else
        {
            //根据实际需要来实现  是否需要改变通话性质  一般不直接更新改变 可进去到具体的界面展示后再调整是否视频
            if (self.currentIsVideo) {
                //从video转voice Call
            }
            else
            {
                //从voice转video Call
                
            }
            //            self.callUpdate.hasVideo = isVideoCall;
            //            [_provider reportCallWithUUID:_currentUUID updated:self.callUpdate];
            
        }
    }
    else
    {
        //不同的回话
        if (self.currentPhoneNumber) {
            //已有正在进行中通话  busy
            if (self.delegate && [self.delegate respondsToSelector:@selector(callKitManager:refreshCurrentCallStatus:withCompletion:)]) {
                [self.delegate callKitManager:self refreshCurrentCallStatus:MXCallStatus_Busy withCompletion:nil];
            }
            return;
        }
        //创建新会话
        self.currentUUID = [NSUUID UUID];
        self.currentIsVideo = isVideoCall;
        self.currentPhoneNumber = person.personHandle.value;
        
        CXHandle *handle = [[CXHandle alloc] initWithType:(CXHandleType)person.personHandle.type value:self.currentPhoneNumber];
        CXStartCallAction *startCallAction = [[CXStartCallAction alloc] initWithCallUUID:self.currentUUID handle:handle];
        startCallAction.video = isVideoCall;
        CXTransaction *transaction = [[CXTransaction alloc] init];
        [transaction addAction:startCallAction];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
        [self requestTransaction:transaction];
        
        self.callUpdate.localizedCallerName = self.userName; //根据phoneNumber 查找当前对应的name 并更新
        [_provider reportCallWithUUID:_currentUUID updated:self.callUpdate];
        
    }
}

#pragma mark - Event
- (void)muteCurrentCall:(BOOL)isMute
{
    NSLog(@"self.currentUUID = %@", self.currentUUID);
    if( self.currentUUID.UUIDString.length == 0 )
        return;
    CXSetMutedCallAction *muteCallAction = [[CXSetMutedCallAction alloc] initWithCallUUID:self.currentUUID muted:isMute];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:muteCallAction];
    [self requestTransaction:transaction];
}

- (void)heldCurrentCall:(BOOL)onHold
{
    NSLog(@"self.currentUUID = %@", self.currentUUID);
    if( self.currentUUID.UUIDString.length == 0 )
        return;
    CXSetHeldCallAction *heldCallAction = [[CXSetHeldCallAction alloc] initWithCallUUID:self.currentUUID onHold:onHold];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:heldCallAction];
    [self requestTransaction:transaction];
}

- (void)playDTMFCurrentCall:(CXPlayDTMFCallActionType)playType andDigits:(NSString *)digits
{
    NSLog(@"self.currentUUID = %@, digits = %@", self.currentUUID, digits);
    if( self.currentUUID.UUIDString.length == 0 )
        return;
    CXPlayDTMFCallAction *playDTMFCallAction = [[CXPlayDTMFCallAction alloc] initWithCallUUID:self.currentUUID digits:digits type:playType];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:playDTMFCallAction];
    [self requestTransaction:transaction];
}

- (void)setGroupCurrentCallWithGroupUUID:(NSUUID *)groupUUID
{
    if( self.currentUUID.UUIDString.length == 0 )
        return;
    CXSetGroupCallAction *groupCallAction = [[CXSetGroupCallAction alloc] initWithCallUUID:self.currentUUID callUUIDToGroupWith:groupUUID];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:groupCallAction];
    [self requestTransaction:transaction];
}

//拨打方 结束通话调用
- (void)endCallAction
{
    NSLog(@"self.currentUUID = %@", self.currentUUID);
    if( self.currentUUID.UUIDString.length == 0 )
        return;
    CXEndCallAction *endCallAction = [[CXEndCallAction alloc] initWithCallUUID:self.currentUUID];
    CXTransaction *transaction = [[CXTransaction alloc] init];
    [transaction addAction:endCallAction];
    
    __weak __typeof(self) wself = self;
    [_callController requestTransaction:transaction completion:^( NSError *_Nullable error){
        NSLog(@"Error requesting transaction: %@", error);
        if (error !=nil) {
            // do something
        }
        else
        {
            NSLog(@"Requested transaction successfully");
            [wself resetVariableData];
            if (wself.delegate && [wself.delegate respondsToSelector:@selector(callKitManager:refreshCurrentCallStatus:withCompletion:)]) {
                [wself.delegate callKitManager:self refreshCurrentCallStatus:MXCallStatus_CallerEnd withCompletion:nil];
            }
        }
    }];
    
    
}

//开始连接
- (void)startedConnectingOutgoingCall
{
    NSLog(@"self.currentUUID = %@", self.currentUUID);
    if( self.currentUUID.UUIDString.length == 0 )
        return;
    [_provider reportOutgoingCallWithUUID:_currentUUID startedConnectingAtDate:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(callKitManager: refreshCurrentCallStatus:withCompletion:)]) {
        [self.delegate callKitManager:self refreshCurrentCallStatus:MXCallStatus_StartConnect withCompletion:nil];
    }
}

//通话连接成功 显示通话时间 作为拨打方
- (void)connectedOutgoingCall
{
    NSLog(@"self.currentUUID = %@", self.currentUUID);
    if( self.currentUUID.UUIDString.length == 0 )
        return;
    [_provider reportOutgoingCallWithUUID:_currentUUID connectedAtDate:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(callKitManager:refreshCurrentCallStatus:withCompletion:)]) {
        [self.delegate callKitManager:self refreshCurrentCallStatus:MXCallStatus_Connected withCompletion:nil];
    }
}

//接听方结束电话
- (void)finishCallWithReason:(CXCallEndedReason)reason;
{
    NSLog(@"self.currentUUID = %@, reason = %ld", self.currentUUID, (long)reason);
    if( self.currentUUID.UUIDString.length == 0 )
        return;
    [_provider reportCallWithUUID:self.currentUUID endedAtDate:nil reason:reason];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(callKitManager:refreshCurrentCallStatus:withCompletion:)]) {
        [self.delegate callKitManager:self refreshCurrentCallStatus:MXCallStatus_AnswerEnd withCompletion:nil];
    }
}

#pragma mark - CXProviderDelegate
- (void)providerDidReset:(CXProvider *)provider
{
    NSLog(@"resetedUUID:%ld",provider.pendingTransactions.count);
}

- (void)providerDidBegin:(CXProvider *)provider
{
    // provider 创建成功
    NSLog(@"a provider begin");
}


- (BOOL)provider:(CXProvider *)provider executeTransaction:(CXTransaction *)transaction
{
    //返回true 不执行系统通话界面 直接End
    return false;
}

- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action
{
    //通话开始
    NSLog(@"action = %@", action);
    //connect --- code 调起app内的呼叫界面
    [action fulfill];
    if (self.delegate && [self.delegate respondsToSelector:@selector(callKitManager:refreshCurrentCallStatus:withCompletion:)])
    {
        [self.delegate callKitManager:self refreshCurrentCallStatus:MXCallStatus_ReadyStart withCompletion:^(BOOL success) {
        }];
    }
}
- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action
{
    //接听
    NSLog(@"action = %@", action);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(callKitManager:refreshCurrentCallStatus:withCompletion:)]) {
        [self.delegate callKitManager:self refreshCurrentCallStatus:MXCallStatus_Accept withCompletion:^(BOOL success) {
        }];
    }
    [action fulfill];
}

//拨打方挂断或被叫方拒绝接听
- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action
{
    //结束通话
    NSLog(@"action = %@", action);
    [self resetVariableData];//通话结束
    [action fulfill];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(callKitManager:refreshCurrentCallStatus:withCompletion:)])
    {
        [self.delegate callKitManager:self refreshCurrentCallStatus:MXCallStatus_End withCompletion:^(BOOL success) {
        }];
    }
    
}
- (void)provider:(CXProvider *)provider performSetHeldCallAction:(CXSetHeldCallAction *)action
{
    //保留
    NSLog(@"action = %@", action);
    if (self.delegate && [self.delegate respondsToSelector:@selector(callKitManager:refreshCurrentCallHoldState:)]) {
        [self.delegate callKitManager:self refreshCurrentCallHoldState:action.onHold];
    }
    [action fulfill];
}
- (void)provider:(CXProvider *)provider performSetMutedCallAction:(CXSetMutedCallAction *)action
{
    //静音
    NSLog(@"action.muted = %@",action.muted ? @"mute":@"unmute");
    if (self.delegate && [self.delegate respondsToSelector:@selector(callKitManager:refreshCurrentCallMuteState:)]) {
        [self.delegate callKitManager:self refreshCurrentCallMuteState:action.muted];
    }
    [action fulfill];
    
}
- (void)provider:(CXProvider *)provider performSetGroupCallAction:(CXSetGroupCallAction *)action
{
    //群组电话
    NSLog(@"CallKit----group call");
    if (self.delegate && [self.delegate respondsToSelector:@selector(callKitManager:refreshCurrentCallGroupState:)]) {
        [self.delegate callKitManager:self refreshCurrentCallGroupState:action.callUUIDToGroupWith];
    }
    [action fulfill];
}


- (void)provider:(CXProvider *)provider performPlayDTMFCallAction:(CXPlayDTMFCallAction *)action
{
    NSLog(@"");
    //双音频功能
    if (self.delegate && [self.delegate respondsToSelector:@selector(callKitManager:refreshCurrentCallplayDTMFState:andCXPlayDTMFCallActionType:)]) {
        [self.delegate callKitManager:self refreshCurrentCallplayDTMFState:action.digits andCXPlayDTMFCallActionType:action.type];
    }
    [action fulfill];
}

- (void)provider:(CXProvider *)provider timedOutPerformingAction:(CXAction *)action
{
    NSLog(@"action = %@", action);
    //超时
    if (self.delegate && [self.delegate respondsToSelector:@selector(callKitManager:refreshCurrentCallStatus:withCompletion:)]) {
        [self.delegate callKitManager:self refreshCurrentCallStatus:MXCallStatus_TimeOut withCompletion:nil];
    }
    [self resetVariableData];
    [action fulfill];
}

/// Called when the provider's audio session activation state changes.
- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession
{
    //audio session 设置
    NSLog(@"");
    
}
- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession
{
    //call end
    NSLog(@"");
}

#pragma mark - mainPrivate
//无论何种操作都需要 话务控制器 去 提交请求 给系统
-(void)requestTransaction:(CXTransaction *)transaction
{
    NSLog(@"");
    [_callController requestTransaction:transaction completion:^( NSError *_Nullable error){
        if (error !=nil) {
            NSLog(@"Error requesting transaction: %@", error);
        }
        else
        {
            NSLog(@"Requested transaction successfully");
        }
    }];
}

//重置变量
- (void)resetVariableData
{
    NSLog(@"");
    if (self.currentPhoneNumber) {
        self.currentPhoneNumber = nil;
    }
    if (self.currentUUID) {
        self.currentUUID = nil;
    }
    self.currentIsVideo = false;
}


#pragma mark - CXCallObserverDelegate

- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call
{
    NSLog(@"CallKit--callChanged--callObserver:::%ld----call.isOnHold---:::%d--call.isOutgoing--:::%d--call.hasConnected--:::%d---call.hasEnded--:::%d",callObserver.calls.count,call.isOnHold,call.isOutgoing,call.hasConnected,call.hasEnded);
    
    if (self.currentUUID)
    {
        if (callObserver.calls.count > 1) {
            self.hasOtherCall = true;
        }
        else
        {
            self.hasOtherCall = false;
        }
        if ([call.UUID.UUIDString isEqualToString:self.currentUUID.UUIDString]) {
            //当前通话
            if (call.hasEnded) {
                // 通话结束
                NSLog(@"call ended");
            }
            
            if (call.isOutgoing) {
                NSLog(@"call out ...");
            }
            
            if (call.isOnHold) {
                NSLog(@"isOnHold");
            }
            
        }
        
    }
    else
    {
        if (callObserver.calls.count > 0) {
            self.hasOtherCall = true;
        }
        else
        {
            self.hasOtherCall = false;
        }
    }
    
}

#pragma mark - setter
- (CXProviderConfiguration *)configuration
{
    NSLog(@"");
    if (!_configuration) {
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        if(appName.length == 0)
        {
            appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        }
        _configuration = [[CXProviderConfiguration alloc] initWithLocalizedName:appName];
        //_configuration.supportedHandleTypes = [[NSSet alloc] initWithObjects:@(CXHandleTypePhoneNumber), nil];
        UIImage *appIcon = [UIImage imageNamed: @"callkitLogo"];
        _configuration.iconTemplateImageData = UIImagePNGRepresentation(appIcon);
        _configuration.maximumCallGroups = 0;
        _configuration.supportsVideo = YES;
    }
    return _configuration;
}

- (CXCallUpdate *)callUpdate
{
    NSLog(@"");
    if (!_callUpdate) {
        _callUpdate = [CXCallUpdate new];
        _callUpdate.supportsHolding = NO;
    }
    return _callUpdate;
}

- (CXCallController *)callController
{
    NSLog(@"");
    if (!_callController) {
        _callController = [[CXCallController alloc] init];
    }
    return _callController;
}
@end
