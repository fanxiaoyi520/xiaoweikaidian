//
//  KDAddAgentImageController.h
//  SinopayStore
//
//  Created by 中付支付 on 2018/12/25.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDAddAgentImageController : ZFBaseViewController
///注册区号加账号
@property (nonatomic, strong)NSString *account;
///代理类型 0 个人  1 公司
@property (nonatomic, assign)NSInteger agentType;

@end

NS_ASSUME_NONNULL_END
