//
//  KDRewardListModel.m
//  SinopayStore
//
//  Created by 中付支付 on 2018/3/1.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDRewardListModel.h"

@implementation KDRewardListModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (void)setTxnAmt:(NSString *)txnAmt{
    if (![txnAmt isKindOfClass:[NSNull class]]) {
        _txnAmt = [NSString stringWithFormat:@"%.2f", [txnAmt doubleValue]/100];
    }
}

- (void)setBonusAmt:(NSString *)bonusAmt{
    if (![bonusAmt isKindOfClass:[NSNull class]]) {
        _bonusAmt = [NSString stringWithFormat:@"%.2f", [bonusAmt doubleValue]/100];
    }
}

@end
