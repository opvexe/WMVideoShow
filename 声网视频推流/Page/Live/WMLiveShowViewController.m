//
//  WMLiveShowViewController.m
//  声网视频推流
//
//  Created by Facebook on 2018/4/26.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "WMLiveShowViewController.h"
#import "WMCommonDefines.h"
#import "WMCertificateToken.h"
#import "WMCallVideoKey.h"
#import <AgoraRtcEngineKit/AgoraLiveKit.h>
#import <AgoraRtcEngineKit/AgoraLivePublisher.h>
#import "WMClientSignal.h"

@interface WMLiveShowViewController ()<AgoraRtcEngineDelegate,AgoraLivePublisherDelegate,AgoraLiveDelegate>
@property(nonatomic,strong)AgoraAPI *signalEngine;
@property(nonatomic,strong)AgoraRtcEngineKit *rtcEngine;
@property(nonatomic,strong)AgoraLiveKit *livekit;
@property(nonatomic,strong)AgoraLivePublisher *publisher;

@property(nonatomic, strong) AVAudioPlayer *audioPlayer;
@property(nonatomic, assign) BOOL needPlayingAlertAfterForeground;
@property(nonatomic, assign) BOOL needPlayingRingAfterForeground;

@property(nonatomic,strong)UIView *localVideoView; ///远程视图
@property(nonatomic,strong)UIView *miniContentView; ///本地视图
@property(nonatomic,strong)UIButton *miniBT;    ///缩小放大按钮
@property(nonatomic,strong)UIButton *speakerBT; ///扬声器
@property(nonatomic,strong)UIButton *swicthBT;  ///摄像头
@property(nonatomic,strong)UIButton *muteBT;    ///静音
@property(nonatomic,strong)UIButton *acceptBT; ///接听
@property(nonatomic,strong)UIButton *hangUpBT; ///挂断
@property(nonatomic,strong)UILabel *tipLabel; ///接听提示

@property(nonatomic,strong)NSMutableDictionary *messagePamar;
@property(nonatomic,strong)NSTimer *activeTimer;
@property(nonatomic,assign)long secTime;

@end

@implementation WMLiveShowViewController

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self stopActiveTimer];
    [self leaveChannel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self updateViewConstraintsView];
    [self loadSignalEngine];
    [self updateView:self.status];
    [self registerForegroundNotification];
    self.secTime = 0;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _signalEngine.onError = nil;
    _signalEngine.onQueryUserStatusResult = nil;
    _signalEngine.onInviteReceivedByPeer = nil;
    _signalEngine.onInviteFailed = nil;
    _signalEngine.onInviteAcceptedByPeer = nil;
    _signalEngine.onInviteRefusedByPeer = nil;
    _signalEngine.onInviteEndByPeer = nil;
}

#pragma mark 注册通知
- (void)registerForegroundNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

#pragma mark  Agora Media SDK
- (void)loadMediaEngine {
    self.livekit = [AgoraLiveKit  sharedLiveKitWithAppId:Agora_AppId];
    self.livekit.delegate  = self;
    self.rtcEngine = self.livekit.getRtcEngineKit;
    [self.rtcEngine setAudioProfile:AgoraAudioProfileDefault scenario:AgoraAudioScenarioDefault];
    [self.rtcEngine enableDualStreamMode:YES];
    self.publisher = [[AgoraLivePublisher alloc] initWithLiveKit:_livekit];
    [self.publisher setDelegate:self];
}

-(void)sendInviteRequest{
    NSDictionary *extraDic = @{@"_require_peer_online": @(1)};
    [_signalEngine channelInviteUser2:self.channelName account:self.remoteAccount extra:[NSString dictionaryToJson:extraDic]];
}

/**
 * 加载本地视频
 */
- (void)startLocalVideo {
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = self.localAccount.integerValue;
    videoCanvas.view = self.localVideoView;
    videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    [_rtcEngine setupLocalVideo:videoCanvas];
    [_rtcEngine setClientRole:AgoraClientRoleBroadcaster];
    [_publisher setVideoResolution:videoCanvas.view.frame.size andFrameRate:30 bitrate:1000];
}


