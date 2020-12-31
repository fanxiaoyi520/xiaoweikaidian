//
//  KDRevocateResultController.h
//  SinopayStore
//
//  Created by 中付支付 on 2017/12/11.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

@interface KDRevocateResultController : ZFBaseViewController


///撤销状态  0 撤销成功  1 失败
@property (nonatomic, strong)NSString *status;

///订单号
@property (nonatomic, strong)NSString *orderID;
///卡号
@property (nonatomic, strong)NSString *cardNum;
///撤销金额
@property (nonatomic, strong)NSString *txnAmt;

///失败原因
@property (nonatomic, strong)NSString *causeStr;

@property (nonatomic, strong)NSString *payType;
@end
