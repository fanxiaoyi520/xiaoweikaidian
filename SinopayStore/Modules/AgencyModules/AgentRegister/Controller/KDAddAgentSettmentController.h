//
//  KDAddAgentSettmentController.h
//  SinopayStore
//
//  Created by 中付支付 on 2018/12/25.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDAddAgentSettmentController : ZFBaseViewController
///注册区号加账号
@property (nonatomic, strong)NSString *account;
///币种
@property (nonatomic, strong)NSString *currency;
///国家编码
@property (nonatomic, strong)NSString *countryCode;
///产品
@property (nonatomic, strong)NSArray *productArray;
///代理类型 0 个人  1 公司
@property (nonatomic, assign)NSInteger agentType;

@end

NS_ASSUME_NONNULL_END
