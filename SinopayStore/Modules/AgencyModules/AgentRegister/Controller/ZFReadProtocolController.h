//
//  ZFReadProtocolController.h
//  Agent
//
//  Created by 中付支付 on 2018/10/26.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "ZFBaseViewController.h"

@interface ZFReadProtocolController : ZFBaseViewController

/// 0 代理协议 1 商户协议
@property (nonatomic, assign)NSInteger protocolType;

@end
