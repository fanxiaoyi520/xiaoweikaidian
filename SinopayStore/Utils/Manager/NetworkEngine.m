//
//  NetworkEngine.m
//  newupop
//
//  Created by Jellyfish on 2017/7/27.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "NetworkEngine.h"
#import "AFNetworking.h"
#import "NSString+NetworkParameters.h"
#import "HBRSAHandler.h"
#import "YYModel.h"
#import "NSString+JSON.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "ZFNavigationController.h"
#import <Bugly/Bugly.h>


@interface NetworkEngine ()

// 当前请求操作任务
@property(nonatomic, strong) NSURLSessionDataTask *task;
@property(nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation NetworkEngine

+ (instancetype)sharedManager {
    static NetworkEngine *networkEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkEngine = [[NetworkEngine alloc] init];
    });
    return networkEngine;
}

- (AFHTTPSessionManager *)getManager{
    if (!_manager) {
        // 显示左上角菊花
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        [AFNetworkActivityIndicatorManager sharedManager].activationDelay = 0.0;
        
        //发起请求
        _manager = [AFHTTPSessionManager manager];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _manager.securityPolicy.allowInvalidCertificates = YES;
        _manager.securityPolicy.validatesDomainName = NO;
        
        // 设置不使用cookie
        AFHTTPRequestSerializer *myHTTPRequestSerializer = _manager.requestSerializer;
        _manager.requestSerializer = myHTTPRequestSerializer;
        [myHTTPRequestSerializer setHTTPShouldHandleCookies:NO];
        myHTTPRequestSerializer.timeoutInterval = 30.0f;
    }
    return _manager;
}

+ (void)postWtihURL:(NSString *)urlStr parmas:(NSDictionary *)params success:(RequestSuccessBlock)success failure:(RequestFailureBlock)failure
{
    // 添加签名字段
    NSMutableDictionary *paramPOST = [[NSMutableDictionary alloc] initWithDictionary:params];
    
    NSString *languageStr = [self getCurrentLanguage];
    //添加language字段  1 英语  2 汉语繁体 3 简体中文
    [paramPOST setValue:languageStr forKey:@"language"];
    
    //代理登录去掉语言
    if (![paramPOST objectForKey:@"txnType"]) {
        [paramPOST removeObjectForKey:@"language"];
    }
    
    // 需要签名的字符串
    NSString *plainText = [NSString getSanwingNetworkParam:paramPOST connector: @"&"];
    plainText = [plainText stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    // 签名
    NSString *sigMD5 = [[HBRSAHandler sharedInstance] signMD5String:plainText];
    
    //上传头像接口图片不需要签名
    if ([[params objectForKey:@"txnType"] isEqualToString:@"07"]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
        [dict removeObjectForKey:@"image"];
        [dict setValue:languageStr forKey:@"language"];
        NSString *signStr = [NSString getSanwingNetworkParam:dict connector:@"&"];
        sigMD5 = [[HBRSAHandler sharedInstance] signMD5String:signStr];
    }
    
    [paramPOST setValue:sigMD5 forKey:@"signature"];
    
    AFHTTPSessionManager *manager = [[NetworkEngine sharedManager] getManager];
    
    DLog(@"paramPOST = %@", paramPOST);
    
    // 发起网络请求
    [NetworkEngine sharedManager].task = [manager POST:urlStr parameters:paramPOST progress:^(NSProgress * _Nonnull uploadProgress)
    {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        // 转字典
        NSDictionary *resultDic = [NSString parseJSONStringToNSDictionary:result];
         DLog(@"txnType%@-服务器返回数据: %@", [paramPOST objectForKey:@"txnType"], resultDic);
        if (resultDic) {
            if([[resultDic objectForKey:@"status"] isEqualToString: @"168"]){//此账号已在其他设备登陆，若非本人操作请及时联系客服！
                
                [self jumpToLogin];
                return ;
            }
            success(resultDic);
        } else {
            DLog(@"服务器异常,请稍后再试");
            [[MBUtils sharedInstance] showMBFailedWithText:NetRequestError inView:[[UIApplication sharedApplication].windows firstObject]];
            
            [Bugly reportExceptionWithCategory:3 name:@"服务器异常,返回空值" reason:plainText callStack:@[] extraInfo:@{} terminateApp:NO];
            
            failure(@"");
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
    {
        DLog(@"txnType%@-出错啦-- %@\n, %zd", [paramPOST objectForKey:@"txnType"], error.userInfo, error.code);
        [[MBUtils sharedInstance] dismissMB];
        [[MBUtils sharedInstance] showMBFailedWithText:NetRequestError inView:[[UIApplication sharedApplication].windows firstObject]];
        
        [Bugly reportExceptionWithCategory:3 name:@"请求失败" reason:[NSString stringWithFormat:@"postParam=%@  error=%@", plainText, error.userInfo] callStack:@[] extraInfo:@{} terminateApp:NO];
        
        failure(error);
     }];
}

+ (void)agentPostWithParams:(NSDictionary *)params success:(RequestSuccessBlock)success failure:(RequestFailureBlock)failure{
    
    // 添加签名字段
    NSMutableDictionary *paramPOST = [[NSMutableDictionary alloc] initWithDictionary:params];
    
//    NSString *languageStr = [self getCurrentLanguage];
//    //添加language字段  1 英语  2 汉语繁体 3 简体中文
//    [paramPOST setValue:languageStr forKey:@"language"];
    
    // 需要签名的字符串
    NSString *plainText = [NSString getSanwingNetworkParam:paramPOST connector: @"&"];

    // 签名
    NSString *sigMD5 = [[HBRSAHandler sharedInstance] signMD5String:plainText];
    [paramPOST setValue:sigMD5 forKey:@"signature"];
    
    DLog(@"paramPOST = %@", paramPOST);
    
    AFHTTPSessionManager *manager = [[NetworkEngine sharedManager] getManager];
    // 发起网络请求
    [NetworkEngine sharedManager].task = [manager POST:AgencyBaseUrl parameters:paramPOST progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        // 转字典
        NSDictionary *resultDic = [NSString parseJSONStringToNSDictionary:result];
        DLog(@"服务器返回数据: %@", resultDic);
        success(resultDic);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[MBUtils sharedInstance] showMBFailedWithText:NetRequestError inView:[[UIApplication sharedApplication].windows firstObject]];
        
        [Bugly reportExceptionWithCategory:3 name:@"请求失败" reason:[NSString stringWithFormat:@"postParam=%@  error=%@", plainText, error.userInfo] callStack:@[] extraInfo:@{} terminateApp:NO];
    }];
}

+ (void)merchantPostWithParams:(NSDictionary *)params success:(RequestSuccessBlock)success failure:(RequestFailureBlock)failure{
    // 添加签名字段
    NSMutableDictionary *paramPOST = [[NSMutableDictionary alloc] initWithDictionary:params];
    // 需要签名的字符串
    NSString *plainText = [NSString getSanwingNetworkParam:paramPOST connector: @"&"];
    
    // 签名
    NSString *sigMD5 = [[HBRSAHandler sharedInstance] signMD5String:plainText];
    [paramPOST setValue:sigMD5 forKey:@"signature"];
    
    DLog(@"paramPOST = %@", paramPOST);
    
    AFHTTPSessionManager *manager = [[NetworkEngine sharedManager] getManager];
    // 发起网络请求
    [NetworkEngine sharedManager].task = [manager POST:AgentMerChantURL parameters:paramPOST progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        // 转字典
        NSDictionary *resultDic = [NSString parseJSONStringToNSDictionary:result];
        DLog(@"服务器返回数据: %@", resultDic);
        success(resultDic);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[MBUtils sharedInstance] showMBFailedWithText:NetRequestError inView:[[UIApplication sharedApplication].windows firstObject]];
        
        [Bugly reportExceptionWithCategory:3 name:@"请求失败" reason:[NSString stringWithFormat:@"postParam=%@  error=%@", plainText, error.userInfo] callStack:@[] extraInfo:@{} terminateApp:NO];
    }];
}

