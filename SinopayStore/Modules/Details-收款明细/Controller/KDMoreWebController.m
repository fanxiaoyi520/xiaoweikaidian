//
//  KDMoreWebController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/8/31.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDMoreWebController.h"
#import <WebKit/WebKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "NSString+NetworkParameters.h"

@interface KDMoreWebController ()<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKUserContentController *userContentController;

@end

@implementation KDMoreWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.naviTitle = NSLocalizedString(@"更多", nil);
    [self createView];
}

- (void)createView{
    
    NSString *merCode = [ZFGlobleManager getGlobleManager].merID;
    NSString *termCode = [ZFGlobleManager getGlobleManager].termCode;
    
    if (!merCode) {
        merCode = @"";
    }
    if (!termCode) {
        termCode = @"";
    }
    
    NSInteger loginType = [[NSUserDefaults standardUserDefaults] integerForKey:@"loginTypeBtn"];
    if (loginType == 0) {//商户登录不要termCode
        termCode = @"";
    }
    
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = GrayBgColor;
    [self.view addSubview:lineView];
    
    WKWebViewConfiguration * Configuration = [[WKWebViewConfiguration alloc]init];
    ///添加js和wkwebview的调用
    _userContentController =[[WKUserContentController alloc]init];
    //    [_userContentController addScriptMessageHandler:self  name:@"testShow"];//注册一个name为testShow的js方法
    Configuration.userContentController = _userContentController;
    
    // 添加webView
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, lineView.bottom, SCREEN_WIDTH, SCREEN_HEIGHT-1-IPhoneXTopHeight) configuration:Configuration];
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    _webView.scrollView.showsVerticalScrollIndicator = NO;
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    NSDictionary *dict = @{
                           @"userType":@"MERCHANT",
                           @"userLoginLocation":@"xiaowei",
                           @"merCode":merCode,
                           @"termCode":termCode
                           };
    
    NSString *params = [NSString getSanwingNetworkParam:dict connector:@"&"];
    NSString *postStr = [NSString stringWithFormat:@"%@?%@", MoreTradeWebUrl, params];
    NSURL *url = [NSURL URLWithString:postStr];
    DLog(@"postUrl = %@", postStr);
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    
    [_webView loadRequest:request];
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
}

- (NSString *)sha256EcryptWith:(NSString *)input{
    
    const char *s = [input cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH] = {0};
    CC_SHA256(keyData.bytes, (CC_LONG)keyData.length, digest);
    NSData *out = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSString *hash = [out description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hash;
}

#pragma mark - WKNavigationDelegate
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    [webView evaluateJavaScript:@"document.getElementById('flag').value"
              completionHandler:^(id _Nullable htmlString, NSError * _Nullable error) {
                  //                  DLog(@"%@", htmlString);
                  //                  if (htmlString && [htmlString integerValue] >= 0) {//返回交易记录条数
                  //
                  //                  }
              }];
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    [XLAlertController acWithMessage:NetRequestError confirmBtnTitle:NSLocalizedString(@"确定", nil) confirmAction:^(UIAlertAction *action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            self.progressView.hidden = YES;
            [self.progressView setProgress:0 animated:NO];
        } else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
}

#pragma mark WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
}

#pragma mark other
- (void)dealloc {
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

#pragma mark 懒加载
- (UIProgressView *)progressView
{
    if(!_progressView)
    {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, 0)];
        _progressView.tintColor = MainThemeColor;
        _progressView.trackTintColor = [UIColor whiteColor];
        [self.view addSubview:_progressView];
    }
    return _progressView;
}

@end
