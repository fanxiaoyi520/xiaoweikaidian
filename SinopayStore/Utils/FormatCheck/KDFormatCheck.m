//
//  KDFormatCheck.m
//  SinopayStore
//
//  Created by 中付支付 on 2019/2/21.
//  Copyright © 2019年 中付支付. All rights reserved.
//

#import "KDFormatCheck.h"

@implementation KDFormatCheck

+ (BOOL)isEmailAddress:(NSString *)inputStr{
    NSString *emailRegex = @"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    return [pre evaluateWithObject:inputStr];
}

+ (BOOL)isChinese:(NSString *)string {
    //包含中文
    NSString *regex = @"^[\u4E00-\u9FA5].$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:string];
    
    //全中文
    NSString *regex2 = @"^[\u4E00-\u9FA5]+$";
    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex2];
    BOOL isMatch2 = [pred2 evaluateWithObject:string];
    
    return (isMatch || isMatch2);
}

@end
