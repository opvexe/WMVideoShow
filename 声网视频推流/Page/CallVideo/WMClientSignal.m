//
//  WMCallClientSignal.m
//  声网视频推流
//
//  Created by Facebook on 2018/5/4.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "WMClientSignal.h"
#import "WMCertificateToken.h"
#import "WMLiveShowViewController.h"

@interface WMClientSignal()<AgoraRtcEngineDelegate,AgoraRtcEngineDelegate>
@property(nonatomic,strong)AgoraAPI *callAgoraApi;
@property(nonatomic, strong) NSMutableArray *callWindows;
@end
@implementation WMClientSignal

+ (instancetype)sharedCallClientSignal{
    static dispatch_once_t onceToken;
    static WMClientSignal *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WMClientSignal alloc] init];
        instance.callWindows = [NSMutableArray arrayWithCapacity:0];
    });
    return instance;
}

-(instancetype)init{
    if (self  =[super init]) {
        [self initCallAgoraApi];
    }
    return self;
}

-(void)initCallAgoraApi{
    self.callAgoraApi = [AgoraAPI getInstanceWithoutMedia:Agora_AppId];
    [self setupCallAgoraAPi];
}

-(void)setupCallAgoraAPi{
    
    WS(weakSelf)
    self.callAgoraApi.onLoginSuccess = ^(uint32_t uid, int fd) {
        NSLog(@"信令登录成功");
    };
    
    self.callAgoraApi.onLog = ^(NSString *text) {
        NSLog(@"打印日志:%@", text);
    };
    
    self.callAgoraApi.onMessageSendSuccess = ^(NSString *messageID) {
        NSLog(@"消息ID:%@", messageID);
    };
    self.callAgoraApi.onMessageSendError = ^(NSString *messageID, AgoraEcode ecode) {
        
        NSLog(@"消息发送失败回调：%@", messageID);
    };

    self.callAgoraApi.onReconnecting = ^(uint32_t nretry) {
        
        NSLog(@"连接丢失回调:%d",nretry);
    };

    self.callAgoraApi.onError = ^(NSString *name, AgoraEcode ecode, NSString *desc) {
        NSLog(@"出错回调:%@",desc);
    };

    self.callAgoraApi .onChannelLeaved = ^(NSString *channelID, AgoraEcode ecode) {
        
        NSLog(@"离开频道回调:%@",channelID);
    };

    self.callAgoraApi .onChannelUserList = ^(NSMutableArray *accounts, NSMutableArray *uids) {
        NSLog(@"频道用户列表%@==%@", accounts,uids);
    };

    
    //MARK:收到呼叫邀请回调
    self.callAgoraApi.onInviteReceived = ^(NSString *channelID, NSString *account, uint32_t uid, NSString *extra) {
        
         NSLog(@"收到呼叫邀请回调");
        dispatch_async(dispatch_get_main_queue(), ^{
            WMLiveShowViewController *roomController = [[WMLiveShowViewController alloc]init];
            BOOL isPresentCallViewController = NO;
            for (UIWindow *window in weakSelf.callWindows) {
                if ([window.rootViewController isKindOfClass:[WMLiveShowViewController class]]) {
                    isPresentCallViewController = YES;
                    break;
                }
            }
            if (!isPresentCallViewController) {
                
                roomController.status = CallRinging;
                [weakSelf presentCallViewController:roomController];
            }else{
                NSDictionary *extraDic = @{@"status": @(1)};
                [weakSelf.callAgoraApi channelInviteRefuse:channelID account:account uid:0 extra:[NSString dictionaryToJson:extraDic]];
            }
        });
    };
}

-(void)login{
    NSString *account = @"1";
    unsigned expiredTime = (unsigned) [[NSDate date] timeIntervalSince1970] + 3600;
    NSString *token = [WMCertificateToken SignalingKeyByAppId:Agora_AppId
                                                  Certificate:Agora_Certificate
                                                      Account:account
                                                  ExpiredTime:expiredTime];
    [self.callAgoraApi login:Agora_AppId account:account token:token uid:0 deviceID:nil];
}


-(void)logout{
    [self.callAgoraApi logout];
    self.callAgoraApi.onLoginSuccess = nil;
    self.callAgoraApi.onLoginFailed = nil;
}


-(void)onLoginFailed:(void(^)(AgoraEcode ecode))failed{
    self.callAgoraApi.onLoginFailed = ^(AgoraEcode ecode) {
        if (failed) {
            failed(ecode);
        }
    };
}


- (void)presentCallViewController:(UIViewController *)viewController {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    UIWindow *activityWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    activityWindow.windowLevel = UIWindowLevelAlert;
    activityWindow.rootViewController = viewController;
    [activityWindow makeKeyAndVisible];
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    animation.type = kCATransitionMoveIn;     //可更改为其他方式
    animation.subtype = kCATransitionFromTop; //可更改为其他方式
    [[activityWindow layer] addAnimation:animation forKey:nil];
    [self.callWindows addObject:activityWindow];
}

- (void)dismissCallViewController:(UIViewController *)viewController {
    
    if ([viewController isKindOfClass:[UIViewController class]]) {
        UIViewController *rootVC = viewController;
        while (rootVC.parentViewController) {
            rootVC = rootVC.parentViewController;
        }
        viewController = rootVC;
    }
    
    for (UIWindow *window in self.callWindows) {
        if (window.rootViewController == viewController) {
            [window resignKeyWindow];
            window.hidden = YES;
            [[UIApplication sharedApplication].delegate.window makeKeyWindow];
            [self.callWindows removeObject:window];
            break;
        }
    }
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end

