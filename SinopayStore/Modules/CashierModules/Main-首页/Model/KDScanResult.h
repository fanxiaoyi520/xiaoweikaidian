//
//  KDScanResult.h
//  SinopayStore
//
//  Created by Jellyfish on 2018/1/4.
//  Copyright © 2018年 中付支付. All rights reserved.
//  扫一扫结果模型

#import <Foundation/Foundation.h>

@interface KDScanResult : NSObject

/** 奖励单号 */
@property(nonatomic, copy) NSString *bonusId;
/** 交易参考号 */
@property(nonatomic, copy) NSString *serialNumber;
/** 订单金额 */
@property(nonatomic, copy) NSString *txnAmt;
/** 奖励金额 */
@property(nonatomic, copy) NSString *bonusAmt;
/** 订单币种 */
@property(nonatomic, copy) NSString *txnCurr;

@end
