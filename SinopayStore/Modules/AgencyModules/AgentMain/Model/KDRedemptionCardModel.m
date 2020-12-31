//
//  KDRedemptionCardModel.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/21.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDRedemptionCardModel.h"

@implementation KDRedemptionCardModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (NSString *)settleAccount{
    return [_settleAccount stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

- (NSString *)cardNo{
    _settleAccount = [_settleAccount stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *num = [TripleDESUtils getDecryptWithString:_settleAccount keyString:AgencyTripledesKey ivString:TRIPLEDES_IV];
    
    return num;
}

@end
