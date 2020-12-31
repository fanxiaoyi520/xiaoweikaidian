//
//  KDCollectionDateModel.m
//  SinopayStore
//
//  Created by Jellyfish on 2017/12/7.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "KDCollectionDateModel.h"
#import "DateUtils.h"

@implementation KDCollectionDateModel

// 如果是当前日期则显示@“今天”
- (NSString *)day {
    NSString *currentDate = [DateUtils getCurrentDateWithFormat:@"yyyy.MM.dd"];
    if ([_day isEqualToString:currentDate]) {
        return NSLocalizedString(@"今天", nil);
    }
    return _day;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"dailyList" : [KDCollectionDeatilsModel class]};
}


@end
