//
//  KDAwardRecord.m
//  SinopayStore
//
//  Created by Jellyfish on 2018/1/3.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDAwardRecord.h"
#import "DateUtils.h"

@implementation KDAwardRecord


- (NSString *)transDate {
    return [DateUtils getCurrentTimeWithTimeStamp:_transDate];
}


- (NSString *)transAmt {
    if ([_transAmt hasPrefix:@"+"]) {
        return [NSString stringWithFormat:@"+%.2f", [_transAmt floatValue]/100.0];
    } else {
        return [NSString stringWithFormat:@"%.2f", [_transAmt floatValue]/100.0];
    }
}

- (NSString *)rewardbalAmt {
    return [NSString stringWithFormat:@"%.2f", [_rewardbalAmt floatValue]/100.0];
}



@end
