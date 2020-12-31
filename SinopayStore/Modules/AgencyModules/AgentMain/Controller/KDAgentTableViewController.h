//
//  KDAgentTableViewController.h
//  SinopayStore
//
//  Created by 中付支付 on 2019/4/10.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDAgentTableViewController : ZFBaseViewController

/// 0 默认商户列表  1 代理列表  2 交易列表  3 分润列表  4 分润详情列表  5 提现余额明细  6 提现申请记录
@property (nonatomic, assign)NSInteger tableType;

///分润详情
@property (nonatomic, strong)NSDictionary *infoDict;

@end

NS_ASSUME_NONNULL_END
