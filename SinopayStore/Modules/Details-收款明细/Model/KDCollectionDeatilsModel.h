//
//  KDCollectionDeatilsModel.h
//  SinopayStore
//
//  Created by Jellyfish on 2017/12/7.
//  Copyright © 2017年 中付支付. All rights reserved.
//  cell 详情

#import <Foundation/Foundation.h>

@interface KDCollectionDeatilsModel : NSObject

/** 收款类型
 1 银联扫码枪收款
 2 云闪付收款
 3 云闪付撤销
 4 银联扫码枪撤销*/
@property(nonatomic, copy) NSString *recMethod;
/** 交易金额 */
@property(nonatomic, copy) NSString *txnAmt;
/** 交易时间 */
@property(nonatomic, copy) NSString *transTime;
/** 结算金额 */
@property(nonatomic, copy) NSString *settAmt;
/** 订单号 */
@property(nonatomic, copy) NSString *orderID;

@end
