//
//  AppDelegate.m
//  SinopayStore
//
//  Created by 中付支付 on 2017/11/30.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "AppDelegate.h"
#import "IQKeyboardManager.h"
#import "UIWindow+Extension.h"
#import "SpeechUtils.h"
#import "ZFTabBarViewController.h"
#import "ZFNavigationController.h"
#import "KDOrderDetailController.h"
#import <Bugly/Bugly.h>

// 推送
#import "JPUSHService.h"
// iOS10 注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif


@interface AppDelegate () <JPUSHRegisterDelegate, UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 设置极光推送
    [self setupJPUSHWithOptions:launchOptions];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window switchRootViewController];
    [self.window makeKeyAndVisible];
    
    //初始化bugly
    [self setupBugly];
    
    [self setupIQKeyBoard];
    
    return YES;
}

#pragma mark bugly
- (void)setupBugly{
    BuglyConfig *config = [[BuglyConfig alloc]init];
#if DEBUG
    config.reportLogLevel = BuglyLogLevelDebug;
#else
    config.reportLogLevel = BuglyLogLevelWarn;
#endif
    config.symbolicateInProcessEnable = YES;
    //自定义版本号
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    config.version = app_Version;
    [Bugly startWithAppId:Bugly_appid config:config];
}

/**
 设置键盘管理器
 */
- (void)setupIQKeyBoard {
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager];
    // 控制整个功能是否启用
    keyboardManager.enable = YES;
    // 控制点击背景是否收起键盘
    keyboardManager.shouldResignOnTouchOutside = YES;
    // 输入框距离键盘的距离
    keyboardManager.keyboardDistanceFromTextField = 10.0f;
    
    // 控制键盘上的工具条文字颜色是否用户自定义
//    keyboardManager.shouldToolbarUsesTextFieldTintColor = YES;
//    // 有多个输入框时，可以通过点击Toolbar 上的“前一个”“后一个”按钮来实现移动到不同的输入框
//    keyboardManager.toolbarManageBehaviour = IQAutoToolbarBySubviews;
//    // 控制是否显示键盘上的工具条
    keyboardManager.enableAutoToolbar = NO;
//    // 是否显示占位文字
//    keyboardManager.shouldShowTextFieldPlaceholder = YES;
//    // 设置占位文字的字体
//    keyboardManager.placeholderFont = [UIFont boldSystemFontOfSize:17];
}

/**
 配置极光推送
 
 @param launchOptions app启动携带参数
 */
- (void)setupJPUSHWithOptions:(NSDictionary *)launchOptions
{
    JPUSHRegisterEntity *entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert | JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    [JPUSHService setupWithOption:launchOptions appKey:JPUSH_APP_KEY
                          channel:nil
                 apsForProduction:YES
            advertisingIdentifier:nil];
    
    // 程序在后台被杀死的情况通过点击推送信息，可以从launchOptions获取到推送参数
    NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 2、非前台，后台被杀死
            [self backgroundClickedRemoteNotification:remoteNotification];
        });
    }
    DLog(@"remoteNotification:%@", [self logDic:remoteNotification]);
}

