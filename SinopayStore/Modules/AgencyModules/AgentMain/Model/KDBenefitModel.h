//
//  KDBenefitModel.h
//  SinopayStore
//
//  Created by 中付支付 on 2019/2/14.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDBenefitModel : NSObject

@property (nonatomic, strong)NSString *transAmount;
@property (nonatomic, strong)NSString *fenrunAccount;
@property (nonatomic, strong)NSString *fenrunDate;
@property (nonatomic, strong)NSString *fenrunAmount;
@property (nonatomic, strong)NSString *fenrunTime;

@property (nonatomic, strong)NSDictionary *agentDict;
@property (nonatomic, strong)NSDictionary *merchantDict;

@end

NS_ASSUME_NONNULL_END