+ (void)singlePostWithParmas:(NSDictionary *)params success:(RequestSuccessBlock)success failure:(RequestFailureBlock)failure
{
    [self postWtihURL:BASEURL parmas:params success:success failure:failure];
}


+ (void)cancelAllNetworkAciton
{
    if ([NetworkEngine sharedManager].task) {
        [[NetworkEngine sharedManager].task cancel];
        [NetworkEngine sharedManager].task = nil;
    }
}

+ (void)getNetStatus{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case -1:
                DLog(@"未知网络");
                break;
            case 0:
                DLog(@"网络不可达");
                break;
            case 1:
                DLog(@"GPRS网络");
                break;
            case 2:
                DLog(@"wifi网络");
                break;
            default:
                break;
        }
        if(status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi){
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:NETWORK_ISOK];
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:NETWORK_ISOK];
        }
    }];
}

+ (void)jumpToLogin{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"注意", nil) message:NSLocalizedString(@"此账号已在其他设备登陆，若非本人操作请及时联系客服", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 跳转至登录界面
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        window.rootViewController = [[ZFNavigationController alloc] initWithRootViewController:[ZFGlobleManager getGlobleManager].loginVC];
    }];

    [alert addAction:confirm];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

+ (NSString *)getCurrentLanguage{
    //iOS11
//    zh-Hant-HK, 繁体香港
//    zh-Hans-CN, 简体中文
//    en-CN,      英文
//    zh-Hant-CN, 繁体中文
//    zh-Hant-TW, 繁体台湾
//    zh-Hant-MO, 繁体澳门
//    en-GB,      英文英国
//    en-AU,      英文澳洲
//    en-IN       英文印度
    
    //iOS 8
//    zh-HK,      繁体香港
//    zh-Hans,    简体中文
//    zh-Hant,    繁体中文
//    en          英文
    
    NSString *language = @"1";
    NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString *languageName = [appLanguages objectAtIndex:0];
    if ([languageName hasPrefix:@"zh-Hant"] || [languageName containsString:@"zh-HK"]) {
        language = @"2";
    }
    if ([languageName hasPrefix:@"zh-Hans"]) {
        language = @"3";
    }
    return language;
}

@end
