//
//  KDWithdrawalDetails.h
//  SinopayStore
//
//  Created by Jellyfish on 2018/1/5.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDWithdrawalDetails : NSObject

/** 银行名称 */
@property(nonatomic, copy) NSString *bankName;
/** 银行卡号 */
@property(nonatomic, copy) NSString *cardNo;
/** 提现金额 */
@property(nonatomic, copy) NSString *drawAmt;
/** 提现申请时间 */
@property(nonatomic, copy) NSString *drawApplyTime;
/** 提现到账时间 */
@property(nonatomic, copy) NSString *drawAccTime;
/** 提现单号 */
@property(nonatomic, copy) NSString *drawNumber;
/** 提现状态 */
@property(nonatomic, copy) NSString *drawStatus;

@end
