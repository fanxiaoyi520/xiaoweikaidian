//
//  KDCashierMainController.h
//  SinopayStore
//
//  Created by 中付支付 on 2018/1/3.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

@interface KDCashierMainController : ZFBaseViewController

typedef NS_ENUM(NSInteger, CashierBtnType) {
    CashierBtnTypeAward = 0,   // 奖励记录
    CashierBtnTypeScan,      // 扫一扫
};

@end
