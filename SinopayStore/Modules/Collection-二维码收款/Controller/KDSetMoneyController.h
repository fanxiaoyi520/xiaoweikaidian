//
//  KDSetMoneyController.h
//  SinopayStore
//
//  Created by 中付支付 on 2018/11/20.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SetMoneyBlock)(NSString *money);

@interface KDSetMoneyController : ZFBaseViewController

@property (nonatomic, copy)SetMoneyBlock block;
@property (nonatomic, strong)NSString *payType; //1:云闪付 2：支付宝
///金额
@property (nonatomic, strong)NSString *money;
@end

NS_ASSUME_NONNULL_END
