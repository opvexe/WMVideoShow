//
//  WMLiveShowViewController.h
//  声网视频推流
//
//  Created by Facebook on 2018/4/26.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

/*！
 * 视频通话 + 直播
 */

typedef NS_ENUM(NSUInteger, CallStatus) {
    /*!
     正在呼出
     */
    CallDialing,
    /*!
     正在呼入
     */
    CallIncoming,
    /*!
     收到一个通话呼入后，正在振铃
     */
    CallRinging,
    /*!
     正在通话
     */
    CallActive,
    /*!
     已经挂断
     */
    CallHangup
};

@interface WMLiveShowViewController : UIViewController

/*！
 * 本地用户
 */
@property (copy, nonatomic) NSString *localAccount;
/*！
 * 远程用户
 */
@property (copy, nonatomic) NSString *remoteAccount;
/*！
 * 房间名
 */
@property (copy, nonatomic) NSString *channelName;
/*！
 * 呼叫状态
 */
@property(nonatomic,assign)CallStatus status;

@end
