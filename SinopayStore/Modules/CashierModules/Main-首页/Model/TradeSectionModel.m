//
//  TradeSectionModel.m
//  newupop
//
//  Created by Jellyfish on 2017/12/27.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "TradeSectionModel.h"

@implementation TradeSectionModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"monthList" : [KDAwardRecord class]};
}

- (NSString *)bousAct {
    return [NSString stringWithFormat:@"%.2f", [_bousAct floatValue]/100.0];
}

- (NSString *)drawAct {
    return [NSString stringWithFormat:@"%.2f", [_drawAct floatValue]/100.0];
}

@end
