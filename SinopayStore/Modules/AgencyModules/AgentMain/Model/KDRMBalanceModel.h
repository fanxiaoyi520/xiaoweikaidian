//
//  KDRMBalanceModel.h
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/25.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDRMBalanceModel : NSObject

@property (nonatomic, strong)NSString *transState;
@property (nonatomic, strong)NSString *withDarwAmt;
@property (nonatomic, strong)NSString *operateType;
@property (nonatomic, strong)NSString *orderNum;
@property (nonatomic, strong)NSString *serviceCharge;
@property (nonatomic, strong)NSString *afterAccountAmt;
@property (nonatomic, strong)NSString *applyDate;

@end

NS_ASSUME_NONNULL_END
