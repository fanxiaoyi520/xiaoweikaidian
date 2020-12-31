//
//  KDTradeDetailsModel.h
//  SinopayStore
//
//  Created by Jellyfish on 2017/12/8.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDTradeDetailsModel : NSObject

/** 交易金额 */
@property(nonatomic, copy) NSString *cardNum;
/** 交易金额 */
@property(nonatomic, copy) NSString *txnAmt;
/** 交易时间 */
@property(nonatomic, copy) NSString *transTime;
/** 结算金额 */
@property(nonatomic, copy) NSString *settAmt;
/** 订单号 */
@property(nonatomic, copy) NSString *orderID;

@end
