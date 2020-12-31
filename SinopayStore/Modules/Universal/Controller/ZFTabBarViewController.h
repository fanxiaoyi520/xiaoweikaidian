//
//  ZFTabBarViewController.h
//  SinopayStore
//
//  Created by Jellyfish on 2017/12/4.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TabbarType) {
    TabbarMerchantType = 0,     // 商户版
    TabbarCashierType,     // 收银员版
    TabbarMerchantCashierType, // 收银员账号登录商户版
    TabbarAgencyType, // 代理登录
};

@interface ZFTabBarViewController : UITabBarController

///登录类型
@property (nonatomic, assign)TabbarType tabbarType;

- (instancetype)initWithTabbarType:(TabbarType)tabbarType;

@end
