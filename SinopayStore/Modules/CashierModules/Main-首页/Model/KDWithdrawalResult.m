//
//  KDWithdrawalResult.m
//  SinopayStore
//
//  Created by Jellyfish on 2018/1/4.
//  Copyright © 2018年 中付支付. All rights reserved.
//

#import "KDWithdrawalResult.h"
#import "DateUtils.h"

@implementation KDWithdrawalResult

- (NSString *)drawAmt {
    return [NSString stringWithFormat:@"%.2f", [_drawAmt floatValue]/100.0];
}

- (NSString *)cardNo {
    NSString *decryNo = [TripleDESUtils getDecryptWithString:[_cardNo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                                   keyString:[ZFGlobleManager getGlobleManager].securityKey
                                                    ivString:TRIPLEDES_IV];
    NSString *SuffixNo = [NSString stringWithFormat:@"%@(%@)", [_bankName stringByReplacingOccurrencesOfString:@"\n" withString:@""], [decryNo substringFromIndex:decryNo.length-4]];
    return SuffixNo;
}

- (NSString *)drawApplyTime {
    return [DateUtils getCurrentTimeWithTimeStamp:_drawApplyTime];
}

@end
