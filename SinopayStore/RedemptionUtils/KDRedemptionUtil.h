//
//  KDRedemptionUtil.h
//  SinopayStore
//
//  Created by 中付支付 on 2019/3/27.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDRedemptionUtil : NSObject

+ (NSString *)getOperateTypeChineseWith:(NSString *)operateType;

+ (NSString *)getTransStateChineseWith:(NSString *)transState;

@end

NS_ASSUME_NONNULL_END