#pragma mark 推流
- (void)liveKit:(AgoraLiveKit *_Nonnull)kit didJoinChannel:(NSString *_Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed{
    [_publisher addStreamUrl:@"rtmp://5477.livepush.myqcloud.com/live/5477_78?bizid=5477&txSecret=8424864bee14d8e15dceb6365436d1e7&txTime=5AE73D7F" transcodingEnabled:NO];
    [_publisher publish];
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = uid;
    videoCanvas.view = self.miniContentView;
    videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    [_rtcEngine setupRemoteVideo:videoCanvas];
    [_livekit startPreview:self.miniContentView renderMode:AgoraVideoRenderModeHidden];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)liveKit:(AgoraLiveKit *_Nonnull)kit didRejoinChannel:(NSString *_Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed{
    
}

- (void)liveKitDidLeaveChannel:(AgoraLiveKit *_Nonnull)kit{
    
}

#pragma AgoraLivePublisherDelegate
-(void)publisher:(AgoraLivePublisher *_Nonnull)publisher streamPublishedWithUrl:(NSString *_Nonnull)url error:(AgoraErrorCode)error{
    
}
-(void)publisher:(AgoraLivePublisher *_Nonnull)publisher streamUnpublishedWithUrl:(NSString *_Nonnull)url{
    
}
-(void)publisherTranscodingUpdated: (AgoraLivePublisher *_Nonnull)publisher{
    
}

-(void)publisher:(AgoraLivePublisher *_Nonnull)publisher publishingRequestReceivedFromUid:(NSUInteger)uid{
    
}

-(void)publisher:(AgoraLivePublisher *_Nonnull)publisher streamInjectedStatusOfUrl:(NSString *_Nonnull)url uid:(NSUInteger)uid status:(AgoraInjectStreamStatus)status{
    
    
}

#pragma mark 信令
- (void)loadSignalEngine {
    
    WS(weakSelf)
    _signalEngine = [WMClientSignal sharedCallClientSignal].callAgoraApi;
    
    _signalEngine.onLogout = ^(AgoraEcode ecode) {
        
        NSLog(@"信令退出登录");
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *presentedVC = weakSelf.presentedViewController;
            if (weakSelf.presentedViewController) {
                [weakSelf dismissViewControllerAnimated:NO completion:nil];
                if ([presentedVC isMemberOfClass:[WMLiveShowViewController class]]) {
                    [weakSelf leaveChannel];
                }
            }
            [weakSelf.navigationController popViewControllerAnimated:NO];
        });
    };
    
    _signalEngine.onError = ^(NSString *name, AgoraEcode ecode, NSString *desc) {
        
        NSLog(@"错误回调:%@",desc);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        });
    };
    
    _signalEngine.onQueryUserStatusResult = ^(NSString *name, NSString *status) {
        
        NSLog(@"查询对方在线状态");
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([status intValue] == 0) {
                weakSelf.tipLabel.text = @"对方不在线";
                [weakSelf leaveChannel];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf dismissViewControllerAnimated:NO completion:nil];
                });
            }else{
                [weakSelf loadMediaEngine];
                [weakSelf startLocalVideo];
                [weakSelf sendInviteRequest];
            }
        });
    };
    
    _signalEngine.onInviteReceivedByPeer = ^(NSString *channelID, NSString *account, uint32_t uid) {
        
        NSLog(@"邀请对方视频会话回调");
        if (![channelID isEqualToString:self.channelName] || ![account isEqualToString:self.remoteAccount]) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf shouldAlertForWaitingRemoteResponse];
        });
    };
    
    _signalEngine.onInviteFailed = ^(NSString *channelID, NSString *account, uint32_t uid, AgoraEcode ecode, NSString *extra) {
        
        NSLog(@"邀请对方视频会话失败");
        if (![channelID isEqualToString:self.channelName] || ![account isEqualToString:self.remoteAccount]) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf leaveChannel];
            [weakSelf dismissViewControllerAnimated:NO completion:nil];
        });
    };
    
    _signalEngine.onInviteAcceptedByPeer = ^(NSString *channelID, NSString *account, uint32_t uid, NSString *extra) {
        
        NSLog(@"对方接受视频会话");
        if (![channelID isEqualToString:self.channelName] || ![account isEqualToString:self.remoteAccount]) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^() {
            [weakSelf joinChannel];
            [weakSelf stopPlayRing];
        });
    };
    
    _signalEngine.onInviteRefusedByPeer = ^(NSString *channelID, NSString *account, uint32_t uid, NSString *extra) {
        
        NSLog(@"对方拒绝视频会话");
        if (![channelID isEqualToString:self.channelName] || ![account isEqualToString:self.remoteAccount]) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            [weakSelf leaveChannel];
            NSData *data = [extra dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if ([dic[@"status"] intValue] == 1) {
                weakSelf.tipLabel.text = @"对方拒绝视频会话";
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf dismissViewControllerAnimated:NO completion:nil];
                });
            }else{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf dismissViewControllerAnimated:NO completion:nil];
                });
            }
        });
    };
    
    _signalEngine.onInviteEndByPeer = ^(NSString *channelID, NSString *account, uint32_t uid, NSString *extra) {
        
        NSLog(@"对方结束视频会话");
        if (![channelID isEqualToString:self.channelName] || ![account isEqualToString:self.remoteAccount]) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            weakSelf.tipLabel.text = @"结束视频会话";
            [weakSelf leaveChannel];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf dismissViewControllerAnimated:NO completion:nil];
            });
        });
    };
}

