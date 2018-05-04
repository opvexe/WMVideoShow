//
//  ViewController.m
//  声网视频推流
//
//  Created by Facebook on 2018/4/26.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "WMSignLoginViewController.h"
#import "WMLiveShowViewController.h"
#import "WMCommonDefines.h"
#import "WMCertificateToken.h"
#import "WMClientSignal.h"

@interface WMSignLoginViewController ()
{
    AgoraAPI *_signalEngine;
}
@property(nonatomic,strong)UITextField *CallTF;
@property(nonatomic,strong)UIButton *loginBT;
@end

@implementation WMSignLoginViewController

static NSString *channelRoom = @"ChannelRoom";  ///房间名

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"信令登录";
    NSLog(@"SDK版本:%@",[AgoraRtcEngineKit getSdkVersion]);
    [[WMClientSignal sharedCallClientSignal]login];
    [self initWithSubViews];
}

-(void)initWithSubViews{
    
    _CallTF = ({
        UITextField *iv = [[UITextField alloc] init];
        iv.placeholder = @"呼叫ID";
        iv.textAlignment = NSTextAlignmentCenter;
        iv.layer.borderColor = [UIColor redColor].CGColor;
        iv.layer.masksToBounds = YES;
        iv.layer.borderWidth = 1.0f;
        [self.view addSubview:iv];
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(40);
            make.right.mas_equalTo(-40);
            make.centerY.mas_equalTo(self.view.mas_centerY);
            make.height.mas_equalTo(40);
        }];
        iv;
    });
    
    _loginBT = ({
        UIButton *iv = [UIButton buttonWithType:UIButtonTypeCustom];
        [iv setTitle:@"进入直播频道" forState:UIControlStateNormal];
        [iv setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        iv.layer.borderColor = [UIColor redColor].CGColor;
        iv.layer.masksToBounds = YES;
        iv.layer.borderWidth = 1.0f;
        [iv addTarget:self action:@selector(Click:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:iv];
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(40);
            make.right.mas_equalTo(-40);
            make.height.mas_equalTo(40);
            make.top.mas_equalTo(self.CallTF.mas_bottom).mas_equalTo(20);
        }];
        iv;
    });
}


///MARK: 登录
-(void)Click:(UIButton *)sender{
    dispatch_async(dispatch_get_main_queue(), ^{
        WMLiveShowViewController *controller = [[WMLiveShowViewController alloc] init];
        controller.remoteAccount = self.CallTF.text;
        controller.localAccount = @"1"; ///本地用户ID
        controller.channelName =channelRoom;
        controller.status = CallDialing;
        [self presentViewController:controller animated:YES completion:nil];
    });
}

@end

