//
//  KDAddCashierController.h
//  SinopayStore
//
//  Created by 中付支付 on 2018/5/24.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

typedef void(^MyBlock)(BOOL isReload);

@interface KDAddCashierController : ZFBaseViewController

@property (nonatomic, copy)MyBlock block;

@end
