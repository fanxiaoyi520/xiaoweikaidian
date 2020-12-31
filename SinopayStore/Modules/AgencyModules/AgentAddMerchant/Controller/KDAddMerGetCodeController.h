//
//  KDAddMerGetCodeController.h
//  SinopayStore
//
//  Created by 中付支付 on 2019/2/15.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDAddMerGetCodeController : ZFBaseViewController

///0 默认新增商户  1 忘记密码  2 新增代理
@property (nonatomic, assign)NSInteger codeType;

@end

NS_ASSUME_NONNULL_END
