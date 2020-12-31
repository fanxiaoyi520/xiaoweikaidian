//
//  KDWithdrawalResult.h
//  SinopayStore
//
//  Created by Jellyfish on 2018/1/4.
//  Copyright © 2018年 中付支付. All rights reserved.
//  提现结果模型

#import <Foundation/Foundation.h>

@interface KDWithdrawalResult : NSObject

/** 提现金额 */
@property(nonatomic, copy) NSString *drawAmt;
/** 提现单号 */
@property(nonatomic, copy) NSString *drawNumber;
/** 卡号 3des加密 */
@property(nonatomic, copy) NSString *cardNo;
/** 提现时间 */
@property(nonatomic, copy) NSString *drawApplyTime;
/** 银行名称 */
@property(nonatomic, copy) NSString *bankName;
/** 预计到账提示 */
@property(nonatomic, copy) NSString *tips;
@end
