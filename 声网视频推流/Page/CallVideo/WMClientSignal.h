//
//  WMCallClientSignal.h
//  声网视频推流
//
//  Created by Facebook on 2018/5/4.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMClientSignal : NSObject

@property(nonatomic,readonly,strong)AgoraAPI *callAgoraApi;

+ (instancetype)sharedCallClientSignal;

-(void)login;

-(void)logout;

-(void)onLoginFailed:(void(^)(AgoraEcode ecode))failed;

- (void)presentCallViewController:(UIViewController *)viewController;

- (void)dismissCallViewController:(UIViewController *)viewController;

@end
