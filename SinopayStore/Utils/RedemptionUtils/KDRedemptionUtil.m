//
//  KDRedemptionUtil.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/27.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDRedemptionUtil.h"

@implementation KDRedemptionUtil

+ (NSString *)getOperateTypeChineseWith:(NSString *)operateType{
    if ([operateType isKindOfClass:[NSNull class]] || !operateType) {
        return @"";
    }
    NSDictionary *dict = [self operateTypeDict];
    
    return [dict objectForKey:operateType];
}

+ (NSString *)getTransStateChineseWith:(NSString *)transState{
    if ([transState isKindOfClass:[NSNull class]] || !transState) {
        return @"";
    }
    
    NSDictionary *dict = [self transStateDict];
    
    return [dict objectForKey:transState];
}

+ (NSDictionary *)operateTypeDict{
    return @{
             @"WITHDARW":NSLocalizedString(@"提现", nil),
             @"FENRUN":NSLocalizedString(@"分润", nil)
             };
}

+ (NSDictionary *)transStateDict{
    
    return @{
             @"WTIHDARW_WAIT_AUDTI":NSLocalizedString(@"提现等待审核", nil),
             @"WTIHDARW_AUDTI_SUCCESS":NSLocalizedString(@"提现审核成功", nil),
             @"WTIHDARW_AUDTI_FAILED":NSLocalizedString(@"提现审核失败", nil),
             @"WTIHDARW_SUCCESS":NSLocalizedString(@"提现成功", nil),
             @"WTIHDARW_SETTLE_FAILED":NSLocalizedString(@"出帐失败", nil),
             @"FENRUN":NSLocalizedString(@"分润", nil)
             };
}

@end
