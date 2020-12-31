//
//  KDWithdrawalDetailsViewController.h
//  SinopayStore
//
//  Created by Jellyfish on 2018/1/3.
//  Copyright © 2018年 中付支付. All rights reserved.
//  提现详情

#import "ZFBaseViewController.h"
#import "KDAwardRecord.h"

@interface KDWithdrawalDetailsViewController : ZFBaseViewController

typedef NS_ENUM(NSInteger, DetailsType) {
    DetailsTypeWithdrawal = 0,   // 提现详情
    DetailsTypeAward,      // 奖励详情
    DetailsTypeRevocation,  // 撤销详情
};


///交易单号
@property (nonatomic, strong)NSString *transNumber;

@end
