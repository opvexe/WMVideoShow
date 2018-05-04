//
//  WMSignKeyCenter.h
//  声网视频推流
//
//  Created by Facebook on 2018/4/26.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMCertificateToken : NSObject

/**
 * 登录数据签名
 */
+ (NSString *)SignalingKeyByAppId: (NSString *) appId Certificate:(NSString *)certificate Account:(NSString*)account ExpiredTime:(unsigned)expiredTime;

/**
 * 获取当前账号
 */
+ (NSString *)account;

@end
