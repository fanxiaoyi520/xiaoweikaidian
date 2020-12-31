//
//  KDSettmentWebController.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/5/15.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDSettmentWebController.h"
#import <WebKit/WebKit.h>
#import "KDSendReportController.h"
#import "DateUtils.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "WKWebView+Image.h"

@interface KDSettmentWebController ()<WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) WKWebView *webView;
///商户号+时间
@property (nonatomic, strong)NSString *merIdAndTime;
///时间
@property (nonatomic, strong)NSString *nowTime;

@property (nonatomic, strong)UIButton *rightBtn;

@property (nonatomic, strong)UIImage *webImage;

@end

@implementation KDSettmentWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviTitle = NSLocalizedString(@"手动结算", nil);
    [self createView];
}

- (void)createView{
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = GrayBgColor;
    [self.view addSubview:lineView];
    // 添加webView
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, IPhoneXTopHeight+1, SCREEN_WIDTH, SCREEN_HEIGHT-IPhoneXTopHeight-1)];
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    _webView.scrollView.showsVerticalScrollIndicator = NO;
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    
    NSString *urlStr = [self getUrlString];
    DLog(@"urlStr = %@", urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
}

- (void)createRightBtn{
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _rightBtn.frame = CGRectMake(SCREEN_WIDTH-130, IPhoneXStatusBarHeight, 110, IPhoneNaviHeight);
//    [_rightBtn setTitle:NSLocalizedString(@"保存", nil) forState:UIControlStateNormal];
    [_rightBtn setTitle:NSLocalizedString(@"发送", nil) forState:UIControlStateNormal];
    [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _rightBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_rightBtn addTarget:self action:@selector(clickSendBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_rightBtn];
}

//保存
- (void)clickSendBtn{
//    CGFloat height = _webView.height;
//    if (height < _webView.scrollView.contentSize.height) {
//        _webView.height = _webView.scrollView.contentSize.height;
//    }
//    _webImage = [self.webView imageRepresentation];
//
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//    [library writeImageToSavedPhotosAlbum:[_webImage CGImage] orientation:(ALAssetOrientation)[_webImage imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
//        _webView.height = SCREEN_HEIGHT-IPhoneXTopHeight-1;
//        if (error) {
//            [[MBUtils sharedInstance] showMBSuccessdWithText:NSLocalizedString(@"保存失败", nil) inView:self.view];
//        } else {
//            [[MBUtils sharedInstance] showMBSuccessdWithText:NSLocalizedString(@"保存成功", nil) inView:self.view];
//        }
//    }];
    
    
//    KDSendReportController *srVC = [[KDSendReportController alloc] init];
//    srVC.merIdAndTime = _merIdAndTime;
//    srVC.webImage = _webImage;
//    srVC.nowTime = _nowTime;
//    [self pushViewController:srVC];
    
    
    if ([[ZFGlobleManager getGlobleManager].email isKindOfClass:[NSNull class]] || [ZFGlobleManager getGlobleManager].email.length < 1) {
        [[MBUtils sharedInstance] showMBTipWithText:NSLocalizedString(@"该商户未绑定邮箱", nil) inView:self.view];
        return;
    }
    
    NSString *merIdAndTime = [NSString stringWithFormat:@"%@%@%@", [ZFGlobleManager getGlobleManager].merID, _nowTime, [ZFGlobleManager getGlobleManager].termCode];
    
    NSDictionary *dicts = @{@"countryCode":[ZFGlobleManager getGlobleManager].areaNum,
                            @"mobile":[ZFGlobleManager getGlobleManager].userPhone,
                            @"sessionID":[ZFGlobleManager getGlobleManager].sessionID,
                            @"email":[ZFGlobleManager getGlobleManager].email,
                            @"merIdAndDate":merIdAndTime,
                            @"txnType":@"63"
                            };
    [[MBUtils sharedInstance] showMBWithText:@"" inView:self.view];
    [NetworkEngine singlePostWithParmas:dicts success:^(id requestResult) {
        
        if ([[requestResult objectForKey:@"status"] isEqualToString:@"0"]) {
            self.block(YES);
            [[MBUtils sharedInstance] showMBSuccessdWithText:[requestResult objectForKey:@"msg"] inView:[UIApplication sharedApplication].keyWindow];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [[MBUtils sharedInstance] showMBFailedWithText:[requestResult objectForKey:@"msg"] inView:[UIApplication sharedApplication].keyWindow];
        }
    } failure:^(id error) {
        
    }];
    
}

- (NSString *)getUrlString{
    _nowTime = [DateUtils getCurrentDateWithFormat:@"YYYYMMddHHmmss"];
    _merIdAndTime = [NSString stringWithFormat:@"%@%@%@", [ZFGlobleManager getGlobleManager].merID, _nowTime, [ZFGlobleManager getGlobleManager].termCode];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", SettmentWebUrl, _merIdAndTime];
    
    return urlStr;
}

#pragma mark - WKNavigationDelegate
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    [webView evaluateJavaScript:@"document.getElementById('flag').value"
              completionHandler:^(id _Nullable htmlString, NSError * _Nullable error) {
                  DLog(@"%@", htmlString);
                  if (htmlString && [htmlString integerValue] >= 0) {//返回交易记录条数
                      [self createRightBtn];
                  }
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

- (void)dealloc {
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

#pragma mark - 懒加载
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
