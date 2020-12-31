//
//  KDAwardDetails.h
//  SinopayStore
//
//  Created by Jellyfish on 2018/1/5.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDAwardDetails : NSObject

/** 领取单号 */
@property(nonatomic, copy) NSString *bonusId;
/** 领取奖励金额 */
@property(nonatomic, copy) NSString *bonusAmt;
/** 参考号 */
@property(nonatomic, copy) NSString *serialNumber;
/** 领取状态 */
@property(nonatomic, copy) NSString *bonusStatus;
/** 交易金额 */
@property(nonatomic, copy) NSString *transAmt;

@end