#pragma mark -- 推送相关
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    DLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#pragma mark- JPUSHRegisterDelegate
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:
(void (^)(UIBackgroundFetchResult))completionHandler {
    // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
    [JPUSHService handleRemoteNotification:userInfo];
    DLog(@"iOS7及以上系统，收到通知:%@", [self logDic:userInfo]);
    DLog(@"application.applicationState = %zd", application.applicationState);
    CGFloat systemVersion = [[UIDevice currentDevice].systemVersion doubleValue];
    NSString *orderID = [userInfo objectForKey:@"orderID"];
    if (orderID.length > 0 && systemVersion < 10.0 && application.applicationState != UIApplicationStateInactive) {
        //语音播报
        NSDictionary *dict = [userInfo objectForKey:@"aps"];
        [[SpeechUtils shareSpeece] speechIt:[dict objectForKey:@"alert"]];
    }
    
    if (application.applicationState == UIApplicationStateActive) {//前台
        if (systemVersion < 10.0) {
            [self foregroundDidReceiveRemoteNotification:userInfo];
        }
    } else if (application.applicationState == UIApplicationStateInactive) {//点击通知栏
        if (systemVersion < 10.0) {
            [self backgroundClickedRemoteNotification:userInfo];
        }
    } else {//后台收到通知
        [[NSUserDefaults standardUserDefaults] setObject:[userInfo objectForKey:@"orderID"] forKey:PUSH_ORDERID];
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma mark- JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler  API_AVAILABLE(ios(10.0)){
    //前台通知
    NSDictionary * userInfo = notification.request.content.userInfo;
    NSString *orderID = [userInfo objectForKey:@"orderID"];
    CGFloat systemVersion = [[UIDevice currentDevice].systemVersion doubleValue];
    if (orderID.length > 0 && systemVersion >= 12.1) {
        //语音播报
        NSDictionary *dict = [userInfo objectForKey:@"aps"];
        [[SpeechUtils shareSpeece] speechIt:[dict objectForKey:@"alert"]];
    }
    
    [self foregroundDidReceiveRemoteNotification:userInfo];
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler  API_AVAILABLE(ios(10.0)){
    //点击通知栏
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    [JPUSHService handleRemoteNotification:userInfo];
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [self backgroundClickedRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}
#endif

// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}
#pragma mark - 点击通知处理方法
// 1、前台收到远程通知，只发送通知
- (void)foregroundDidReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self remoteNotificationHandler:userInfo];
}

// 2、后台点击远程通知，发送通知并赋值
- (void)backgroundClickedRemoteNotification:(NSDictionary *)userInfo {
    if ([userInfo objectForKey:@"transNumber"]) {//奖励撤销通知
        [[NSUserDefaults standardUserDefaults] setObject:[userInfo objectForKey:@"transNumber"] forKey:TRANS_Number];
        [self remoteNotificationHandler:userInfo];
    } else {//交易通知
        [[NSUserDefaults standardUserDefaults] setObject:[userInfo objectForKey:@"orderID"] forKey:PUSH_ORDERID];
        [self remoteNotificationHandler:userInfo];
    }
}

// 发送通知的方法
- (void)remoteNotificationHandler:(NSDictionary *)userInfo
{
    if ([userInfo objectForKey:@"transNumber"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"voidRewardNotification" object:nil userInfo:userInfo];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReadRemoteNotificationContent" object:nil userInfo:userInfo];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //在后台时接收到交易通知
    [self jumpToCollectionDetail];
    if (![[ZFGlobleManager getGlobleManager] determineWhetherTheAPPOpensTheLocation]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"提示", nil)
                                                          message:NSLocalizedString(@"请到设置->隐私->定位服务中开启【小微开店】定位服务，以便于距离筛选能够准确获得你的位置信息", nil)
                                                         delegate:self
                                                cancelButtonTitle:nil
                                                otherButtonTitles:NSLocalizedString(@"设置", nil),nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{//点击弹窗按钮后
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)jumpToCollectionDetail{
    if ([ZFGlobleManager getGlobleManager].loginStatus != 1) {
        return;
    }
    // 获取跟控制器
    UIViewController *rootVC = nil;
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    ZFTabBarViewController *tabVC = (ZFTabBarViewController *)window.rootViewController;
    rootVC = [(ZFNavigationController *)[tabVC selectedViewController] visibleViewController];
    NSString *orderID = [[NSUserDefaults standardUserDefaults] objectForKey:PUSH_ORDERID];
    if (orderID.length > 0) {
        // 收到交易通知设置红点
        [rootVC.tabBarController.tabBar showBadgeOnItemIndex:1];
        //清空orderID
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PUSH_ORDERID];
    }
}

@end
