//
//  KDRewardListModel.h
//  SinopayStore
//
//  Created by 中付支付 on 2018/3/1.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDRewardListModel : NSObject

///奖励编号
@property (nonatomic, strong)NSString *bonusId;
///参考号
@property (nonatomic, strong)NSString *serialNumber;
///交易金额
@property (nonatomic, strong)NSString *txnAmt;
///奖励金额
@property (nonatomic, strong)NSString *bonusAmt;
///交易币种
@property (nonatomic, strong)NSString *txnCurr;

///领取状态
@property (nonatomic, strong)NSString *gainStatus;
///领取信息
@property (nonatomic, strong)NSString *gainMsg;

@end
