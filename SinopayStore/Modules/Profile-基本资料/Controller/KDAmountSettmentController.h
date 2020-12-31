//
//  KDAmountSettmentController.h
//  SinopayStore
//
//  Created by 中付支付 on 2018/5/2.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

typedef void(^AmountBlock)(NSString *amount, NSInteger amountType);

@interface KDAmountSettmentController : ZFBaseViewController
///金额
@property (nonatomic, strong)NSString *amount;
///选择类型 1 小于等于  2 大于
@property (nonatomic, assign)NSInteger amountType;

@property (nonatomic, copy)AmountBlock amountBlock;

@end
