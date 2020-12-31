//
//  UIWindow+Extension.m
//  StatePay
//
//  Created by Jellyfish on 17/3/19.
//  Copyright © 2017年 Jellyfish. All rights reserved.
//

#import "UIWindow+Extension.h"
#import "ZFNavigationController.h"
#import "ZFLoginViewController.h"
#import "NewFeatureViewController.h"
#import "NSObject+LBLaunchImage.h"

@implementation UIWindow (Extension)

- (void)switchRootViewController {
    
//    BOOL isFirstLaunch = [[[NSUserDefaults standardUserDefaults] valueForKey:@"FirstLaunch"] boolValue];
//
//    if (!isFirstLaunch) {
//        DLog(@"------第一次进入APP,展示新特性界面------");
//        self.rootViewController = [[NewFeatureViewController alloc] init];
//    } else {
        ZFLoginViewController *loginVC = [[ZFLoginViewController alloc] init];
        ZFNavigationController *navi = [[ZFNavigationController alloc] initWithRootViewController:loginVC];
        self.rootViewController = navi;
        //保存登录页 退出时不用重新创建
        [ZFGlobleManager getGlobleManager].loginVC = loginVC;

        [self setupLaunchAd];
//    }
}

- (void)setupLaunchAd
{
    [NSObject makeLBLaunchImageAdView:^(LBLaunchImageAdView *imgAdView) {
        //设置广告的类型
        imgAdView.getLBlaunchImageAdViewType(LogoAdType);
        imgAdView.adTime = 1.5;
        //自定义跳过按钮
        imgAdView.skipBtn.hidden = YES;
        
        //设置本地启动图片
        imgAdView.localAdImgName = NSLocalizedString(@"ad_ch", nil);
//        if ([[NetworkEngine getCurrentLanguage] isEqualToString:@"1"]) {
//            imgAdView.localAdImgName = @"ad_en";
//        } else {
//            imgAdView.localAdImgName = @"ad_ch";
//        }
        // 广告地址
        // imgAdView.imgUrl = @"http://img.zcool.cn/community/01316b5854df84a8012060c8033d89.gif";
        //各种点击事件的回调
        imgAdView.clickBlock = ^(clickType type){
            switch (type) {
                case clickAdType:
                    DLog(@"点击广告回调");
                    break;
                    
                case skipAdType:
                case overtimeAdType:
                    DLog(@"默认进入登录页面");
                    break;
                    
                default:
                    break;
            }
        };
    }];
}


@end

