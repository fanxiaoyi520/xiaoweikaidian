//
//  KDScanTradeResultController.h
//  SinopayStore
//
//  Created by 中付支付 on 2018/11/21.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDScanTradeResultController : ZFBaseViewController

/// 0 成功  1 失败
@property (nonatomic, assign)NSInteger tradeType;
///失败信息
@property (nonatomic, strong)NSString *errMsg;
///金额
@property (nonatomic, strong)NSString *amount;
///卡号
@property (nonatomic, strong)NSString *cardNo;

@end

NS_ASSUME_NONNULL_END

