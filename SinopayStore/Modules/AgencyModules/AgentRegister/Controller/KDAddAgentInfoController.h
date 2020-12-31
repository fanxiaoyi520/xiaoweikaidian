//
//  KDAddAgentInfoController.h
//  SinopayStore
//
//  Created by 中付支付 on 2018/12/25.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDAddAgentInfoController : ZFBaseViewController
///注册区号
@property (nonatomic, strong)NSString *areaNum;
///注册账号
@property (nonatomic, strong)NSString *account;

@end

NS_ASSUME_NONNULL_END