#pragma mark 加入房间
- (void)joinChannel{
    unsigned expiredTime = (unsigned) [[NSDate date] timeIntervalSince1970] + 3600;
    NSString * key = [WMCallVideoKey createMediaKeyByAppID:Agora_AppId
                                            appCertificate:Agora_Certificate
                                               channelName:self.channelName
                                                    unixTs:(unsigned)time(NULL)
                                                 randomInt:(rand()%256 << 24) + (rand()%256 << 16) + (rand()%256 << 8) + (rand()%256)
                                                       uid:0
                                                 expiredTs:expiredTime];
    
    int result = [_livekit joinChannelByToken:key channelId:self.channelName config:[AgoraLiveChannelConfig defaultConfig] uid:self.remoteAccount.integerValue];
    if (result != AgoraEcode_SUCCESS) {
        [_signalEngine channelInviteEnd:self.channelName account:self.remoteAccount uid:0];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark  离开房间
-(void)leaveChannel{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self stopPlayRing];
    [_livekit stopPreview];
    [_livekit leaveChannel];
    [_publisher unpublish];
    [_signalEngine channelInviteEnd:self.channelName account:self.remoteAccount uid:0];
    _rtcEngine = nil;
}

///MARK: 初始化视图
-(void)updateViewConstraintsView{
    
    _localVideoView = ({
        UIView *iv = [[UIView alloc]init];
        iv.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:iv];
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
        iv;
    });
    
    _miniContentView = ({
        UIView *iv = [[UIView alloc]init];
        iv.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:iv];
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 180));
            make.right.mas_equalTo(-13);
            make.top.mas_equalTo(32);
        }];
        iv;
    });
    
    _miniBT = ({
        UIButton *iv =[UIButton buttonWithType:UIButtonTypeCustom];
        [iv setImage:LSWMImageNamed(@"minimize.png") forState:UIControlStateNormal];
        [iv setImage:LSWMImageNamed(@"minimize.png") forState:UIControlStateHighlighted];
        [iv setImage:LSWMImageNamed(@"minimize.png") forState:UIControlStateSelected];
        [iv setImage:LSWMImageNamed(@"minimize.png") forState:UIControlStateDisabled];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        [iv addTarget:self action:@selector(miniAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:iv];
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(22, 22));
            make.left.mas_equalTo(20);
            make.top.mas_equalTo(self.miniContentView.mas_top);
        }];
        iv;
    });
    
    _hangUpBT = ({
        UIButton *iv =[UIButton buttonWithType:UIButtonTypeCustom];
        [iv setImage:LSWMImageNamed(@"hang_up.png") forState:UIControlStateNormal];
        [iv setImage:LSWMImageNamed(@"hang_up.png") forState:UIControlStateHighlighted];
        [iv setImage:LSWMImageNamed(@"hang_up_hover.png") forState:UIControlStateSelected];
        [iv setImage:LSWMImageNamed(@"hang_up.png") forState:UIControlStateDisabled];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        iv.titleLabel.font   = [UIFont systemFontOfSize:12.0];
        [iv setTitle:@"拒绝" forState:UIControlStateNormal];
        [iv setTitle:@"拒绝" forState:UIControlStateHighlighted];
        [iv setTitle:@"拒绝" forState:UIControlStateSelected];
        [iv setTitle:@"拒绝" forState:UIControlStateDisabled];
        [iv addTarget:self action:@selector(hangUp:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:iv];
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(64.0f, 64.0f));
            make.centerX.mas_equalTo(self.view);
            make.bottom.mas_equalTo(-30);
        }];
        iv;
    });
    
    _acceptBT = ({
        UIButton *iv =[UIButton buttonWithType:UIButtonTypeCustom];
        [iv setImage:LSWMImageNamed(@"answer.png") forState:UIControlStateNormal];
        [iv setImage:LSWMImageNamed(@"answer.png") forState:UIControlStateHighlighted];
        [iv setImage:LSWMImageNamed(@"answer_hover.png") forState:UIControlStateSelected];
        [iv setImage:LSWMImageNamed(@"answer.png") forState:UIControlStateDisabled];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        iv.titleLabel.font   = [UIFont systemFontOfSize:12.0];
        [iv setTitle:@"接听" forState:UIControlStateNormal];
        [iv setTitle:@"接听" forState:UIControlStateHighlighted];
        [iv setTitle:@"接听" forState:UIControlStateSelected];
        [iv setTitle:@"接听" forState:UIControlStateDisabled];
        [iv addTarget:self action:@selector(acceptButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:iv];
        iv;
    });
    
    _muteBT = ({
        UIButton *iv =[UIButton buttonWithType:UIButtonTypeCustom];
        [iv setImage:LSWMImageNamed(@"mute.png") forState:UIControlStateNormal];
        [iv setImage:LSWMImageNamed(@"mute.png") forState:UIControlStateHighlighted];
        [iv setImage:LSWMImageNamed(@"mute_hover.png") forState:UIControlStateSelected];
        [iv setImage:LSWMImageNamed(@"mute.png") forState:UIControlStateDisabled];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        iv.titleLabel.font   = [UIFont systemFontOfSize:12.0];
        [iv setTitle:@"静音" forState:UIControlStateNormal];
        [iv setTitle:@"静音" forState:UIControlStateHighlighted];
        [iv setTitle:@"静音" forState:UIControlStateSelected];
        [iv setTitle:@"静音" forState:UIControlStateDisabled];
        [iv addTarget:self action:@selector(mutePressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:iv];
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.hangUpBT);
            make.height.mas_equalTo(self.hangUpBT);
            make.left.mas_equalTo(self.view).offset(25);
            make.bottom.mas_equalTo(self.hangUpBT.mas_top).mas_offset(-50);
        }];
        iv;
    });
    
    _speakerBT = ({
        UIButton *iv =[UIButton buttonWithType:UIButtonTypeCustom];
        [iv setImage:LSWMImageNamed(@"handfree.png") forState:UIControlStateNormal];
        [iv setImage:LSWMImageNamed(@"handfree.png") forState:UIControlStateHighlighted];
        [iv setImage:LSWMImageNamed(@"handfree_hover.png") forState:UIControlStateSelected];
        [iv setImage:LSWMImageNamed(@"handfree.png") forState:UIControlStateDisabled];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        iv.titleLabel.font   = [UIFont systemFontOfSize:12.0];
        [iv setTitle:@"扬声器" forState:UIControlStateNormal];
        [iv setTitle:@"扬声器" forState:UIControlStateHighlighted];
        [iv setTitle:@"扬声器" forState:UIControlStateSelected];
        [iv setTitle:@"扬声器" forState:UIControlStateDisabled];
        [iv addTarget:self action:@selector(speakerPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:iv];
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.hangUpBT);
            make.height.mas_equalTo(self.hangUpBT);
            make.centerX.mas_equalTo(self.view);
            make.top.mas_equalTo(self.muteBT.mas_top);
        }];
        iv;
    });
    
    _swicthBT = ({
        UIButton *iv =[UIButton buttonWithType:UIButtonTypeCustom];
        [iv setImage:LSWMImageNamed(@"camera.png") forState:UIControlStateNormal];
        [iv setImage:LSWMImageNamed(@"camera.png") forState:UIControlStateHighlighted];
        [iv setImage:LSWMImageNamed(@"camera_hover.png") forState:UIControlStateSelected];
        [iv setImage:LSWMImageNamed(@"camera.png") forState:UIControlStateDisabled];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [iv setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        iv.titleLabel.font   = [UIFont systemFontOfSize:12.0];
        [iv setTitle:@"切换摄像头" forState:UIControlStateNormal];
        [iv setTitle:@"切换摄像头" forState:UIControlStateHighlighted];
        [iv setTitle:@"切换摄像头" forState:UIControlStateSelected];
        [iv setTitle:@"切换摄像头" forState:UIControlStateDisabled];
        [iv addTarget:self action:@selector(doSwitchCameraPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:iv];
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.hangUpBT);
            make.height.mas_equalTo(self.hangUpBT);
            make.right.mas_equalTo(self.view).offset(-25);
            make.top.mas_equalTo(self.muteBT.mas_top);
        }];
        iv;
    });
    
    _tipLabel = ({
        UILabel *iv = [[UILabel alloc]init];
        iv.textColor  = [UIColor whiteColor];
        iv.font = [UIFont systemFontOfSize:16];
        [self.view addSubview:iv];
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.speakerBT.mas_top).mas_offset(-50);
        }];
        iv;
    });
}

