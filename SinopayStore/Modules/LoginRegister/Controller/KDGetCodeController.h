//
//  KDGetCodeController.h
//  SinopayStore
//
//  Created by 中付支付 on 2017/12/6.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

@interface KDGetCodeController : ZFBaseViewController

/// 0 忘记商户密码  1 忘记收银员密码
@property (nonatomic, assign)NSInteger forgetType;

@end
