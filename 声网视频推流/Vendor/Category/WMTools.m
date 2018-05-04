//
//  WMTools.m
//  声网视频推流
//
//  Created by Facebook on 2018/5/4.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "WMTools.h"

@implementation WMTools

+ (NSString *)getTalkTimeStringForTime:(long)time {
    if (time < 60 * 60) {
        return [NSString stringWithFormat:@"%02ld:%02ld", time / 60, time % 60];
    } else {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", time / 60 / 60, (time / 60) % 60, time % 60];
    }
}

@end