- (void)layoutTextUnderImageButton:(UIButton *)button {
    button.titleEdgeInsets = UIEdgeInsetsMake(0, -button.imageView.frame.size.width,
                                              -button.imageView.frame.size.height - 5.0f, 0);
    button.imageEdgeInsets = UIEdgeInsetsMake(-button.titleLabel.intrinsicContentSize.height - 5.0f, 0, 0,
                                              -button.titleLabel.intrinsicContentSize.width);
}

///MARK: 根据状态更新视图
-(void)updateView:(CallStatus)stats{
    
    switch (stats) {
        case CallDialing:{  ///拨号
            self.swicthBT.hidden = NO;
            self.muteBT.hidden = NO;
            self.speakerBT.hidden = NO;
            self.hangUpBT.hidden = NO;
            self.acceptBT.hidden = YES;
            self.hangUpBT.selected  =YES;
            self.miniBT.hidden = YES;
            self.miniContentView.hidden = YES;
            
            self.tipLabel.text = @"等待接听";
            [_signalEngine queryUserStatus:self.remoteAccount];
            [self shouldAlertForWaitingRemoteResponse];
        }
            break;
        case CallRinging:{  ///呼叫
            
            self.swicthBT.hidden = NO;
            self.muteBT.hidden = NO;
            self.speakerBT.hidden = NO;
            self.acceptBT.hidden = NO;
            self.hangUpBT.hidden = NO;
            self.hangUpBT.selected  =NO;
            self.miniBT.hidden = YES;
            self.miniContentView.hidden = YES;
            
            self.tipLabel.text = [NSString stringWithFormat:@"%@呼叫你",self.remoteAccount];
            [self shouldRingForIncomingCall];
            [self.hangUpBT mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(64.0f, 64.0f));
                make.left.mas_equalTo(33);
                make.bottom.mas_equalTo(-30);
            }];
            
            [self.acceptBT mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(64.0f, 64.0f));
                make.right.mas_equalTo(-33);
                make.bottom.mas_equalTo(self.hangUpBT);
            }];
            
        }
            break;
        case CallActive:{ ///接听中
            
            self.swicthBT.hidden = NO;
            self.muteBT.hidden = NO;
            self.speakerBT.hidden = NO;
            self.hangUpBT.hidden = NO;
            self.acceptBT.hidden = YES;
            self.hangUpBT.selected  =YES;
            self.miniBT.hidden = NO;
            self.miniContentView.hidden = NO;
            
            [self startActiveTimer];
            [self stopPlayRing];
            [self.hangUpBT mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(64.0f, 64.0f));
                make.centerX.mas_equalTo(self.view);
                make.bottom.mas_equalTo(-30);
            }];
            
        }
            break;
        default:
            break;
    }
    [self layoutTextUnderImageButton:self.acceptBT];
    [self layoutTextUnderImageButton:self.hangUpBT];
    [self layoutTextUnderImageButton:self.swicthBT];
    [self layoutTextUnderImageButton:self.muteBT];
    [self layoutTextUnderImageButton:self.speakerBT];
}

