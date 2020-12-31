//
//  KDAwardDetails.m
//  SinopayStore
//
//  Created by Jellyfish on 2018/1/5.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDAwardDetails.h"

@implementation KDAwardDetails

- (NSString *)bonusAmt {
    return [NSString stringWithFormat:@"%.2f", [_bonusAmt floatValue]/100.0];
}

- (NSString *)transAmt {
    return [NSString stringWithFormat:@"%.2f", [_transAmt floatValue]/100.0];
}

@end
