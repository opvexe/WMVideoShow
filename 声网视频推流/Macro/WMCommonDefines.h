//
//  WMCommonDefines.h
//  声网视频推流
//
//  Created by Facebook on 2018/4/26.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#ifndef WMCommonDefines_h
#define WMCommonDefines_h

///MARK: 第三方
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
#import <AgoraSigKit/AgoraSigKit.h>
#import <Masonry.h>
#import "NSString+WMCategory.h"
#import "WMTools.h"

///MARK: 测试
#define Agora_AppId @"58c851bd26754702a3381a8e8dc67097"
#define Agora_Certificate @"1c605d2441cb4460984f0160e7f36367"

///MARK: 防止循环引用
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define WSSTRONG(strongSelf) __strong typeof(weakSelf) strongSelf = weakSelf;


#define  LSWMImageNamed(imageName)   [UIImage imageNamed:imageName]

#endif /* WMCommonDefines_h */