///MARK: 点击事件
-(void)miniAction:(UIButton *)sender{
    
}

-(void)doSwitchCameraPressed:(UIButton *)sender{
    sender.selected = !sender.selected;
    [_rtcEngine switchCamera];
}
-(void)hangUp:(UIButton *)sender{
    
    if (self.acceptBT) {   ///被别人呼叫
        NSDictionary *extraDic = @{@"status": @(0)};
        [_signalEngine channelInviteRefuse:self.channelName account:self.remoteAccount uid:0 extra:[NSString dictionaryToJson:extraDic]];
        [self stopPlayRing];
    }else{              ///呼叫状态挂断电话
        [_signalEngine channelInviteEnd:self.channelName account:self.remoteAccount uid:0];
        [self leaveChannel];
    }
    
    [self dismissViewControllerAnimated:NO completion:nil];
}
-(void)acceptButtonClicked:(UIButton *)sender{
    [self updateView:CallActive];
    [self joinChannel];
    [_signalEngine channelInviteAccept:self.channelName account:self.remoteAccount uid:0 extra:@""];
}

-(void)mutePressed:(UIButton *)sender{
    sender.selected = !sender.selected;
    [_rtcEngine muteLocalAudioStream:sender.selected];
}

-(void)speakerPressed:(UIButton *)sender{
    sender.selected = !sender.selected;
    [_rtcEngine setEnableSpeakerphone:sender.selected];
}


