//
//  KDAuthenticateViewController.h
//  SinopayStore
//
//  Created by Jellyfish on 2017/12/6.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

typedef void(^MyBlock)(BOOL isReload);

@interface KDAuthenticateViewController : ZFBaseViewController

typedef NS_ENUM(NSInteger, PickViewType) {
    PickViewTypeCountry = 0,   // 所在国家
    PickViewTypeBank,      // 银行名称
    PickViewTypeStoreType, // 店铺类型
};

/// 1 登陆后进件
@property (nonatomic, assign)NSInteger authentType;
///登陆后进件回调
@property (nonatomic, copy)MyBlock block;

@end
