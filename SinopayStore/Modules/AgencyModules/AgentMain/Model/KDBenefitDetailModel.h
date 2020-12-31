//
//  KDBenefitDetailModel.h
//  SinopayStore
//
//  Created by 中付支付 on 2019/2/15.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDBenefitDetailModel : NSObject

@property (nonatomic, strong)NSString *xiajiAccount;
@property (nonatomic, strong)NSString *transAmount;
@property (nonatomic, strong)NSString *xiaJiName;
@property (nonatomic, strong)NSString *fenrunDate;
@property (nonatomic, strong)NSString *xiajiRate;
@property (nonatomic, strong)NSString *fenrunAmount;
@property (nonatomic, strong)NSString *xiajiType;
@property (nonatomic, strong)NSString *transType;

@end

NS_ASSUME_NONNULL_END