///MARK: 开启定时器
- (void)startActiveTimer {
    self.activeTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                        target:self
                                                      selector:@selector(updateActiveTimer)
                                                      userInfo:nil
                                                       repeats:YES];
    [self.activeTimer fire];
    
}
-(void)updateActiveTimer{
    WS(weakSelf)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.secTime++;
        weakSelf.tipLabel.text = [WMTools getTalkTimeStringForTime:weakSelf.secTime];
    });
}
- (void)stopActiveTimer {
    if (self.activeTimer) {
        [self.activeTimer invalidate];
        self.activeTimer = nil;
        [self.messagePamar setObject:self.tipLabel.text forKey:@"durationStr"];
        [self.messagePamar setObject:@(self.secTime) forKey:@"duration"];
        [self.messagePamar setValue:[NSString stringWithFormat:@"视频通话时长:%@",self.tipLabel.text] forKey:@"content"];
    }
}
-(NSMutableDictionary *)messagePamar{
    if (!_messagePamar) {
        
        _messagePamar= [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _messagePamar;
}

#pragma mark 响铃
///MARK: 开始播放铃声
- (void)startPlayRing:(NSString *)ringPath {
    if (ringPath) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        //默认情况下扬声器播放
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
        
        if (self.audioPlayer) {
            [self stopPlayRing];
        }
        
        NSURL *url = [NSURL fileURLWithPath:ringPath];
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if (!error) {
            self.audioPlayer.numberOfLoops = -1;
            self.audioPlayer.volume = 1.0;
            [self.audioPlayer prepareToPlay];
            [self.audioPlayer play];
        }
    }
}

///MARK: 停止播放铃声
- (void)stopPlayRing {
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
        //设置铃声停止后恢复其他app的声音
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                             error:nil];
    }
}

///MARK: 停止播放铃声(通话接通或挂断)
- (void)shouldStopAlertAndRing {
    self.needPlayingRingAfterForeground = NO;
    self.needPlayingAlertAfterForeground = NO;
    [self stopPlayRing];
}
///MARK: 接听响铃
- (void)shouldRingForIncomingCall {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        NSString *ringPath =  [[NSBundle mainBundle] pathForResource:@"voip_call" ofType:@"mp3"];
        [self startPlayRing:ringPath];
        self.needPlayingRingAfterForeground = NO;
    } else {
        self.needPlayingRingAfterForeground = YES;
    }
}

///MARK: 拨打响铃
- (void)shouldAlertForWaitingRemoteResponse {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        NSString *ringPath = [[NSBundle mainBundle] pathForResource:@"voip_calling_ring" ofType:@"mp3"];
        [self startPlayRing:ringPath];
        self.needPlayingAlertAfterForeground = NO;
    } else {
        self.needPlayingAlertAfterForeground = YES;
    }
}

- (void)appDidBecomeActive {
    if (self.needPlayingAlertAfterForeground) {
        [self shouldAlertForWaitingRemoteResponse];
    } else if (self.needPlayingRingAfterForeground) {
        [self shouldRingForIncomingCall];
    }
}

- (void)addProximityMonitoringObserver {
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(proximityStatueChanged:)
                                                 name:UIDeviceProximityStateDidChangeNotification
                                               object:nil];
}
- (void)removeProximityMonitoringObserver {
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceProximityStateDidChangeNotification
                                                  object:nil];
}
- (void)proximityStatueChanged:(NSNotificationCenter *)notification {
    if ([UIDevice currentDevice].proximityState) {
        [[AVAudioSession sharedInstance]
         setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        [[AVAudioSession sharedInstance]
         setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

@end

