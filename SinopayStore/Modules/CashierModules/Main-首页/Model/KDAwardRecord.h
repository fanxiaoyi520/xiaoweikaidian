//
//  KDAwardRecord.h
//  SinopayStore
//
//  Created by Jellyfish on 2018/1/3.
//  Copyright © 2018年 中付支付. All rights reserved.
//  奖励记录模型

#import <Foundation/Foundation.h>

@interface KDAwardRecord : NSObject

/** 结余奖励金 */
@property(nonatomic, copy) NSString *rewardbalAmt;
/** 提现或奖励金额 */
@property(nonatomic, copy) NSString *transAmt;
/** 提现获奖励日期 */
@property(nonatomic, copy) NSString *transDate;
/** 提现或奖励单号 */
@property(nonatomic, copy) NSString *transNumber;
/** 提现或奖励类型（状态） */
@property(nonatomic, copy) NSString *transType;



@end
