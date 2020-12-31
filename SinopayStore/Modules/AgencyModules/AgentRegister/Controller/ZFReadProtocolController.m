//
//  ZFReadProtocolController.m
//  Agent
//
//  Created by 中付支付 on 2018/10/26.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFReadProtocolController.h"

@interface ZFReadProtocolController ()

@end

@implementation ZFReadProtocolController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"用户协议", nil);
    
    UIWebView *web = [UIWebView new];
    web.frame = CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight);
    [self.view addSubview:web];
    
    //加载本地的html文件
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *nameStr = @"SigningAgreements.html";
    if (_protocolType == 1) {
        nameStr = @"merchantAgreement.html";
    }
    
    NSString *filePath = [resourcePath stringByAppendingPathComponent:nameStr];
    
    ////如果之前不能解码，现在使用GBK解码
    NSString *htmlString = [[NSString alloc] initWithContentsOfFile:filePath encoding:0x80000632 error:nil];

    //将文字内容显示到webview控件上
    [web loadHTMLString: htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}


@end
