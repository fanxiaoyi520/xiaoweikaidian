//
//  KDAddAgentBranchBankController.h
//  SinopayStore
//
//  Created by 中付支付 on 2019/1/3.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"
typedef void(^MyBlock)(NSDictionary *dict);

NS_ASSUME_NONNULL_BEGIN

@interface KDAddAgentBranchBankController : ZFBaseViewController

///0 银行   1 分行
@property (nonatomic, assign)NSInteger searchType;

///国家编码
@property (nonatomic, strong)NSString *countryCode;
///银行代码
@property (nonatomic, strong)NSString *bankCode;
@property (nonatomic, copy)MyBlock block;


@end

NS_ASSUME_NONNULL_END
