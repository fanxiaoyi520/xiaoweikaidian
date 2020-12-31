//
//  KDRedemptionCardModel.h
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/21.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDRedemptionCardModel : NSObject

@property (nonatomic, strong)NSString *bankCode;
@property (nonatomic, strong)NSString *settleAccountName;
@property (nonatomic, strong)NSString *settleBankName;
@property (nonatomic, strong)NSString *settleAccount;
@property (nonatomic, strong)NSString *cardNo;

@end

NS_ASSUME_NONNULL_END
