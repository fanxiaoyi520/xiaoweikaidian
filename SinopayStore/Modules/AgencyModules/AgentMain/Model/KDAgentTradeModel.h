//
//  KDAgentTradeModel.h
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/4.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDAgentTradeModel : NSObject

@property (nonatomic, strong)NSString *acqInsCode;
@property (nonatomic, strong)NSString *cardNo;
@property (nonatomic, strong)NSString *merCode;
@property (nonatomic, strong)NSString *merName;
@property (nonatomic, strong)NSString *orderNum;
@property (nonatomic, strong)NSString *respCode;
@property (nonatomic, strong)NSString *srveniryMode;
@property (nonatomic, strong)NSString *traceNumber;
@property (nonatomic, strong)NSString *transAmt;
@property (nonatomic, strong)NSString *transCode;
@property (nonatomic, strong)NSString *transDate;
@property (nonatomic, strong)NSString *transType;

@end

NS_ASSUME_NONNULL_END
