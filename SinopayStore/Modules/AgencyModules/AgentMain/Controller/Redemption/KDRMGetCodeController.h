//
//  KDRMGetCodeController.h
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/25.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDRMGetCodeController : ZFBaseViewController

///0 初始设置密码  1 忘记密码  2 添加银行卡
@property (nonatomic, assign)NSInteger getCodeType;

@end

NS_ASSUME_NONNULL_END
