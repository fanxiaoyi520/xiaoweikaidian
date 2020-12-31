//
//  KDScanResult.m
//  SinopayStore
//
//  Created by Jellyfish on 2018/1/4.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDScanResult.h"

@implementation KDScanResult

- (NSString *)txnAmt
{
    return [NSString stringWithFormat:@"%.2f", [_txnAmt floatValue]/100.0];
}

- (NSString *)bonusAmt
{
    return [NSString stringWithFormat:@"%.2f", [_bonusAmt floatValue]/100.0];
}

@end
