//
//  KDFormatCheck.h
//  SinopayStore
//
//  Created by 中付支付 on 2019/2/21.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDFormatCheck : NSObject

+ (BOOL)isEmailAddress:(NSString *)inputStr;

+ (BOOL)isChinese:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
