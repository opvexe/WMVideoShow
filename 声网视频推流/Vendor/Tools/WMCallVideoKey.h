//
//  WMCallVideoKey.h
//  声网视频推流
//
//  Created by Facebook on 2018/4/26.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMCallVideoKey : NSObject

+ (NSString *) createMediaKeyByAppID:(NSString*)appID
                      appCertificate:(NSString*)appCertificate
                         channelName:(NSString*)channelName
                              unixTs:(uint32_t)unixTs
                           randomInt:(uint32_t)randomInt
                                 uid:(uint32_t)uid
                           expiredTs:(uint32_t)expiredTs
;

@end
