//
//  KDRedemptionDetailController.h
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/28.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDRedemptionDetailController : ZFBaseViewController

@property (nonatomic, strong)NSString *orderNum;
/// 1 提现完成时   0 默认提现列表详情
@property (nonatomic, assign)NSInteger detailType;

@end

NS_ASSUME_NONNULL_END
